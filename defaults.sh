# shellcheck shell=bash
#
# distributed defaults
#
test ${__rrconf_defaults_sh:=no} = yes && return 0
__rrconf_defaults_sh=yes

RRDEBUG=${RRDEBUG:=0}
RRLOGLEVEL=${RRLOGLEVEL:=0}

SYSDEFDIR=/etc/default
test -f /etc/redhat-release &&
  SYSDEFDIR=/etc/sysconfig

RRMODULES=${RRMODULES:=${RRCONF}/lib}

return 0
