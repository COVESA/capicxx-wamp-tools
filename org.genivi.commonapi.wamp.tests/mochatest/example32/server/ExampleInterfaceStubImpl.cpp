/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "ExampleInterfaceStubImpl.hpp"

namespace v0 {
namespace testcases {
namespace example32 {

ExampleInterfaceStubImpl::ExampleInterfaceStubImpl() : ExampleInterfaceStubDefault() {
	std::cout << "ExampleInterfaceStubImpl constructor called" << std::endl;
}

ExampleInterfaceStubImpl::~ExampleInterfaceStubImpl() {
}

/*
ExampleInterfaceStubImpl::RemoteEventHandlerType* ExampleInterfaceStubImpl::initStubAdapter(const std::shared_ptr<ExampleInterfaceStubImpl::StubAdapterType> &_stubAdapter) {
	return nullptr;
}
*/

static const CommonAPI::Version version(0, 0);

const CommonAPI::Version& ExampleInterfaceStubImpl::getInterfaceVersion(std::shared_ptr<CommonAPI::ClientId> clientId) {
	return version;
}

} // namespace example32
} // namespace testcases
} // namespace v0
