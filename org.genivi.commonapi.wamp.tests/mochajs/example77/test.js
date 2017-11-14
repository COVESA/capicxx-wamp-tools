//Use assertion library of node.js
var assert = require('assert');
// Use autobahn library
var autobahn = require('autobahn');

// Create tests for example77

var ConnectionStates = {
	UNCONNECTED : 0,
	CONNECTED : 1,
	CONNECTION_CLOSED : 2,
}

// Exchange with connection state from 'autobahn' connection if possible
var connectionState = ConnectionStates.UNCONNECTED;

var connection = new autobahn.Connection({
	url : 'ws://127.0.0.1:8080/ws',
	realm : 'realm1'
});

before(function(done) {
	connection.onopen = function(session, details) {
		connectionState = ConnectionStates.CONNECTED;
		done();
	};

	connection.onclose = function(reason, details) {
		connectionState = ConnectionStates.CONNECTION_CLOSED;
		console.log('Connection closed');
		if (reason != 'closed') {
			// Connection abnormally closed --> close normally
			connection.close();
			done();
		}
	}
	connection.open();
})

after(function() {
	if (connectionState == ConnectionStates.CONNECTED) {
		connection.close();
	}
})

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

describe(
		'Example 77 tests',
		function() {
			var addr = 'local:testcases.example77.ExampleInterface:v0_7:testcases.example77.ExampleInterface';

			var methodCalls = [ {
				name : addr + '.' + 'add2',
				args : [ 42, 20, 10 ],
				expected : 30
			} ];

			it('Check connection state', function() {
				assert.equal(ConnectionStates.CONNECTED, connectionState);
			});

			methodCalls.forEach(function(methodCall) {
				it('Call method: ' + methodCall.name, function(done) {
					if (connection.isConnected) {
						callMethod.call(null, done, connection.session,
								methodCall);
					} else {
						done(new Error("No connection to server!"));
					}
				});
			});
		});