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
		'Example77Tests',
		function() {

			var address = 'local:testcases.example77.ExampleInterface:v0_7:testcases.example77.ExampleInterface';

			var methodCalls = [ {
				name : address + '.' + 'add2',
				args : [ 42, 20, 10 ],
				expected : [ 30, 10 ]
			}, {
				name : address + '.' + 'add2',
				args : [ 42, 10, 30 ],
				expected : [ 40, -20 ]
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
			it('TestMethodCall_add2_0', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[0]);
			});
			
			it('TestMethodCall_add2_1', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[1]);
			});
		});
