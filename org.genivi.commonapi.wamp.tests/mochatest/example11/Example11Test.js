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
		'Example11Tests',
		function() {

			var address = 'local:testcases.example11.ExampleInterface:v0_7:testcases.example11.ExampleInterface';

			var methodCalls = [ {
				name : address + '.' + 'method1',
				args : [ 42, -64 ],
				expected : [ -128 ]
			}, {
				name : address + '.' + 'method2',
				args : [ 42, 127 ],
				expected : [ 255 ]
			}, {
				name : address + '.' + 'method3',
				args : [ 42, -16384 ],
				expected : [ -32768 ]
			}, {
				name : address + '.' + 'method4',
				args : [ 42, 32767 ],
				expected : [ 65535 ]
			}, {
				name : address + '.' + 'method5',
				args : [ 42, -1073741824 ],
				expected : [ -2147483648 ]
			}, {
				name : address + '.' + 'method6',
				args : [ 42, 2147483647 ],
				expected : [ 4294967295 ]
			}, {
				name : address + '.' + 'method7',
				args : [ 42, Number.MAX_SAFE_INTEGER ],
				expected : [ -Number.MAX_SAFE_INTEGER ]
			}, {
				name : address + '.' + 'method8',
				args : [ 42, Number.MAX_SAFE_INTEGER ],
				expected : [ 2 * Number.MAX_SAFE_INTEGER ]
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

			it('TestMethodCall_method2', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[1]);

			});

			it('TestMethodCall_method3', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[2]);

			});
			
			it('TestMethodCall_method4', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[3]);
			});
			
			it('TestMethodCall_method5', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[4]);
			});
			
			it('TestMethodCall_method6', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[5]);
			});
			
			it('TestMethodCall_method7', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[6]);
			});
			
			it('TestMethodCall_method8', function(done) {
				assert.connectionState(connection);
				assert.methodCall(done, connection.session, methodCalls[7]);
			});
		});
