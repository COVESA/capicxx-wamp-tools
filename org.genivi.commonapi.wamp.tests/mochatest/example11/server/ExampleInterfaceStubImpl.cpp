/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "ExampleInterfaceStubImpl.hpp"

namespace v0 {
namespace testcases {
namespace example11 {

ExampleInterfaceStubImpl::ExampleInterfaceStubImpl() :
		ExampleInterfaceStub() {
	std::cout << "ExampleInterfaceStubImpl constructor called" << std::endl;
}

ExampleInterfaceStubImpl::~ExampleInterfaceStubImpl() {
}

ExampleInterfaceStubImpl::RemoteEventHandlerType* ExampleInterfaceStubImpl::initStubAdapter(
		const std::shared_ptr<ExampleInterfaceStubImpl::StubAdapterType> &_stubAdapter) {
	return nullptr;
}

static const CommonAPI::Version version(0, 0);

const CommonAPI::Version& ExampleInterfaceStubImpl::getInterfaceVersion(
		std::shared_ptr<CommonAPI::ClientId> clientId) {
	return version;
}

void ExampleInterfaceStubImpl::method1(
		const std::shared_ptr<CommonAPI::ClientId> _client, int8_t _arg1,
		method1Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method1 called with arg1='" << _arg1
			<< "'" << std::endl;

	_reply(2 * _arg1);
}

void ExampleInterfaceStubImpl::method2(
		const std::shared_ptr<CommonAPI::ClientId> _client, uint8_t _arg1,
		method2Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method2 called" << std::endl;
	_reply(2 * _arg1 + 1);
}

void ExampleInterfaceStubImpl::method3(
		const std::shared_ptr<CommonAPI::ClientId> _client, int16_t _arg1,
		method3Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method3 called" << std::endl;
	_reply(2 * _arg1);
}

void ExampleInterfaceStubImpl::method4(
		const std::shared_ptr<CommonAPI::ClientId> _client, uint16_t _arg1,
		method4Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method4 called" << std::endl;
	_reply(2 * _arg1 + 1);
}

void ExampleInterfaceStubImpl::method5(
		const std::shared_ptr<CommonAPI::ClientId> _client, int32_t _arg1,
		method5Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method5 called" << std::endl;
	_reply(2 * _arg1);
}

void ExampleInterfaceStubImpl::method6(
		const std::shared_ptr<CommonAPI::ClientId> _client, uint32_t _arg1,
		method6Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method6 called" << std::endl;
	_reply(2 * _arg1 + 1);
}

void ExampleInterfaceStubImpl::method7(
		const std::shared_ptr<CommonAPI::ClientId> _client, int64_t _arg1,
		method7Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method7 called" << std::endl;
	_reply(-1 * _arg1);
}

void ExampleInterfaceStubImpl::method8(
		const std::shared_ptr<CommonAPI::ClientId> _client, uint64_t _arg1,
		method8Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method8 called with arg1='" << _arg1
			<< "'" << std::endl;
	_reply(2 * _arg1);
}

void ExampleInterfaceStubImpl::method9(
		const std::shared_ptr<CommonAPI::ClientId> _client, int8_t _arg1,
		int16_t _arg2, int32_t _arg3, int64_t _arg4, method9Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method9 called" << std::endl;
	_reply(2 * _arg1, 2 * _arg2, 2 * _arg3, 2 * _arg4);
}

void ExampleInterfaceStubImpl::method10(
		const std::shared_ptr<CommonAPI::ClientId> _client, uint8_t _arg1,
		uint16_t _arg2, uint32_t _arg3, uint64_t _arg4,
		method10Reply_t _reply) {
	std::cout << "ExampleInterfaceStubImpl::method10 called" << std::endl;
	_reply(2 * _arg1 + 1, 2 * _arg2 + 1, 2 * _arg3 + 1, 2 * _arg4 + 1);

}

} // namespace example10
} // namespace testcases
} // namespace v0
