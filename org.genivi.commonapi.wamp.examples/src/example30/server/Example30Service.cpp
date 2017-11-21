/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <iostream>
#include <thread>

#include <CommonAPI/CommonAPI.hpp>

#include "ExampleInterfaceStubImpl.hpp"

int main(int argc, const char * const argv[])
{
	//CommonAPI::Runtime::setProperty("LogContext", "E30CC");
	//CommonAPI::Runtime::setProperty("LogApplication", "E30CC");
	CommonAPI::Runtime::setProperty("LibraryBase", "Example30");

	std::shared_ptr<CommonAPI::Runtime> runtime = CommonAPI::Runtime::get();

	std::string domain = "local";
	std::string instance = "testcases.example30.ExampleInterface";
	std::string connection = "service-sample";

	// create service and register it at runtime
	std::shared_ptr<v0::testcases::example30::ExampleInterfaceStubImpl> myService =
			std::make_shared<v0::testcases::example30::ExampleInterfaceStubImpl>();
	runtime->registerService(domain, instance, myService);

	int i=0;
	const int nPerMinute = 10;
	while (true) {
		std::cout << "Waiting for calls... (Abort with CTRL+C)" << std::endl;
		for(int j=0; j<nPerMinute; j++) {
			int n = i*100 + j;

			if (j%2 == 0) {
				std::cout << "Firing broadcast1 event #" << n << std::endl;
				myService->fireBroadcast1Event(n);
			} else {
				std::cout << "Firing broadcast2 event #" << n << std::endl;
				myService->fireBroadcast2Event(n, 10000+n);
			}


			std::this_thread::sleep_for(std::chrono::seconds(60/nPerMinute));
		}
		i++;
	}

	return 0;
}

