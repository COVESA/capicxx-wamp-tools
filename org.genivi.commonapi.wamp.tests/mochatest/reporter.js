/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de). All rights reserved.
 * 
 * Author: Markus Mühlbrandt
 * 
 ******************************************************************************/
var mocha = require('mocha');
module.exports = MyReporter;
//[==========] Running 2 tests from 1 test case.
//[----------] Global test environment set-up.
//[----------] 2 tests from SquareRootTest
//[ RUN      ] SquareRootTest.PositiveNos
//..\user_sqrt.cpp(6862): error: Value of: sqrt (2533.310224)
//  Actual: 50.332
//Expected: 50.3321
//[  FAILED  ] SquareRootTest.PositiveNos (9 ms)
//[ RUN      ] SquareRootTest.ZeroAndNegativeNos
//[       OK ] SquareRootTest.ZeroAndNegativeNos (0 ms)
//[----------] 2 tests from SquareRootTest (0 ms total)
// 
//[----------] Global test environment tear-down
//[==========] 2 tests from 1 test case ran. (10 ms total)
//[  PASSED  ] 1 test.
//[  FAILED  ] 1 test, listed below:
//[  FAILED  ] SquareRootTest.PositiveNos
function MyReporter(runner) {
	mocha.reporters.Base.call(this, runner);
	var passes = 0;
	var failures = 0;

	runner.on('suite', function(suiteRoot) {
		if (suiteRoot.title == "") {
			var tests = 0;
			suiteRoot.suites.forEach(function(suite) {
				tests += suite.tests.length;
			});
			console.log('[==========] Running %d tests from %d test suite.',
					tests, suiteRoot.suites.length);
		}
	});

	runner.on('test', function(test) {
		console.log('[ RUN      ] %s.%s', test.parent.title, test.title);
	});

	runner.on('pass', function(test) {
		passes++;
		console.log('[       OK ] %s.%s', test.parent.title, test.title);
	});

	runner.on('fail', function(test, err) {
		failures++;
		console.log(err.message);
		console.log('[  FAILED  ] %s.%s', test.parent.title, test.title);
	});

	runner.on('suite end', function(suiteRoot) {
		if (suiteRoot.title == "") {
			var tests = 0;
			suiteRoot.suites.forEach(function(suite) {
				tests += suite.tests.length;
			});
			console.log('[==========] %d tests from %d test case ran.', tests,
					suiteRoot.suites.length);
		}
	});

	runner.on('end', function() {
		if (passes > 0) {
			console.log('[  PASSED  ] %d test.', passes);
		}
		if (failures > 0) {
			console.log('[  FAILED  ] %d test, listed below:', failures);
		}
		process.exit(failures);
	});
}