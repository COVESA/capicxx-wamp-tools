/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <iostream>
#include <thread>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>

#include <CommonAPI/CommonAPI.hpp>

#include "ExampleInterfaceStubImpl.hpp"

static bool signalReceived = false;

void signalHandler(int signalNumber) {
	std::cout << "Received signal (" << signalNumber << ")" << std::endl;
	signalReceived = true;
}

//void registerSignalHandler(int signal, sigaction* action) {
//	std::cout << "Register signal handler..." << std::endl;
//	action->sa_handler = signalHandler;
//	sigemptyset(&action->sa_mask);
//	action->sa_flags = 0;
//	sigaction(signal, action, NULL);
//}

void registerSignalHandler(int signalNumber) {
	std::cout << "Register signal handler..." << std::endl;
	signal(signalNumber, signalHandler);
}

int main(int argc, const char * const argv[]) {

	//CommonAPI::Runtime::setProperty("LogContext", "E30CC");
	//CommonAPI::Runtime::setProperty("LogApplication", "E30CC");
	CommonAPI::Runtime::setProperty("LibraryBase", "Example30");

	std::shared_ptr < CommonAPI::Runtime > runtime = CommonAPI::Runtime::get();

	std::string domain = "local";
	std::string instance = "testcases.example30.ExampleInterface";
	std::string connection = "service-sample";

	// create service and register it at runtime
	std::shared_ptr<v0::testcases::example30::ExampleInterfaceStubImpl> myService =
			std::make_shared<v0::testcases::example30::ExampleInterfaceStubImpl>();
	runtime->registerService(domain, instance, myService);

	//Register signal handler
	//struct sigaction action;
	registerSignalHandler(SIGUSR1);

	int action = 0;
	int n = 1;
	bool toggle = false;

	while (true) {
		std::cout << "Waiting for calls... (Abort with CTRL+C)" << std::endl;
		if (signalReceived) {
			signalReceived = false;
			switch (action) {
			case 0: {
				std::cout << "Firing broadcast1 event #" << n << std::endl;
				myService->fireBroadcast1Event(n);
				break;
			}
			case 1: {
				std::cout << "Firing broadcast2 event #" << n << std::endl;
				myService->fireBroadcast2Event(n, 10000 + n);
				break;
			}
			case 2: {
				std::cout << "Firing broadcast3 event #" << n << std::endl;
				std::string p = "Number";
				myService->fireBroadcast3Event(p + std::to_string(n));
				break;
			}
			case 3: {
				std::cout << "Firing broadcast4 event #" << n << std::endl;
				myService->fireBroadcast4Event(!toggle);
				toggle = !toggle;
				break;
			}
			}

			action = action == 3 ? 0 : action + 1;
			n++;
		}
		sleep(60);
	}

	return EXIT_SUCCESS;
}

