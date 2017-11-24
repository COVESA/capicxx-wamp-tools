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
    _reply("Hello " + _arg1 + "!");
}

} // namespace example12
} // namespace testcases
} // namespace v0
