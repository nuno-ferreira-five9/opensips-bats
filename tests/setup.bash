#!/bin/bash

function setup_suite() {
  # Pull latest images
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml pull --ignore-pull-failures
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml build
}

function teardown_suite() {
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml down --remove-orphans --volumes
  docker images -q "${TESTS_NAMESPACE}*" | xargs docker rmi -f
  docker network prune --filter "label=com.docker.compose.project=${TESTS_NAMESPACE}" -f
  return 0
}
