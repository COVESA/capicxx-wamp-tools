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

// Create tests for example77

var connection = new autobahn.Connection({
	url : 'ws://127.0.0.1:8080/ws',
	realm : 'realm1'
});

// 'describe' equals a test suite, group or package. It is used to group tests.
// 'it' equals a single test.
describe(
		'Example10Tests',
		function() {

			var address = 'local:testcases.example10.ExampleInterface:v0_7:testcases.example10.ExampleInterface';

			var methodCalls = [ {
				name : address + '.' + 'method1',
				args : [ 42, 20 ],
				expected : 40
			}, {
				name : address + '.' + 'methodWithError1',
				args : [ 42, 20 ],
				expected : [ 1, 0 ]
			}, {
				name : address + '.' + 'methodWithError1',
				args : [ 42, 8 ],
				expected : [ 0, 80 ]
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

			// Actually the JUnit wrapper parses the 'it' tests to create the
			// JUnit test descriptor. So iterating the methodCalls array here is
			// not possible.
			it('TestMethodCall_method1', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[0]);
			});

			it('TestMethodCall_methodWithError1', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[1]);

			});

			it('TestMethodCall_methodWithError1_noError', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[2]);

			});
		});
