#!/bin/sh
#
# Inject a device if and only if the com.example.key1 annotation
# exists with a value of 'value1'.

DEVICE=$(cat <<EOF
{
  "path": "/dev/mydev",
  "type": "c",
  "major": 123,
  "minor": 456,
  "fileMode": 438,
  "uid": 0,
  "gid": 0
}
EOF
)
jq --argjson device "${DEVICE}" 'if .annotations["com.example.key1"] == "value1" then .linux.devices |= . + [$device] else . end'
