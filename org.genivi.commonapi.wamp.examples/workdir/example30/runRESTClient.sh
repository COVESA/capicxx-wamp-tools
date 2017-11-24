#!/bin/bash

# NOTE: the first argument (here: 7) is the client id for the communication
#       the second and third argument are the actual arguments for the add2() method
#       the return value will be another struct containing the sum and the difference of the add2 arguments

# TODO: this is not yet correct! Clarify how broadcasts will look like in REST.
curl -H "Content-Type: application/json" \
    -d '{"procedure": "local:testcases.example30.ExampleInterface:v0_7:testcases.example30.ExampleInterface.method1", "args": [7, 33]}' \
    http://127.0.0.1:8080/call

echo
