#!/bin/bash
set -eu -o pipefail

RUN_SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
export REPOSITORY_ROOT=$(dirname $RUN_SCRIPT_DIR)
export TESTS_DIR=${TESTS_DIR:-"${REPOSITORY_ROOT}/tests"}
export TESTS_RESULTS_DIR=${TESTS_RESULTS_DIR:-"${REPOSITORY_ROOT}/tests/results"}

TESTS_NAMESPACE=${TESTS_NAMESPACE:-"$(basename $REPOSITORY_ROOT)"}
export TESTS_NAMESPACE="${TESTS_NAMESPACE}_${$}"

rm -rf ${TESTS_RESULTS_DIR}
mkdir -p ${TESTS_RESULTS_DIR}

pushd $REPOSITORY_ROOT

#tests/libs/bats/bin/bats --timing --verbose-run --show-output-of-passing-tests \
tests/libs/bats/bin/bats --timing \
    --setup-suite-file ${TESTS_DIR}/setup.bash \
    --formatter pretty --report-formatter junit --output ${TESTS_RESULTS_DIR} \
    "$@" \
    ${TESTS_DIR}/*.bats

popd