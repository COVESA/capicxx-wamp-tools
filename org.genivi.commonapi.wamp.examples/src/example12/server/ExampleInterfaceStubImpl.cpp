/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "ExampleInterfaceStubImpl.hpp"

namespace v0 {
namespace testcases {
namespace example12 {

ExampleInterfaceStubImpl::ExampleInterfaceStubImpl() : ExampleInterfaceStub() {
	std::cout << "ExampleInterfaceStubImpl constructor called" << std::endl;
}

ExampleInterfaceStubImpl::~ExampleInterfaceStubImpl() {
}

ExampleInterfaceStubImpl::RemoteEventHandlerType* ExampleInterfaceStubImpl::initStubAdapter(const std::shared_ptr<ExampleInterfaceStubImpl::StubAdapterType> &_stubAdapter) {
	return nullptr;
}

static const CommonAPI::Version version(0, 0);

const CommonAPI::Version& ExampleInterfaceStubImpl::getInterfaceVersion(std::shared_ptr<CommonAPI::ClientId> clientId) {
	return version;
}

void ExampleInterfaceStubImpl::method1(const std::shared_ptr<CommonAPI::ClientId> _client, std::string _arg1, method1Reply_t _reply) {
    std::cout << "ExampleInterfaceStubImpl::method1 called with arg1='" << _arg1 << "'" << std::endl;

    // return a slightly modified string
    _reply("Hello " + _arg1 + "!");
}

void ExampleInterfaceStubImpl::method2(const std::shared_ptr<CommonAPI::ClientId> _client, bool _arg1, method2Reply_t _reply) {
    std::cout << "ExampleInterfaceStubImpl::method2 called with arg1='" << _arg1 << "'" << std::endl;

    // return the opposite boolean value
    _reply(!_arg1);
}

void ExampleInterfaceStubImpl::method3(
		const std::shared_ptr<CommonAPI::ClientId> _client,
		ExampleInterface::MyEnum _arg1,
		method3Reply_t _reply)
{
    std::cout << "ExampleInterfaceStubImpl::method3 called with arg1='" << _arg1 << "'" << std::endl;

    ExampleInterface::MyEnum ret1;
	switch(_arg1) {
	case ExampleInterface::MyEnum::ENUM1:
		ret1 = ExampleInterface::MyEnum::ENUM2; break;
	case ExampleInterface::MyEnum::ENUM2:
		ret1 = ExampleInterface::MyEnum::ENUM3; break;
	case ExampleInterface::MyEnum::ENUM3:
		ret1 = ExampleInterface::MyEnum::ENUM4; break;
	case ExampleInterface::MyEnum::ENUM4:
		ret1 = ExampleInterface::MyEnum::ENUM1; break;
	}
    _reply(ret1);
}


} // namespace example12
} // namespace testcases
} // namespace v0
