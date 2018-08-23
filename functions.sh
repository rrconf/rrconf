#
# generic shell functions
#
test ${__rrconf_functions_sh:=no} = yes && return 0
__rrconf_functions_sh=yes

log() {
  echo $* 1>&2
  return 0
}

logv() {
  test ${CAUSEVERBOSE} -ge 1 || return 0
  log $*
}

logvv() {
  test ${CAUSEVERBOSE} -ge 2 || return 0
  log $*
}

logvvv() {
  test ${CAUSEVERBOSE} -ge 3 || return 0
  log $*
}

check.environ() {
  test $# -ge 1 || {
    log "check.environ() expects environment variable names as arguments"
    exit 1
  }

  while test $# -ge 1; do
    local name=$1
    shift
    local check=${!name:-}
    test "${check}" && continue;
    log "Error: required variable '$name' was not set"
    exit 1
  done
}

check.environ.isfile() {
  test $# -ge 1 || {
    log "check.environ.isfile() expects environment variable names as arguments"
    exit 1
  }

  while test $# -ge 1; do
    local name=$1
    shift
    check.environ ${name}
    test -f "${!name}" &&
      test -r "${!name}" &&
        continue;
    log "Error: '$name' should point to a readable file"
    exit 1
  done
}

include() {
  test $# -eq 1 || {
    log 'missing argument to include()'
    return 1
  }
  local file=$1
  test -z "${file}" && {
    log 'zero length argument to include()'
    return 0
  }
  # some versions of readlink don't fail on missing file here
  local incl=$(readlink -e "$file") || true
  test "${incl}" || {
    log "file ${file} to include was not found"
    return 0
  }
  source "${incl}" || {
    log "included file $file returned failure: $?"
    return 0
  }
}

includeq() {
  test $# -eq 1 || {
    log 'missing argument to include()'
    return 1
  }
  local file=$1
  test -z "${file}" && {
    return 0
  }
  # some versions of readlink don't fail on missing file here
  local incl=$(readlink -e "$file") || true
  test "${incl}" || {
    return 0
  }
  source "${incl}" || {
    log "included file $file returned failure: $?"
    return 0
  }
}

tplrender() {
  local tplfile="$1"
  test $# -gt 1 && {
    local tplvars="$(readlink -e $2)" || return 0
    source $tplvars
  }

  local oldifs=$IFS
  IFS=''
  while true; do
    read -r line || {
      true
      break
    }
    while [[ "$line" =~ \$\{([a-zA-Z_][a-zA-Z_0-9]*)\} ]] ; do
      LHS=${BASH_REMATCH[1]}
      RHS=${!LHS:-}
      line=${line//\$\{$LHS\}/$RHS}
    done
    echo "$line"
  done < "$tplfile"
  IFS="$oldifs"
}

return 0
