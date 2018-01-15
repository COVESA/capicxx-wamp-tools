/* Copyright (C) 2018 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef ExampleInterfaceSTUBIMPL_H_
#define ExampleInterfaceSTUBIMPL_H_

#include "v0/testcases/example36/ExampleInterfaceStubDefault.hpp"

namespace v0 {
namespace testcases {
namespace example36 {

class ExampleInterfaceStubImpl : public ExampleInterfaceStubDefault {
public:
	ExampleInterfaceStubImpl();
    virtual ~ExampleInterfaceStubImpl();

//    virtual RemoteEventHandlerType* initStubAdapter(const std::shared_ptr<StubAdapterType> &_stubAdapter);

    virtual const CommonAPI::Version& getInterfaceVersion(std::shared_ptr<CommonAPI::ClientId> clientId);

private:
};

} // namespace example36
} // namespace testcases
} // namespace v0

#endif /* ExampleInterfaceSTUBIMPL_H_ */
