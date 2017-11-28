/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Markus Mühlbrandt
 * 
 ******************************************************************************/

// Use assertion library of node.js
var assert = require('assert');

exports.methodCall = function(done, session, methodCall) {
	session
			.call(methodCall.name, methodCall.args)
			.then(
					function(res) {
						if (Array.isArray(res.args)) {
							assert
									.equal(Array.isArray(res.args), Array
											.isArray(methodCall.expected),
											'Returned type is array. Expected type is primitive.');
							assert.equal(res.args.length,
									methodCall.expected.length,
									'Actual array length: ' + res.args.length
											+ '\nExpected array length: '
											+ methodCall.expected.length);

							for (var i = 0; i < methodCall.expected.length; i++) {
								var actual = res.args[i];
								var expected = methodCall.expected[i];
								assert.equal(actual, expected, 'Actual[' + i
										+ ']: ' + actual + '\nExpected[' + i
										+ ']: ' + expected);
							}
						} else {
							assert
									.equal(Array.isArray(res.args), Array
											.isArray(methodCall.expected),
											'Returned type is no array. Expected type is array.');

							assert.equal(res, methodCall.expected, 'Actual: '
									+ res + '\nExpected: '
									+ methodCall.expected);
						}
						done();
					},//
					function(err) {
						done(new Error(err.error));
					});
}

exports.connectionState = function(connection) {
	assert.equal(true, connection.isConnected, 'No connection to server!');
}