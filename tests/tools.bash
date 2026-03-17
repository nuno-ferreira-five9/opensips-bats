#!/bin/bash

# @param ${1} container name
function start_containers() {
  local CONTAINER_NAME=${1}
  run docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml up \
    --always-recreate-deps --remove-orphans --abort-on-container-exit --exit-code-from ${CONTAINER_NAME} ${CONTAINER_NAME}
}

# @param ${1} container name
function get_container_log() {
  local CONTAINER_NAME=${1}
  docker compose -p ${TESTS_NAMESPACE} -f ${TESTS_DIR}/compose.yml logs ${CONTAINER_NAME} > ${TESTS_RESULTS_DIR}/${TEST_ARTIFACTS}/${CONTAINER_NAME}.log
}


# @param ${1} file name
# @param ${2} number of occurrences to assert (e.g. 0, 1, 2, 3, etc. or 1+ for one or more occurrences)
# @param ${3} pattern
function assert_file_occurrences() {
  local FILENAME=${1}
  local OCCURRENCES=${2}
  shift 2
  local REGEXP=${@}
  local RESULT_MATCHES

  if ! [[ "${OCCURRENCES}" =~ ^[0-9]+\+{0,1}$ ]]; then
    echo "Second parameter for occurrences must be an integer, received \"${OCCURRENCES}\""
    return 1
  fi

  if [[ ! -z "${REGEXP}" && ! -z ${FILENAME} ]]; then
    RESULT_MATCHES=$(egrep -ic "${REGEXP}" ${FILENAME} || true)
    if [[ ${OCCURRENCES} =~ ^[0-9]+$ ]]; then
        if [[ "${RESULT_MATCHES}" != "${OCCURRENCES}" ]]; then
            echo "MATCH result is: ${RESULT_MATCHES} but number of occurrences should be ${OCCURRENCES}"
            return 1
        fi
    elif [[ ${OCCURRENCES} =~ .*\+ ]]; then
        _OCCURRENCES=$(echo ${OCCURRENCES} | sed 's/+//' )
        if [[ ${RESULT_MATCHES} -lt ${_OCCURRENCES} ]]; then
            echo "MATCH result is: ${RESULT_MATCHES} but number of occurrences should be ${OCCURRENCES}"
            return 1
        fi
    fi
  else
    echo "Missing parameters. Received filename: \"${FILENAME}\" pattern: \"${REGEXP}\""
    return 1
  fi
  return 0
}