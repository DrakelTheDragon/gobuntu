#!/usr/bin/env bash

set -euxo pipefail

feature_dir="$(realpath -e "${BASH_SOURCE[0]%/*}" 2>/dev/null)" || die "Failed to get the feature directory."

# shellcheck source=.devcontainer/local-features/bash-ide/utils.sh
source "${feature_dir}/utils.sh" 2>/dev/null || die "Failed to source utils.sh."

if [ "$(id -u)" -ne 0 ]; then
  die 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
fi

platform="$(get_platform -l -s ".")" || die "Failed to get platform."
bin_path="/usr/local/bin"

app_name="shellcheck"
app_repo="koalaman/${app_name}"
app_rtag="${SHELLCHECKVERSION:-"latest"}"
if [ "${app_rtag}" = "latest" ]; then
  app_rtag="$(get_latest_github_release_tag "${app_repo}")" || die "Failed to fetch latest release version."
fi

echo "Installing ${app_name}..."
install_github_release_asset "${app_repo}" "${app_rtag}" "${app_name}-${app_rtag}.${platform}.tar.xz" "${bin_path}" || die "Failed to install ${app_name}."
echo "Installed ${app_name} successfully!"

app_name="shfmt"
app_repo="mvdan/sh"
app_rtag="${SHFMTVERSION:-"latest"}"
if [ "${app_rtag}" = "latest" ]; then
  app_rtag="$(get_latest_github_release_tag "${app_repo}")" || die "Failed to fetch latest release version."
fi

echo "Installing ${app_name}..."
install_github_release_asset "${app_repo}" "${app_rtag}" "${app_name}_${app_rtag}_${platform//.x86_64/_amd64}" "${bin_path}" || die "Failed to install ${app_name}."
echo "Installed ${app_name} successfully!"
