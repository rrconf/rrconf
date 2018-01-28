#
# common prollogue to be included by any cause script
#
test ${__cause_lib_sh:=no} = yes && return 0
__cause_lib_sh=yes

# associative arrays must declared as a global variable
declare -A CAUSEGITMAP

export CAUSE=$(readlink -e ${CAUSE})

# sometimes, e.g. rc.local, HOME may not be set:
export HOME="${HOME:-$(getent passwd $(id -u) | awk -F: '{print $6}')}"

source "${CAUSE}/functions.sh"
source "${CAUSE}/defaults.sh"

export CAUSEDEBUG
export CAUSEVERBOSE

test -d ${CAUSELIBS} ||
  mkdir -p ${CAUSELIBS}

function __cause_cleanup() {
  test ${CAUSEVERBOSE} -gt 2 && {
    echo Cause Trace
    cat ${CAUSETRACE}
  }
  test ${CAUSETRACEMINE} -eq 1 &&
    rm -f ${CAUSETRACE}
}

export CAUSETRACE=${CAUSETRACE:=0}
CAUSETRACEMINE=0
test ${CAUSETRACE} = 0 && {
  CAUSETRACEMINE=1
  export CAUSETRACE=$(mktemp /tmp/cause-$(date +%Y%m%d-%H%M%S)-XXXXXXX)
  trap __cause_cleanup 0 1 2 3 6 15
  echo $0 >> ${CAUSETRACE}
}

includeq "${SYSDEFDIR}/cause"

CAUSEPULL=${CAUSEPULL:=never}

showhelp() {
  log "$0 <name>"
  exit 2
}

test $# -lt 1 &&
  showhelp

while test $# -ge 1; do
  test "=${1:0:1}" = "=-" || break
  case "=$1" in
  =-x)
    CAUSEDEBUG=1
    shift
    ;;
  =-v)
    CAUSEVERBOSE=$(( ${CAUSEVERBOSE}+1 ))
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

test $# -ge 1 || {
  echo Missing module name
  showhelp
}


## functions:

# do a git pull on a module
function causepull() {
  test x${CAUSEPULL} = xnever && return 0
  local localpull="CAUSEPULL_${1//-/_}"
  test x${!localpull:-unset} = xnever && return 0

  git pull --ff-only --rebase
}

# find the repo
findrepo() {
  local name=$1

}

# include config files for module
function getconfig() {
  local name=$1

  cd $CAUSELIBS/$name
  includeq "$(readlink -e defaults.sh)"
  includeq "$(readlink -e /etc/cause/config-$name.sh)"
}

# when module is required, but not present - clone it
function getrepo() {
  local name=$1

  cd $CAUSELIBS
  test -d $name && return 0
  local repo=${CAUSEGITMAP[$name]:-${CAUSEGITBASE}$name}
  logv cloning $repo to $name
  git clone -q $repo $name
}

function markloaded() {
  local name=$1

  echo "require=$name" >> ${CAUSETRACE}
}

function checkloaded() {
  local name=$1

  grep -F "require=$name" >/dev/null 2>&1 ${CAUSETRACE}
}

function replay() {
  local name=$1

  logvv replaying $name

  pushd $CAUSELIBS
  getrepo $name
  getconfig $name

  cd $CAUSELIBS/$name
  causepull $name

  ./main || {
    log $name failed
    exit 2
  }
  popd
}

function _require() {
  local name=$1

  logvv requiring $name

  checkloaded $name && return 0
  markloaded $name || exit 1

  pushd $CAUSELIBS
  getrepo $name
  getconfig $name

  cd $CAUSELIBS/$name
  causepull $name

  ./main || {
    log $name failed
    exit 2
  }
  popd
}

test "${CAUSEDEBUG:-0}" -gt 0 && set -x
return 0
