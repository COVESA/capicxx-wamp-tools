/*
* This file was generated by the CommonAPI Generators.
* Used org.genivi.commonapi.wamp (standalone).
* Used org.franca.core 0.9.1.201412191134.
*
* This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
* If a copy of the MPL was not distributed with this file, You can obtain one at
* http://mozilla.org/MPL/2.0/.
*/

#include "v0/testcases/example12/ExampleInterface.hpp"
#include "v0/testcases/example12/ExampleInterfaceWampStubAdapter.hpp"
#include "v0/testcases/example12/ExampleInterfaceWampStructsSupport.hpp"

#include <functional>

namespace v0 {
namespace testcases {
namespace example12 {

std::shared_ptr<CommonAPI::Wamp::WampStubAdapter> createExampleInterfaceWampStubAdapter(
						const CommonAPI::Wamp::WampAddress &_address,
						const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection,
						const std::shared_ptr<CommonAPI::StubBase> &_stub) {
	std::cout << "createExampleInterfaceWampStubAdapter called" << std::endl;
	return std::make_shared<ExampleInterfaceWampStubAdapter>(_address, _connection, _stub);
}

INITIALIZER(registerExampleInterfaceWampStubAdapter) {
	CommonAPI::Wamp::Factory::get()->registerStubAdapterCreateMethod(
		ExampleInterface::getInterface(), &createExampleInterfaceWampStubAdapter);
	std::cout << "registerStubAdapterCreateMethod(createExampleInterfaceWampStubAdapter)" << std::endl;
}

ExampleInterfaceWampStubAdapterInternal::~ExampleInterfaceWampStubAdapterInternal() {
	deactivateManagedInstances();
	ExampleInterfaceWampStubAdapterHelper::deinit();
}

void ExampleInterfaceWampStubAdapterInternal::deactivateManagedInstances() {

}

CommonAPI::Wamp::WampGetAttributeStubDispatcher<
	::v0::testcases::example12::ExampleInterfaceStub,
	CommonAPI::Version
> ExampleInterfaceWampStubAdapterInternal::getExampleInterfaceInterfaceVersionStubDispatcher(&ExampleInterfaceStub::getInterfaceVersion, "uu");


const ExampleInterfaceWampStubAdapterHelper::StubDispatcherTable& ExampleInterfaceWampStubAdapterInternal::getStubDispatcherTable() {
	return stubDispatcherTable_;
}

const CommonAPI::Wamp::StubAttributeTable& ExampleInterfaceWampStubAdapterInternal::getStubAttributeTable() {
	return stubAttributeTable_;
}

ExampleInterfaceWampStubAdapterInternal::ExampleInterfaceWampStubAdapterInternal(
		const CommonAPI::Wamp::WampAddress &_address,
		const std::shared_ptr<CommonAPI::Wamp::WampProxyConnection> &_connection,
		const std::shared_ptr<CommonAPI::StubBase> &_stub)
	: CommonAPI::Wamp::WampStubAdapter(_address, _connection, false),
	  ExampleInterfaceWampStubAdapterHelper(_address, _connection, std::dynamic_pointer_cast<ExampleInterfaceStub>(_stub), false),
	  stubDispatcherTable_({ /* TODO: is stubDispatcherTable needed at all? */ }),
		stubAttributeTable_() {
	std::cout << "ExampleInterfaceWampStubAdapterInternal constructor called" << std::endl;
	stubDispatcherTable_.insert({ { "getInterfaceVersion", "" }, &/*namespace::*/ExampleInterfaceWampStubAdapterInternal::getExampleInterfaceInterfaceVersionStubDispatcher });
}


//////////////////////////////////////////////////////////////////////////////////////////

void ExampleInterfaceWampStubAdapterInternal::provideRemoteMethods() {
	std::cout << "provideRemoteMethods called" << std::endl;

	CommonAPI::Wamp::WampMethodWithReplyStubDispatcher<ExampleInterfaceWampStubAdapterInternal>
		::provideRemoteMethod(*this,
			"method1", &ExampleInterfaceWampStubAdapterInternal::wrap_method1);
	CommonAPI::Wamp::WampMethodWithReplyStubDispatcher<ExampleInterfaceWampStubAdapterInternal>
		::provideRemoteMethod(*this,
			"method2", &ExampleInterfaceWampStubAdapterInternal::wrap_method2);
	CommonAPI::Wamp::WampMethodWithReplyStubDispatcher<ExampleInterfaceWampStubAdapterInternal>
		::provideRemoteMethod(*this,
			"method3", &ExampleInterfaceWampStubAdapterInternal::wrap_method3);
}

void ExampleInterfaceWampStubAdapterInternal::wrap_method1(autobahn::wamp_invocation invocation) {
	std::cout << "ExampleInterfaceWampStubAdapterInternal::wrap_method1 called" << std::endl;
	auto clientNumber = invocation->argument<uint32_t>(0);
	auto arg1 = invocation->argument<std::string>(1);
	std::cerr << "Procedure " << getWampAddress().getRealm() << ".method1 invoked (clientNumber=" << clientNumber << ") " << "arg1=" << arg1 << std::endl;
	std::shared_ptr<CommonAPI::Wamp::WampClientId> clientId = std::make_shared<CommonAPI::Wamp::WampClientId>(clientNumber);
	std::string ret1;
	stub_->method1(
		clientId, arg1
		, [&](std::string _ret1) {
			ret1=_ret1; 
		}
	);
	invocation->result(std::make_tuple(ret1));
}

void ExampleInterfaceWampStubAdapterInternal::wrap_method2(autobahn::wamp_invocation invocation) {
	std::cout << "ExampleInterfaceWampStubAdapterInternal::wrap_method2 called" << std::endl;
	auto clientNumber = invocation->argument<uint32_t>(0);
	auto arg1 = invocation->argument<bool>(1);
	std::cerr << "Procedure " << getWampAddress().getRealm() << ".method2 invoked (clientNumber=" << clientNumber << ") " << "arg1=" << arg1 << std::endl;
	std::shared_ptr<CommonAPI::Wamp::WampClientId> clientId = std::make_shared<CommonAPI::Wamp::WampClientId>(clientNumber);
	bool ret1;
	stub_->method2(
		clientId, arg1
		, [&](bool _ret1) {
			ret1=_ret1; 
		}
	);
	invocation->result(std::make_tuple(ret1));
}

void ExampleInterfaceWampStubAdapterInternal::wrap_method3(autobahn::wamp_invocation invocation) {
	std::cout << "ExampleInterfaceWampStubAdapterInternal::wrap_method3 called" << std::endl;
	auto clientNumber = invocation->argument<uint32_t>(0);
	auto arg1 = invocation->argument<uint32_t>(1);
	std::cerr << "Procedure " << getWampAddress().getRealm() << ".method3 invoked (clientNumber=" << clientNumber << ") " << "arg1=" << arg1 << std::endl;
	std::shared_ptr<CommonAPI::Wamp::WampClientId> clientId = std::make_shared<CommonAPI::Wamp::WampClientId>(clientNumber);
	uint32_t ret1;
	ExampleInterface::MyEnum __arg1;
	__arg1.value_ = arg1; 
	stub_->method3(
		clientId, __arg1
		, [&](ExampleInterface::MyEnum _ret1) {
			ret1=_ret1.value_; 
		}
	);
	invocation->result(std::make_tuple(ret1));
}


} // namespace example12
} // namespace testcases
} // namespace v0
