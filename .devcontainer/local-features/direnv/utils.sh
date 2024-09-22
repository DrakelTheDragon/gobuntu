# shellcheck shell=bash

die() {
    local exit_code="${?:-1}"
    local message="${1}"
    echo "Error: ${message}" >&2 && exit "${exit_code}"
}

get_platform() {
    local platform
    local separator

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        -l | --lowercase) declare -l platform ;;
        -s | --separator)
            if [[ "$1" == --separator=* ]]; then
                separator="${1#*=}"
            else
                [[ -z "$2" || "$2" =~ ^- && "$2" != "-" ]] && return 1
                separator="$2"
                shift
            fi
            ;;
        esac
        shift
    done

    if ! platform="$(uname -sm 2>/dev/null)"; then
        return 1
    fi

    if [[ -n "${separator}" ]]; then
        platform="${platform// /${separator}}"
    fi

    echo "${platform}"
}

get_latest_github_release_tag() {
    local repo="$1"

    if [[ -z "${repo}" ]]; then
        return 1
    fi

    curl -fsL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name' 2>/dev/null || return "$?"
}

install_github_release_asset() {
    if [[ "$#" -lt 4 ]]; then
        return 1
    fi

    local repo="$1"
    local tag="$2"
    local asset="$3"
    local path="$4"
    local url="https://github.com/${repo}/releases/download/${tag}/${asset}"
    local opts=(-C "${path}" --strip-components=1 --exclude={'"*.md"','"*.txt"','"LICENSE"','"README"'})

    case "${asset}" in
    *.tar.xz) curl -fsSL "${url}" | tar -xJ "${opts[@]}" 2>/dev/null || return "$?" ;;
    *.tar.gz) curl -fsSL "${url}" | tar -xz "${opts[@]}" 2>/dev/null || return "$?" ;;
    *.tar*) curl -fsSL "${url}" | tar -x "${opts[@]}" 2>/dev/null || return "$?" ;;
    *) curl -fsSL "${url}" -o "${path}/${asset%%[^a-zA-Z]*}" 2>/dev/null || return "$?" ;;
    esac
}

file_contains_line_with() {
    local file="$1"
    local pattern="$2"
    grep -qF "${pattern}" "${file}" 2>/dev/null || return 1
}

add_hook() {
    if [[ "$#" -lt 3 ]]; then
        return 1
    fi

    local shell_comm="${1}"
    local shell_type="${2}"
    local shell_home="${3}"
    local shell_file="${shell_home}/.${shell_type}rc"
    local shell_hook="${shell_comm} hook ${shell_type}"

    if [ -f "${shell_file}" ]; then
        if [ "${shell_type}" = "zsh" ] && [ -d "${shell_home}/.oh-my-zsh" ]; then
            if ! file_contains_line_with "${shell_file}" "plugins\+?=\((?:\w* ?)*\b${shell_comm}\b(?: ?\w*)*\)"; then
                printf "plugins+=(%s)\n" "${shell_comm}" >>"${shell_file}" || return 1
            fi
        fi

        if ! file_contains_line_with "${shell_file}" "${shell_hook}"; then
            # shellcheck disable=SC2016
            printf 'eval "$(%s)"\n' "${shell_hook}" >>"${shell_file}" || return 1
        fi
    fi

}
