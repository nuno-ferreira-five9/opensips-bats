#!/usr/bin/env bats
load "$REPOSITORY_ROOT/tests/libs/bats-support/load"
load "$REPOSITORY_ROOT/tests/libs/bats-assert/load"
load "$REPOSITORY_ROOT/tests/tools"

function setup() {
  TEST_NAME=$(basename $BATS_TEST_FILENAME ".bats")
  TEST_ID=$(printf "%03d" $BATS_TEST_NUMBER)
  TEST_NAME_ID=$(tr " " "_" <<< $BATS_TEST_DESCRIPTION)
  export TEST_ARTIFACTS=${TEST_NAME}/${TEST_NAME_ID}
  export TESTS_NAMESPACE="${TESTS_NAMESPACE}-${TEST_ID}"
}

function teardown() {
  echo "Tearing down test environment for ${TEST_NAME_ID}"
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml down --remove-orphans --volumes 2>/dev/null || true
}

# bats file_tags=sip

# bats test_tags=000
@test "000 - bats version" {
  bats_require_minimum_version "1.13.0"
}

# bats test_tags=000
@test "000 - docker is installed" {
  run command -v docker
  assert_success
}

# bats test_tags=000
@test "000 - docker compose is available" {
  run docker compose version
  assert_success
  assert_output --partial 'Docker Compose'
}

# bats test_tags=000
@test "000 - check opensips version" {
  run docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml run --rm opensips01 opensips -V
  assert_success
  assert_output --partial 'opensips 4.1.0-dev' 
}

# bats test_tags=001
@test "001 - UAC can successfully make a call through OpenSIPS to UAS" {
  run docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml up \
    --always-recreate-deps --remove-orphans --abort-on-container-exit --exit-code-from uac01 uac01
  assert_success

  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml logs opensips01 > ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/opensips01.log
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml logs uac01 > ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/uac01.log
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml logs uas01 > ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/uas01.log

  # check for expected log lines in opensips logs
  run grep -E "transaction answered:.*;method=INVITE" ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/opensips01.log
  assert_success
  run grep -E "Successful call.*\|.*0.*\|.*1" ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/uac01.log
  assert_success
}

# bats test_tags=002
@test "002 - UAC can successfully make a call through OpenSIPS to UAS" {
  start_containers uac01
  assert_success

  get_container_log opensips01
  get_container_log uac01
  get_container_log uas01

  # check for expected log lines in opensips logs
  assert_file_occurrences ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/opensips01.log 1 "transaction answered:.*;method=INVITE"
  assert_file_occurrences ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/uac01.log 1+ "Successful call.*\|.*0.*\|.*1"
}
