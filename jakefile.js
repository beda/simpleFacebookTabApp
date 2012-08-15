// Copyright (c) 2012 Titanium I.T. LLC. All rights reserved. See LICENSE.txt for details.

/*global desc, task, jake, fail, complete */
(function() {
	"use strict";

	desc("Build and test");
	task("default", ["test"]);

	desc("Test everything");
	task("test", ["node"], function() {
		var reporter = require("nodeunit").reporters["default"];
		reporter.run(['src/server/_server_test.coffee'], null, function(failures) {
			if (failures) fail("Tests failed");
			complete();
   	});
	}, {async: true});

//	desc("Ensure correct version of Node is present");
	task("node", [], function() {
		var NODE_VERSION = "v0.8.6";

		sh("node --version", function(stdout) {
			if (stdout.trim() !== NODE_VERSION) fail("Incorrect node version. Expected " + NODE_VERSION + ".");
			complete();
		});
	}, {async: true});

	function sh(command, callback) {
		console.log("> " + command);

		var stdout = "";
		var process = jake.createExec(command, {printStdout:true, printStderr: true});
		process.on("stdout", function(chunk) {
			stdout += chunk;
		});
		process.on("cmdEnd", function() {
			console.log();
			callback(stdout);
		});
		process.run();
	}
}());