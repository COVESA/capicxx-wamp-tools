/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "ExampleInterfaceStubImpl.hpp"

namespace v0 {
namespace testcases {
namespace example10 {

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

void ExampleInterfaceStubImpl::method1(const std::shared_ptr<CommonAPI::ClientId> _client, int64_t _arg1, method1Reply_t _reply) {
    std::cout << "ExampleInterfaceStubImpl::method1 called" << std::endl;

    // provide response
    _reply(_arg1 * 2);
}

void ExampleInterfaceStubImpl::methodWithError1(const std::shared_ptr<CommonAPI::ClientId> _client, int64_t _arg1, methodWithError1Reply_t _reply) {
    std::cout << "ExampleInterfaceStubImpl::methodWithError1 called" << std::endl;

    // return an error if _arg1>9 (used for testing)
	ExampleInterface::methodWithError1Error error;
    if (_arg1>9) {
    	error = ExampleInterface::methodWithError1Error::Literal::ERROR1;
        _reply(error, 0);
    } else {
    	error = ExampleInterface::methodWithError1Error::Literal::OK;
        _reply(error, _arg1*10);
    }
}

} // namespace example10
} // namespace testcases
} // namespace v0
