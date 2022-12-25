#!/bin/bash
test -z "$(type -p)" 2>/dev/null || {
	echo "This code expects to be executed in a pre-installed bash shell."
	exit 1
}

set -eu
set -o pipefail

# sensible defaults:
export RR_REPO="${RR_REPO:=https://github.com/rrconf/rrconf.git}"
export RR_DIR="${RR_DIR:=/opt/rrconf}"
export RR_MODREPOS="${RR_MODREPOS:=https://github.com/rrconf/tutorial-}"

function check_command() {
	local cmd
	cmd="$( type -P "${1}" 2>/dev/null )" || true
	test "${cmd}" = "" && {
		echo "Missing command ${1}"
		exit 1
	}
	echo "$cmd"
}

function main() {

        test $# -ge 1 && test "$1" = "force" && {
                shift
                rm -rf "${RR_DIR}"
        }
        test -d "${RR_DIR}" || {
                ${GIT} clone "${RR_REPO}" "${RR_DIR}"
        }

        if [[ -L /bin/require ]]; then
                local re
                re="$(realpath -e /bin/require)"
                if [[ "${re}" != "${RR_DIR}/require" ]]; then
                        rm -f /bin/require
                        ln -s "${RR_DIR}/require" /bin/require
                fi
        else
                ln -s "${RR_DIR}/require" /bin/require
        fi
        if [[ -L /bin/replay ]]; then
                local re
                re="$(realpath -e /bin/replay)"
                if [[ "${re}" != "${RR_DIR}/replay" ]]; then
                        rm -f /bin/replay
                        ln -s "${RR_DIR}/replay" /bin/replay
                fi
        else
                ln -s "${RR_DIR}/replay" /bin/replay
        fi

        mkdir -p /etc/rrconf/repos.d 2>/dev/null || true
        touch /etc/rrconf/rrconf.conf

        nn=10
        for repo in ${!RR_MODREPO*}; do
                echo "${!repo}" > "/etc/rrconf/repos.d/${nn}-repoconf"
                nn=$((nn+3))
        done

	return 0
}

GIT=$(check_command git)
export GIT

main "$@"
