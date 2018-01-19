/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Markus Mühlbrandt
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
		'Example32Tests',
		function() {

			var address = 'local:testcases.example32.ExampleInterface:v0_7:testcases.example32.ExampleInterface';

			var broadcasts = [ {
				name : address + '.' + 'broadcast1',
				expected : [ 1 ], // first trigger of broadcast1
				subscription : null
			}, {
				name : address + '.' + 'broadcast1',
				expected : [ 100 ], // second trigger of broadcast1
				subscription : null
			}, {
				name : address + '.' + 'broadcast6',
				expected : [ [ 4, 102 ] ], // 4 is uint32_t (first element of four in the union)
				subscription : null
			}, {
				name : address + '.' + 'broadcast7',
				expected : [ { "bar" : 6, "foo" : 3 } ],
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
			it('TestBroadcast_broadcast1_first', function(done) {
				assertBroadcast(done, broadcasts[0]);
			});

			/*
			// TODO: it doesn't work currently to test the same broadcast twice because the testcases are not synchronized
			// (we will receive the second update from the first testcase)
			it('TestBroadcast_broadcast1_second', function(done) {
				assertBroadcast(done, broadcasts[1]);
			});
			*/

			it('TestMethodCall_broadcast6', function(done) {
				assertBroadcast(done, broadcasts[2]);
			});

			it('TestMethodCall_broadcast7', function(done) {
				assertBroadcast(done, broadcasts[3]);
			});
		});

function assertBroadcast(done, broadcast) {
	assert.connectionState(connection);
	assert.broadcast(done, connection.session, broadcast);
	os.sendSignal('SIGUSR1', 'Example32Service');
}
