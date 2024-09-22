#!/usr/bin/env bash

set -euxo pipefail

if ! feature_dir="$(realpath -e "${BASH_SOURCE[0]%/*}" 2>/dev/null)"; then
    die "Failed to get the feature directory."
fi

# shellcheck source=.devcontainer/local-features/direnv/utils.sh
if ! source "${feature_dir}/utils.sh"; then
    die "Failed to source utils.sh."
fi

if [ -z "${_REMOTE_USER_HOME}" ]; then
    die "Failed to get remote user home directory."
fi

if [ "$(id -u)" -ne 0 ]; then
    die 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
fi

app_name="direnv"

echo "Installing ${app_name}..."

export bin_path="/usr/local/bin"

curl -sfL "https://${app_name}.net/install.sh" | bash || die "Failed to install ${app_name}."
chmod +x "${bin_path}/${app_name}" &>/dev/null || die "Failed to make ${app_name} executable."

add_hook "${app_name}" "bash" "${_REMOTE_USER_HOME}" || die "Failed to add ${app_name} hook to .bashrc."
add_hook "${app_name}" "zsh" "${_REMOTE_USER_HOME}" || die "Failed to add ${app_name} hook to .zshrc."

echo "Installed ${app_name} successfully!"
