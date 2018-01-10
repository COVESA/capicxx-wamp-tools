/*
* This file was generated by the CommonAPI Generators.
* Used org.genivi.commonapi.wamp (standalone).
* Used org.franca.core 0.9.1.201412191134.
*
* This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
* If a copy of the MPL was not distributed with this file, You can obtain one at
* http://mozilla.org/MPL/2.0/.
*/
#ifndef V0_TESTCASES_EXAMPLE12_Example_Interface_WAMP_STRUCTS_SUPPORT_HPP_
#define V0_TESTCASES_EXAMPLE12_Example_Interface_WAMP_STRUCTS_SUPPORT_HPP_

#include <v0/testcases/example12/ExampleInterface.hpp>
#include <msgpack.hpp>

namespace msgpack {
MSGPACK_API_VERSION_NAMESPACE(MSGPACK_DEFAULT_API_NS) {
namespace adaptor {

template<>
struct convert<::v0::testcases::example12::ExampleInterface::MyEnum> {
	msgpack::object const& operator()(msgpack::object const& o, ::v0::testcases::example12::ExampleInterface::MyEnum& v) const {
		if (o.type != msgpack::type::POSITIVE_INTEGER) throw msgpack::type_error();
		v.value_ = o.as<uint32_t>();
		return o;
	}
};

template<>
struct object_with_zone<::v0::testcases::example12::ExampleInterface::MyEnum> {
	void operator()(msgpack::object::with_zone& o, ::v0::testcases::example12::ExampleInterface::MyEnum const& v) const {
		msgpack::operator<<(o, v.value_);
	}
};

template<>
struct convert<::v0::testcases::example12::ExampleInterface::MyStruct1> {
	msgpack::object const& operator()(msgpack::object const& o, ::v0::testcases::example12::ExampleInterface::MyStruct1& v) const {
		if (o.type != msgpack::type::ARRAY) throw msgpack::type_error();
		if (o.via.array.size != 2) throw msgpack::type_error();
		v = ::v0::testcases::example12::ExampleInterface::MyStruct1 (
			o.via.array.ptr[0].as<uint32_t>(),
			o.via.array.ptr[1].as<bool>()
        );
		return o;
	}
};

template<>
struct object_with_zone<::v0::testcases::example12::ExampleInterface::MyStruct1> {
	void operator()(msgpack::object::with_zone& o, ::v0::testcases::example12::ExampleInterface::MyStruct1 const& v) const {
		o.type = type::ARRAY;
		o.via.array.size = 2;
		o.via.array.ptr = static_cast<msgpack::object*>(
		o.zone.allocate_align(sizeof(msgpack::object) * o.via.array.size));
		o.via.array.ptr[0] = msgpack::object(v.getElem1(), o.zone);
		o.via.array.ptr[1] = msgpack::object(v.getElem2(), o.zone);
	}
};

template<>
struct convert<::v0::testcases::example12::ExampleInterface::MyStruct2> {
	msgpack::object const& operator()(msgpack::object const& o, ::v0::testcases::example12::ExampleInterface::MyStruct2& v) const {
		if (o.type != msgpack::type::ARRAY) throw msgpack::type_error();
		if (o.via.array.size != 2) throw msgpack::type_error();
		v = ::v0::testcases::example12::ExampleInterface::MyStruct2 (
			o.via.array.ptr[0].as<::v0::testcases::example12::ExampleInterface::MyEnum>(),
			o.via.array.ptr[1].as<::v0::testcases::example12::ExampleInterface::MyEnum>()
        );
		return o;
	}
};

template<>
struct object_with_zone<::v0::testcases::example12::ExampleInterface::MyStruct2> {
	void operator()(msgpack::object::with_zone& o, ::v0::testcases::example12::ExampleInterface::MyStruct2 const& v) const {
		o.type = type::ARRAY;
		o.via.array.size = 2;
		o.via.array.ptr = static_cast<msgpack::object*>(
		o.zone.allocate_align(sizeof(msgpack::object) * o.via.array.size));
		o.via.array.ptr[0] = msgpack::object(v.getElem1(), o.zone);
		o.via.array.ptr[1] = msgpack::object(v.getElem2(), o.zone);
	}
};

} // namespace adaptor
} // MSGPACK_API_VERSION_NAMESPACE(MSGPACK_DEFAULT_API_NS)
} // namespace msgpack

#endif // V0_TESTCASES_EXAMPLE12_Example_Interface_WAMP_STRUCTS_SUPPORT_HPP_

