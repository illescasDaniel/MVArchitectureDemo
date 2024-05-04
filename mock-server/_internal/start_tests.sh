#!/bin/sh

java -jar "_internal/WireMock_3.2.0.jar" --verbose --port 8081 --root-dir="mappings/unit-tests"
