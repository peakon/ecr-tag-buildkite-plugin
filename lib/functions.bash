#!/usr/bin/env bash

# Reads a list from plugin config into a global result array
# Returns success if values were read
plugin_read_list_into_result() {
  result=()

  for prefix in "$@" ; do
    local i=0
    local parameter="${prefix}_${i}"

    if [[ -n "${!prefix:-}" ]] ; then
      echo "🚨 Plugin received a string for $prefix, expected an array" >&2
      exit 1
    fi

    while [[ -n "${!parameter:-}" ]]; do
      result+=("${!parameter}")
      i=$((i+1))
      parameter="${prefix}_${i}"
    done
  done

  [[ ${#result[@]} -gt 0 ]] || return 1
}

function createTag() {
  local registryId="$1"
  local repositoryName="$2"
  local imageTag="$3"
  local newImageTag
  newImageTag="$(echo -n "$4" | tr -s -c '[:alnum:][\_]' -)"

  local manifest
  local result
  local exit_code

  if [[ -n "${BUILDKITE_PLUGIN_ECR_TAG_AWS_PROFILE:-}" ]]; then
    aws_cli_args=(--profile "$BUILDKITE_PLUGIN_ECR_TAG_AWS_PROFILE")
  else
    aws_cli_args=()
  fi

  # shellcheck disable=SC2068
  manifest=$(aws ${aws_cli_args[@]:-} ecr batch-get-image --registry-id "${registryId}" --repository-name "${repositoryName}" --image-ids imageTag="${imageTag}" --output json | jq --raw-output --join-output '.images[0].imageManifest')
  set +e
  # shellcheck disable=SC2068
  result=$( { aws ${aws_cli_args[@]:-} ecr put-image --registry-id "${registryId}" --repository-name "${repositoryName}" --image-tag "${newImageTag}" --image-manifest "${manifest}"; } 2>&1 )
  exit_code=$?
  set -e
  if [ "${exit_code}" -ne 0 ]; then
    echo "${result}"
    if [ "${exit_code}" -eq 255 ]; then # https://docs.aws.amazon.com/cli/latest/topic/return-codes.html
      if [[ "${result}" =~ .*"ImageAlreadyExistsException".* ]]; then
        echo "Image tag ${newImageTag} already exist. Skipping..."
      fi
    else
      exit "${exit_code}"
    fi
  else
    echo "Successfully retagged image: ${newImageTag}"
  fi
}
