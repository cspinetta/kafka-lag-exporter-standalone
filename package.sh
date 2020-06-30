#!/bin/bash

PROJECT_ROOT="$(dirname $0)"

cd ${PROJECT_ROOT}

VERSION="$1"
if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    exit 1
fi

rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'

if [[ ${VERSION} =~ $rx ]]; then
  echo "Packaging Version ${VERSION}"
else
  echo "Version not supplied or invalid. it must match against ${rx}"
  echo "Usage: $0 <version>"
  exit 1
fi

set -e  # Exit immediately if a pipeline returns a non-zero status

mkdir -p target
tar -cvf target/kafka-lag-exporter-standalone-"$VERSION".tar kafka-exporter-standalone/

echo "Done. Package ready at target/kafka-lag-exporter-standalone-"${VERSION}".tar"

cd - > /dev/null
