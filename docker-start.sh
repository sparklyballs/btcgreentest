#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ ${farmer} == 'true' ]]; then
  btcgreen start farmer-only
elif [[ ${harvester} == 'true' ]]; then
  if [[ -z ${farmer_address} || -z ${farmer_port} || -z ${ca} ]]; then
    echo "A farmer peer address, port, and ca path are required."
    exit
  else
    btcgreen configure --set-farmer-peer "${farmer_address}:${farmer_port}"
    btcgreen start harvester
  fi
else
  btcgreen start farmer
fi

# Ensures the log file actually exists, so we can tail successfully
touch "$CONFIG_ROOT/log/debug.log"
tail -f "$CONFIG_ROOT/log/debug.log"
