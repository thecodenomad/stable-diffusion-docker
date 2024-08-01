#! /usr/bin/env bash

NIGHTLY="${NIGHTLY:-0}"

ROCM_VERSION="${ROCM_VERSION:-6.1}"
CMD="pip3 download torch torchvision torchaudio --index-url"
URL="https://download.pytorch.org/whl/rocm"

pushd /tmp/pip_cache

# TODO: Remove iGPU when supported in stable
if [[ "${NIGHTLY}" == "1" || "${IGPU}" == "1" ]]; then
  URL="https://download.pytorch.org/whl/nightly/rocm"
fi

echo "Installing rocm ${ROCM_VERSION}"
${CMD} "${URL}${ROCM_VERSION}

popd
