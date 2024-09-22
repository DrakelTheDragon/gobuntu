#!/usr/bin/env bash

set -euxo pipefail

feature_dir="$(realpath -e "${BASH_SOURCE[0]%/*}" 2>/dev/null)" || die "Failed to get the feature directory."

# shellcheck source=.devcontainer/local-features/buf/utils.sh
source "${feature_dir}/utils.sh" 2>/dev/null || die "Failed to source utils.sh."

if [ "$(id -u)" -ne 0 ]; then
  die 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
fi

platform="$(get_platform -s "-")" || die "Failed to fetch system platform information."
bin_path="/usr/local"

app_name="buf"
app_repo="bufbuild/${app_name}"
app_rtag="${VERSION:-"latest"}"
if [ "${app_rtag}" = "latest" ]; then
  app_rtag="$(get_latest_github_release_tag "${app_repo}")" || die "Failed to fetch latest release version."
fi

echo "Installing ${app_name}..."
install_github_release_asset "${app_repo}" "${app_rtag}" "${app_name}-${platform}.tar.gz" "${bin_path}" || die "Failed to install ${app_name}."
echo "Installed ${app_name} successfully!"
