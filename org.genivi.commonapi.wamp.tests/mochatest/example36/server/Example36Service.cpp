/* Copyright (C) 2018 itemis AG
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

void registerSignalHandler(int signalNumber) {
	std::cout << "Register signal handler..." << std::endl;
	signal(signalNumber, signalHandler);
}

int main(int argc, const char * const argv[]) {

	//CommonAPI::Runtime::setProperty("LogContext", "E36CC");
	//CommonAPI::Runtime::setProperty("LogApplication", "E36CC");
	CommonAPI::Runtime::setProperty("LibraryBase", "Example36");

	std::shared_ptr < CommonAPI::Runtime > runtime = CommonAPI::Runtime::get();

	std::string domain = "local";
	std::string instance = "testcases.example36.ExampleInterface";
	std::string connection = "service-sample";

	// create service and register it at runtime
	std::shared_ptr<v0::testcases::example36::ExampleInterfaceStubImpl> myService =
			std::make_shared<v0::testcases::example36::ExampleInterfaceStubImpl>();
	runtime->registerService(domain, instance, myService);

	//Register signal handler
	//struct sigaction action;
	registerSignalHandler(SIGUSR1);

	int action = 0;
	int n = 1;

	while (true) {
		std::cout << "Waiting for calls... (Abort with CTRL+C)" << std::endl;
		for(int i=0; i<60; i++) {
			// check for signal every second
			if (signalReceived) {
				signalReceived = false;
				switch (action) {
				case 0: {
					std::cout << "Firing broadcast1 selective #" << n << std::endl;
					myService->fireBroadcast1Selective(n);
					break;
				}
				}

				action = action == 0 ? 0 : action + 1;
				n++;
			}
			sleep(1);
		}
	}

	return EXIT_SUCCESS;
}

