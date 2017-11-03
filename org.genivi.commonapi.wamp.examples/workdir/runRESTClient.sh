#!/bin/bash

# NOTE: the first argument (here: 7) is the client id for the communication
#       the second and third argument are the actual arguments for the add2() method
#       the return value will be another struct containing the sum and the difference of the add2 arguments

curl -H "Content-Type: application/json" \
    -d '{"procedure": "local:testcases.example77.ExampleInterface:v0_7:testcases.example77.ExampleInterface.add2", "args": [7, 33, 22]}' \
    http://127.0.0.1:8080/call

echo
