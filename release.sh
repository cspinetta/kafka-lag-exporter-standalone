#!/bin/bash

usage="${0} [version]"
VERSION=$(cat app-version)

function failureExit() {
  message=$1
  echo ${message}
  echo "Usage:"
  echo ${usage}
  exit 1
}

rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'

if [[ ${VERSION} =~ $rx ]]; then
  echo "Releasing Version ${VERSION}"
else
  failureExit "Version not supplied."
fi

# Move to root
cd "$(dirname $0)"
set -e

echo "I'm checking if repository has changes"

if git diff-index --quiet HEAD --; then

    # Create tag
    echo "Creating tag ${VERSION}"

    git tag -a ${VERSION} -m "Testing ${VERSION}"
    git push origin ${VERSION}

    ./package.sh ${VERSION}

    echo "Done."
else
    echo "Project has uncommitted changes! commit them to continue, I'm guessing you don't want to deploy unversioned changes... or do you? D:"
    exit 1
fi

cd - > /dev/null
exit 0
