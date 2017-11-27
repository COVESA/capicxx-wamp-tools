#!/bin/bash

# NOTE: the first argument (here: 7) is the client id for the communication
#       the second is the actual arguments for the method1() method
#       the return value will be another string, which is the modified input string

curl -H "Content-Type: application/json" \
    -d '{"procedure": "local:testcases.example12.ExampleInterface:v0_7:testcases.example12.ExampleInterface.method1", "args": [7, "foobar"]}' \
    http://127.0.0.1:8080/call

echo
