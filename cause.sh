#
# common file to be included by any cause script
#
test ${__cause_cause_sh:=no} = yes && return 0
__cause_cause_sh=yes

CAUSE=${CAUSE:=missing}
test ${CAUSE} = missing &&
  export CASUE=$(readlink -e $BASH_SOURCE)

MYHOMEro=${MYHOME:-missing}
test ${MYHOMEro} = missing &&
  MYHOME=$(dirname $(readlink -e $0) )

# sometimes, e.g. rc.local, HOME may not be set:
HOME=${HOME:-$(getent passwd $(id -u) | awk -F: '{print$6}')}

# associative arrays must declared as a global variable
declare -A CAUSEGITMAP

source "${CAUSE}/functions.sh"
source "${CAUSE}/defaults.sh"

test -d ${CAUSELIBS} ||
  mkdir -p ${CAUSELIBS}

function __cause_cleanup() {
  cat ${CAUSETRACE}
  rm -f ${CAUSETRACE}
}

export CAUSETRACE=${CAUSETRACE:=0}
test ${CAUSETRACE} = 0 && {
  export CAUSETRACE=$(mktemp /tmp/cause-$(date +%Y%m%d-%H%M%S)-XXXXXXX)
  trap __cause_cleanup 0 1 2 3 6 15
  echo $0 >> ${CAUSETRACE}
}

includeq "${SYSDEFDIR}/cause"
includeq "${HOME}/.config/cause.sh"

CAUSEPULL=${CAUSEPULL:=never}

# do a git pull on a module
function causepull() {
  test x${CAUSEPULL} = xnever && return 0
  local localpull="CAUSEPULL_${1//-/_}"
  test x${!localpull:-unset} = xnever && return 0

  git pull --ff-only --rebase
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
  local repo=${CAUSEGITMAP[$name]:-$CAUSEGITBASE-$name}
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

function require() {
  local name=$1

  checkloaded $name && return 0
  markloaded $name || exit 1
  getrepo $name
  getconfig $name
  cd $CAUSELIBS/$name
  causepull $name
  
  ./main || {
    log $name failed
    exit 2
  }
}
                    