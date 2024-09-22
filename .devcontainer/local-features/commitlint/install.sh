#!/usr/bin/env bash

set -euxo pipefail

feature_dir="$(realpath -e "${BASH_SOURCE[0]%/*}" 2>/dev/null)" || die "Failed to get the feature directory."

# shellcheck source=.devcontainer/local-features/buf/utils.sh
source "${feature_dir}/utils.sh" 2>/dev/null || die "Failed to source utils.sh."

if [ "$(id -u)" -ne 0 ]; then
    die 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
fi

app_name="commitlint"

echo "Installing ${app_name}..."
npm install --global "@${app_name}"/{cli,config-conventional,"cz-${app_name}"} || die "Failed to install ${app_name}."
echo "Installed ${app_name} successfully!"

app_name="commitizen"

echo "Installing ${app_name}..."
npm install --global ${app_name} || die "Failed to install ${app_name}."
echo "Installed ${app_name} successfully!"
