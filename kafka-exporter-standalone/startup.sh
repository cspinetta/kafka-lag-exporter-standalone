#!/bin/bash

PROJECT_ROOT="$(dirname $0)"

cd ${PROJECT_ROOT}

function run() {
    docker-compose down
    docker-compose up -d
}

run

cd - > /dev/null
