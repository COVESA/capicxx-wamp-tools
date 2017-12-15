/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <iostream>
#include <thread>

#include <CommonAPI/CommonAPI.hpp>

//#include "v0/testcases/example32/ExampleInterface.hpp"
#include "ExampleInterfaceStubImpl.hpp"

using namespace v0::testcases::example32;

int main(int argc, const char * const argv[])
{
	//CommonAPI::Runtime::setProperty("LogContext", "E32CC");
	//CommonAPI::Runtime::setProperty("LogApplication", "E32CC");
	CommonAPI::Runtime::setProperty("LibraryBase", "Example32");

	std::shared_ptr<CommonAPI::Runtime> runtime = CommonAPI::Runtime::get();

	std::string domain = "local";
	std::string instance = "testcases.example32.ExampleInterface";
	std::string connection = "service-sample";

	// create service and register it at runtime
	std::shared_ptr<ExampleInterfaceStubImpl> myService =
			std::make_shared<ExampleInterfaceStubImpl>();
	runtime->registerService(domain, instance, myService);

	int i=0;
	const int nPerMinute = 20;
	while (true) {
		std::cout << "Waiting for calls... (Abort with CTRL+C)" << std::endl;
		bool toggle = true;
		for(int j=0; j<nPerMinute; j++) {
			int n = i*100 + j;

			int action = j % 6;
			switch (action) {
			case 0: {
				std::cout << "Firing broadcast1 event #" << n << std::endl;
				ExampleInterface::MyEnum arg1 =
					toggle ? ExampleInterface::MyEnum::ENUM1 : ExampleInterface::MyEnum::ENUM3;
				myService->fireBroadcast1Event(arg1);
				toggle = !toggle;
				break;
			}
			case 1: {
				std::cout << "Firing broadcast2 event #" << n << std::endl;
				ExampleInterface::MyArray1 arg1;
				arg1.push_back(n);
				arg1.push_back(n*2);
				arg1.push_back(n*3);
				myService->fireBroadcast2Event(arg1);
				break;
			}
			case 2: {
				std::cout << "Firing broadcast3 event #" << n << std::endl;
				ExampleInterface::MyArray1 arg1;
				arg1.push_back(n);
				arg1.push_back(n*2);
				arg1.push_back(n*3);
				arg1.push_back(n*4);
				myService->fireBroadcast3Event(arg1);
				break;
			}
			case 3: {
				std::cout << "Firing broadcast4 event #" << n << std::endl;
				std::vector<ExampleInterface::MyStruct> arg1;
				arg1.push_back(ExampleInterface::MyStruct(n,   toggle));
				arg1.push_back(ExampleInterface::MyStruct(n*2, !toggle));
				arg1.push_back(ExampleInterface::MyStruct(n*3, toggle));
				myService->fireBroadcast4Event(arg1);
				break;
			}
			case 4: {
				std::cout << "Firing broadcast5 event #" << n << std::endl;
				ExampleInterface::MyMap1 arg1;
				arg1[std::to_string(n)]    = n*100;
				arg1[std::to_string(n+10)] = n*200;
				arg1[std::to_string(n+20)] = n*300;
				myService->fireBroadcast5Event(arg1);
				break;
			}
			case 5: {
				std::cout << "Firing broadcast6 event #" << n << std::endl;
				ExampleInterface::MyMap2 arg1;
				arg1[std::to_string(n)]    = ExampleInterface::MyStruct(n,   toggle);
				arg1[std::to_string(n+10)] = ExampleInterface::MyStruct(n*2, !toggle);
				arg1[std::to_string(n+20)] = ExampleInterface::MyStruct(n*3, toggle);
				myService->fireBroadcast6Event(arg1);
				break;
			}
			}

			std::this_thread::sleep_for(std::chrono::seconds(60/nPerMinute));
		}
		i++;
	}

	return 0;
}

