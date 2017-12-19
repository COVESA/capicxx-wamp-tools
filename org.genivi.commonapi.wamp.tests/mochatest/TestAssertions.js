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
		try {
			var expected = methodCall.expected;
			if (Array.isArray(expected)) {
				assertArray(res.args, expected);
			} else if (isPrimitive(expected)) {
				assertPrimitive(res, expected);
			}
			done();
		} catch (err) {
			done(err);
		}
	},//
	function(err) {
		done(new Error(err.error));
	});
}

exports.broadcast = function(done, session, broadcast) {
	session.subscribe(broadcast.name, function(args) {
		try {
			var expected = broadcast.expected;
			if (Array.isArray(expected)) {
				assertArray(args, expected);
			} else if (isPrimitive(expected)) {
				assertPrimitive(args, expected);
			}
			done();
		} catch (err) {
			done(err);
		}
	}).then(function(sub) {
		broadcast.subscription = sub;
	});
}

exports.connectionState = function(connection) {
	assert.equal(true, connection.isConnected, 'no connection to server!');
}

function assertArray(actual, expected) {
	if (!(Array.isArray(actual) && Array.isArray(expected))) {
		assert.fail(actual, expected, new TypeError('expected array type'));
	}

	assert.equal(actual.length, expected.length, 'array length not matching');

	for (var i = 0; i < expected.length; i++) {
		assert.equal(actual[i], expected[i], 'values at index (' + i
				+ ') do not match');
	}
}

function assertPrimitive(actual, expected) {
	if (!(isPrimitive(actual) && isPrimitive(expected))) {
		assert.fail(actual, expected, new TypeError('expected primitive type'));
	}
	assert.equal(actual, expected);
}

function isPrimitive(test) {
	return (test !== Object(test));
};