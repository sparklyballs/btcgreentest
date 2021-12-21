#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ -n "${TZ}" ]]; then
  echo "Setting timezone to ${TZ}"
  ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone
fi

cd /btcgreen-blockchain || exit 1

# shellcheck disable=SC1091
. ./activate

btcgreen init --fix-ssl-permissions

if [[ ${testnet} == 'true' ]]; then
   echo "configure testnet"
   btcgreen configure --testnet true
fi

if [[ ${keys} == "persistent" ]]; then
  echo "Not touching key directories"
elif [[ ${keys} == "generate" ]]; then
  echo "to use your own keys pass them as a text file -v /path/to/keyfile:/path/in/container and -e keys=\"/path/in/container\""
  btcgreen keys generate
elif [[ ${keys} == "copy" ]]; then
  if [[ -z ${ca} ]]; then
    echo "A path to a copy of the farmer peer's ssl/ca required."
	exit
  else
  btcgreen init -c "${ca}"
  fi
else
  btcgreen keys add -f "${keys}"
fi

for p in ${plots_dir//:/ }; do
    mkdir -p "${p}"
    if [[ ! $(ls -A "$p") ]]; then
        echo "Plots directory '${p}' appears to be empty, try mounting a plot directory with the docker -v command"
    fi
    btcgreen plots add -d "${p}"
done

if [[ -n "${peer_count}" ]]; then
  aedge configure --set-peer-count "${peer_count}"
fi

if [[ -n "${outbound_peer_count}" ]]; then
  aedge configure --set_outbound-peer-count "${outbound_peer_count}"
fi

if [[ -n "${log_level}" ]]; then
  btcgreen configure --log-level "${log_level}"
fi

sed -i 's/localhost/127.0.0.1/g' "$CONFIG_ROOT/config/config.yaml"

exec "$@"
