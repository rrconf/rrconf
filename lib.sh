#
# shellcheck shell=bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2317
#
# common prollogue to be included by any rrconf executable
#
test "${__rrconf_lib_sh:=no}" = yes && return 0
__rrconf_lib_sh=yes

export CDPATH=
export PATH=/sbin:/usr/sbin:/bin:/usr/bin

RRCONF="${RRCONF:=$(dirname "$(readlink -e "${BASH_SOURCE}" )" )}"
export RRCONF

RRUID=$(/usr/bin/id -u)
export RRUID

# sometimes, e.g. rc.local, HOME may not be set:
HOME="${HOME:-$(getent passwd "${RRUID}" | awk -F: '{print $6}')}"
export HOME

test "${RRUID}" -eq 0 || {
  # non-root user has ability to set defaults before system-wide config
  test -r ~/.config/rrconf.conf &&
    source ~/.config/rrconf.conf
}
test -r /etc/rrconf/rrconf.conf &&
  source /etc/rrconf/rrconf.conf

source "${RRCONF}/functions.sh"
source "${RRCONF}/defaults.sh"

export require="${RRCONF}/require"
export replay="${RRCONF}/replay"

export RRCONF_REPOS="${RRCONF_REPOS:=/etc/rrconf/repos.d}"
export RRDEBUG
export RRLOGLEVEL
export RRMODULES

test -d "${RRMODULES}" ||
  mkdir -p "${RRMODULES}"

function __rrconf_cleanup() {
  test "${RRLOGLEVEL}" -gt 2 && {
    echo Cause Trace
    cat "${RRTRACE}"
  }
  test "${RRTRACEMINE}" -eq 1 &&
    rm -f "${RRTRACE}"
}

export RRTRACE=${RRTRACE:=0}
RRTRACEMINE=0
test "${RRTRACE}" = 0 && {
  RRTRACEMINE=1
  RRTRACE="$(mktemp "/tmp/rrconf-$(date +%Y%m%d-%H%M%S)-XXXXXXX")"
  export RRTRACE
  trap __rrconf_cleanup 0 1 2 3 6 15
  echo "${0}" >> "${RRTRACE}"
}

includeq "${SYSDEFDIR}/rrconf"

RRMODPULL=${RRMODPULL:=never}
RRMODDELA=${RRMODDELA:=0}

showhelp() {
  log "$0 <name>"
  exit 2
}

test "${RRTRACEMINE}" -eq 1 && {
  while test $# -ge 1; do
    test "=${1:0:1}" = "=-" || break
    case "=$1" in
    =-xx)
      RRDEBUG=2
      shift
      ;;
    =-x)
      RRDEBUG=1
      shift
      ;;
    =-v)
      RRLOGLEVEL=$(( RRLOGLEVEL + 1 ))
      shift
      ;;
    =-h|=--h*)
      showhelp
      ;;
    *)
      echo "Unknown switch $1"
      showhelp
    esac
  done || true
}

# if this is a top level invocation, need module name argument
test "${RRTRACEMINE}" -eq 1 -a $# -lt 1 && {
  log Missing module name
  showhelp
}

## functions:

# do a git pull on a module
function modpull() {
  local repourl=$1
  test "${RRMODPULL}" = never && return 0
  local localpull="RRMODPULL_${1//-/_}"
  localpull="${localpull//\./_}"
  test "${!localpull:-unset}" = never && return 0
  test "${RRMODDELA}" = TRUE && sleep $(( (RANDOM % 5) + 5 ))s

  logvvv git remote -v

  git pull --quiet --ff-only --rebase
}

# include config files for module
function getconfig() {
  local name=$1

  cd "${RRMODULES}/${name}" || {
    warn "Failed chdir to ${RRMODULES}"
    exit 2
  }
  includeq "$(readlink -e defaults.sh)"
  includeq "$(readlink -e "/etc/rrconf/config-${name}.sh")"
}

function runclone() {
  local repourl=$1
  local name=$2

  test "${RRMODDELA}" = TRUE && sleep $(( (RANDOM % 5) + 5 ))s

  logvv "Trying to clone ${repourl}"

  git clone -q "${repourl}" "${name}" >/dev/null 2>&1
}

# when module is required, but not present - clone it
function getrepo() {
  local name=$1

  cd "${RRMODULES}" || {
    warn "Failed chdir to ${RRMODULES}"
    exit 2
  }
  test -d "${name}" && return 0

  local repodir=${RRCONF_REPOS:=/etc/rrconf/repos.d}
  test -d "${repodir}" || {
    log "Missing directory in \$RRCONF_REPOS (${repodir})"
    exit 99
  }
  for repo in $(run-parts --list "${repodir}"); do
    repourl="$(<"${repo}")${name}.git"
    runclone "${repourl}" "${name}" && {
      logv "Cloned ${repourl}"
      return 0
    }
    logv "Failed to clone ${repourl}"
  done
  log "Missing repository for ${name}"
  return 1
}

function markloaded() {
  echo "require=${1}" >> "${RRTRACE}"
}

function checkloaded() {
  grep -F "require=${1}" >/dev/null 2>&1 "${RRTRACE}"
}

function _replay() {
  local name=$1
  shift

  logvv "Executing module ${name}"

  pushd "${RRMODULES}" >/dev/null || {
    warn "Failed chdir to ${RRMODULES}"
    exit 2
  }
  getrepo "${name}"
  getconfig "${name}"

  export RRMODHOME="${RRMODULES}/${name}"
  cd "${RRMODHOME}" || {
    warn "Failed chdir to ${RRMODHOME}"
    exit 2
  }
  modpull "${name}"

  if test "${RRDEBUG}" -ge 1; then
    bash -x ./main "$@" || {
      log "${name} failed"
      exit 2
    }
  else
    ./main "$@" || {
      log "${name} failed"
      exit 2
    }
  fi

  unset RRMODHOME
  popd >/dev/null || return
}

function _require() {
  local name=$1
  shift

  logvv requiring "${name}"

  checkloaded "${name}" && return 0
  markloaded "${name}" || exit 1
  _replay "${name}" "$@"
}

test "${RRDEBUG:-0}" -ge 2 && set -x
return 0
