#! /usr/bin/env bash

NIGHTLY="${NIGHTLY:-0}"
pushd /tmp/pip_cache

if [[ "${NIGHTLY}" == "1" ]]; then
  pip3 download --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1
else
  pip3 download torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1
fi

popd
