#
# generic shell functions
#
test ${__cause_functions_sh:=no} = yes && return 0
__cause_functions_sh=yes

log() {
  echo $* 1>&2
  return 0
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
  local incl=$(readlink -e "$file") || {
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
  local incl=$(readlink -e "$file") || {
    return 0
  }
  source "${incl}" || {
    log "included file $file returned failure: $?"
    return 0
  }
}

return 0
