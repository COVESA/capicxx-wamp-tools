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
		/*
		console.log("result method: " + JSON.stringify(res) +
			" isPrimitive=" + isPrimitive(res) +
			" isArray=" + Array.isArray(res) +
			" isMultiArg=" + isMultiArg(res));
		*/
		try {
			var expected = methodCall.expected;

			// expected always have to be an array, in order to distinguish
			// multi-argument cases and single argument of array/struct type
			if (! Array.isArray(expected)) {
				assert.fail(expected, new TypeError('expected must be array type'));
			}
			
			if (isMultiArg(res)) {
				assertArray(res.args, expected);
			} else {
				// pack actual result into 1-element array in case autobahn returns a primitive
				var resArray = [ res ];
				assertArray(resArray, expected);
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
		/*
		console.log("result broadcast: " + JSON.stringify(args) +
			" isPrimitive=" + isPrimitive(args) +
			" isArray=" + Array.isArray(args) +
			" isMultiArg=" + isMultiArg(args));
		*/
		try {
			var expected = broadcast.expected;

			// expected always have to be an array, in order to distinguish
			// multi-argument cases and single argument of array/struct type
			if (! Array.isArray(expected)) {
				assert.fail(expected, new TypeError('expected must be array type'));
			}
			
			assertArray(args, expected);
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
		if (Array.isArray(expected[i])) {
			assertArray(actual[i], expected[i]);
		} else {
			if (isPrimitive(expected[i])) {
				assert.equal(actual[i], expected[i], 'values at index (' + i + ') do not match');
			} else {
				// compare string-wise, should probably be replaced by object-deep-compare later
				//console.log("actual  : " + JSON.stringify(actual[i]));
				//console.log("expected: " + JSON.stringify(expected[i]));
				assert.equal(actual[i].toString(), expected[i].toString(), 'complex values at index (' + i + ') do not match');
			}
		}
	}
}

function isPrimitive(test) {
	return (test !== Object(test));
};

function isMultiArg(test) {
	if (isPrimitive(test)) { return false; }
	if (Array.isArray(test)) { return false; }
	return test.hasOwnProperty('args');
};
