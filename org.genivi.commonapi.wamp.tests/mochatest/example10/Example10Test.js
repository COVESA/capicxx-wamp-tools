/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 ******************************************************************************/
// Use assertion library of node.js
var assert = require('assert');
// Use autobahn library
var autobahn = require('autobahn');

// Create tests for example77

var connection = new autobahn.Connection({
	url : 'ws://127.0.0.1:8080/ws',
	realm : 'realm1'
});

function callMethod(done, session, methodCall) {
	session.call(methodCall.name, methodCall.args).then(
			function(res) {
				assert.equal(methodCall.expected, res.args[0],
						'Method result does not match!');
				done();
			}, function(err) {
				done(new Error(err.error));
			});
}

// 'describe' equals a test suite, group or package. It is used to group tests.
// 'it' equals a single test.
describe(
		'Example10Tests',
		function() {

			var address = 'local:testcases.example10.ExampleInterface:v0_7:testcases.example10.ExampleInterface';

			var methodCalls = [ {
				name : address + '.' + 'method1',
				args : [ 42, 20 ],
				expected : 20
			}, {
				name : address + '.' + 'methodWithError1',
				args : [ 42, 21 ],
				expected : 'ERROR1'
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
				if (connection.isConnected) {
					connection.close();
				}
			})

			it('TestConnectionState', function() {
				assert.equal(true, connection.isConnected,
						'No connection to server!');
			});

			// Actually the JUnit wrapper parses the 'it' tests to create the
			// JUnit test descriptor. So iterating the methodCalls array here is
			// not possible.
			it('TestMethodCall_method1', function(done) {
				if (connection.isConnected) {
					callMethod.call(null, done, connection.session,
							methodCalls[0]);
				} else {
					done(new Error("No connection to server!"));
				}
			});
			
			it('TestMethodCall_methodWithError1', function(done) {
				if (connection.isConnected) {
					callMethod.call(null, done, connection.session,
							methodCalls[1]);
				} else {
					done(new Error("No connection to server!"));
				}
			});
		});
