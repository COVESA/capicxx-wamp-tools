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

void ExampleInterfaceStubImpl::method4(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyStruct1 _arg1, method4Reply_t _reply) {
    ExampleInterface::MyStruct1 ret1;

    ret1.setElem1(_arg1.getElem1() * 2);
    ret1.setElem2(! _arg1.getElem2());
    _reply(ret1);
}

void ExampleInterfaceStubImpl::method5(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyArray1 _arg1, method5Reply_t _reply) {
    ExampleInterface::MyArray1 ret1 = {};

    // add elements in reverse order
    for(int i=_arg1.size()-1; i>=0; i--) {
    	ret1.push_back(_arg1[i]);
    }

    _reply(ret1);
}

void ExampleInterfaceStubImpl::method6(const std::shared_ptr<CommonAPI::ClientId> _client, std::vector<uint64_t> _arg1, method6Reply_t _reply) {
	std::vector<uint64_t> ret1 = {};

    // add elements in reverse order and duplicate each element
    for(int i=_arg1.size()-1; i>=0; i--) {
    	ret1.push_back(_arg1[i]);
    	ret1.push_back(_arg1[i]);
    }

    _reply(ret1);
}

void ExampleInterfaceStubImpl::method7(const std::shared_ptr<CommonAPI::ClientId> _client, std::vector<ExampleInterface::MyStruct1> _arg1, method7Reply_t _reply) {
	std::vector<ExampleInterface::MyStruct1> ret1 = {};

    // add elements in reverse order and duplicate each element
    for(int i=_arg1.size()-1; i>=0; i--) {
    	ret1.push_back(_arg1[i]);
    	ret1.push_back(_arg1[i]);
    }

    _reply(ret1);
}

void ExampleInterfaceStubImpl::method8(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyStruct2 _arg1, method8Reply_t _reply) {
    ExampleInterface::MyStruct2 ret1;

    ExampleInterface::MyEnum enum1 = _arg1.getElem1();
    ExampleInterface::MyEnum enum2 = _arg1.getElem2();

    // switch elem enumerators
    ret1.setElem1(enum2);
    ret1.setElem2(enum1);

    _reply(ret1, enum1==enum2);
}



} // namespace example12
} // namespace testcases
} // namespace v0
