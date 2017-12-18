/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Markus Mühlbrandt
 * 
 ******************************************************************************/

// Use assertion library of node.js
var assert = require('assert');

exports.sendSignal = function(signal, process) {
	var spawn = require('child_process').spawn;
	var childProcess = spawn('pkill', [ '-' + signal, '-f', process ]);
	return childProcess;
}