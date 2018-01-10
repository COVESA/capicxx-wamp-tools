/* Copyright (C) 2017 itemis AG
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef ExampleInterfaceSTUBIMPL_H_
#define ExampleInterfaceSTUBIMPL_H_

#include "v0/testcases/example12/ExampleInterfaceStub.hpp"

namespace v0 {
namespace testcases {
namespace example12 {

class ExampleInterfaceStubImpl : public ExampleInterfaceStub {
public:
	ExampleInterfaceStubImpl();
    virtual ~ExampleInterfaceStubImpl();

    virtual RemoteEventHandlerType* initStubAdapter(const std::shared_ptr<StubAdapterType> &_stubAdapter);

    virtual const CommonAPI::Version& getInterfaceVersion(std::shared_ptr<CommonAPI::ClientId> clientId);

    /// This is the method that will be called on remote calls on the method method1
    virtual void method1(const std::shared_ptr<CommonAPI::ClientId> _client, std::string _arg1, method1Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method2
    virtual void method2(const std::shared_ptr<CommonAPI::ClientId> _client, bool _arg1, method2Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method3.
    virtual void method3(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyEnum _arg1, method3Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method4.
    virtual void method4(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyStruct _arg1, method4Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method5.
     virtual void method5(const std::shared_ptr<CommonAPI::ClientId> _client, ExampleInterface::MyArray1 _arg1, method5Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method6.
    virtual void method6(const std::shared_ptr<CommonAPI::ClientId> _client, std::vector<uint64_t> _arg1, method6Reply_t _reply);

    /// This is the method that will be called on remote calls on the method method7.
    virtual void method7(const std::shared_ptr<CommonAPI::ClientId> _client, std::vector< ExampleInterface::MyStruct > _arg1, method7Reply_t _reply);

private:
};

} // namespace example12
} // namespace testcases
} // namespace v0

#endif /* ExampleInterfaceSTUBIMPL_H_ */
