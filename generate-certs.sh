#!/bin/bash
set -eu

SCRIPT_DIR=$(dirname "$0")

export CA_DIR=ca
export SERVER_DIR=server

${SCRIPT_DIR}/generate-ca-cert.sh
${SCRIPT_DIR}/generate-server-cert.sh
