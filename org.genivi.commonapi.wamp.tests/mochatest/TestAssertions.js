/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Markus Mühlbrandt
 * 
 ******************************************************************************/

// Use assertion library of node.js
var assert = require('assert');

exports.methodCall = function(done, session, methodCall) {
	session.call(methodCall.name, methodCall.args).then(function(res) {
		assertResult(res, methodCall.expected);
		done();
	},//
	function(err) {
		done(new Error(err.error));
	});
}

exports.broadcast = function(done, session, broadcast) {
	session.subscribe(broadcast.name, function(args) {
		console
				.log("received " + broadcast.name + ' arguments: '
						+ args.length);
		assertResult(res, broadcast.expected);
		done();
	});
}

exports.connectionState = function(connection) {
	assert.equal(true, connection.isConnected, 'No connection to server!');
}

function assertResult(res, expected) {
	if (Array.isArray(res.args)) {
		assert.equal(Array.isArray(res.args), Array.isArray(expected),
				'\nActual array type: ' + res.args
						+ '\nExpected primitive type: ' + expected);
		assert.equal(res.args.length, expected.length, 'Actual array length: '
				+ res.args.length + '\nExpected array length: '
				+ expected.length);

		for (var i = 0; i < expected.length; i++) {
			var actual = res.args[i];
			assert.equal(actual, expected[i], 'Actual[' + i + ']: ' + actual
					+ '\nExpected[' + i + ']: ' + expected[i]);
		}
	} else {
		assert.equal(Array.isArray(res.args), Array.isArray(expected),
				'Returned type is no array. Expected type is array.');

		assert.equal(res, expected, 'Actual: ' + res + '\nExpected: '
				+ expected);
	}
}