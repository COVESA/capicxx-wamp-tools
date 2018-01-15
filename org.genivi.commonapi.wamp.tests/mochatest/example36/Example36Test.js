/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Klaus Birken
 * 
 ******************************************************************************/
// Use assertion library
var assert = require('../TestAssertions.js');
// Use autobahn library
var autobahn = require('autobahn');

var os = require('../UnixCommands.js');

var connection = new autobahn.Connection({
	url : 'ws://127.0.0.1:8080/ws',
	realm : 'realm1'
});

// 'describe' equals a test suite, group or package. It is used to group tests.
// 'it' equals a single test.
describe(
		'Example36Tests',
		function() {

			var address = 'local:testcases.example36.ExampleInterface:v0_7:testcases.example36.ExampleInterface';

			var broadcasts = [ {
				name : address + '.' + 'broadcast1',
				expected : [ 1 ],
				subscription : null
			} ];

			before(function(done) {
				connection.onopen = function(session, details) {
					done();
				};

				connection.onclose = function(reason, details) {
					if (reason != 'closed') {
						// Connection abnormally closed --> close normally
						connection.close();
						done();
					}
				}
				connection.open();
			})

			after(function() {
				// Cleanup subscriptions
				broadcasts.forEach(function(broadcast) {
					if (broadcast.subscription != null) {
						connection.session.unsubscribe(broadcast.subscription)
								.then(function(gone) {

								}, function(err) {
									throw new Error(err.error);
								});
					}
				});

				if (connection.isConnected) {
					connection.close();
				}
			})

			// Actually the JUnit wrapper parses the 'it' tests to create the
			// JUnit test descriptor. So iterating the methodCalls array here is
			// not possible.
			it('TestBroadcastCall_broadcast1', function(done) {
				assertBroadcast(done, broadcasts[0]);
			});

		});

function assertBroadcast(done, broadcast) {
	assert.connectionState(connection);
	assert.broadcast(done, connection.session, broadcast);
	os.sendSignal('SIGUSR1', 'Example36Service');
}
