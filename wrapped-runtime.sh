#!/bin/sh
#
# HACK: assumes the runtime respects
# https://github.com/opencontainers/runtime-tools/blob/v0.8.0/docs/command-line-interface.md

RUNTIME="${RUNTIME:-runc}"
FILTER_DIR="${FILTER_DIR:-/etc/containers/oci/config-filters.d}"
COMMAND="${1}"  # HACK: assumes no global options

config_filters()
{
	# HACK: assumes --bundle is unset or set to the current working directory
	CONFIG="$(cat config.json)"
	for FILTER in $(ls "${FILTER_DIR}")
	do
		# HACK: ignores exit code
		CONFIG=$(echo "${CONFIG}" | "${FILTER_DIR}/${FILTER}")
	done
	echo "${CONFIG}" >config.json
}

if test "${COMMAND}" == 'create'
then
	# HACK: ignores exit code
	config_filters
fi
"${RUNTIME}" "${@}"
