#
# distributed defaults
#
test ${__cause_defaults_sh:=no} = yes && return 0
__cause_defaults_sh=yes

CAUSEDEBUG=${CAUSEDEBUG:=0}
CAUSEVERBOSE=${CAUSEVERBOSE:=0}

SYSDEFDIR=/etc/default
test -f /etc/redhat-release &&
  SYSDEFDIR=/etc/sysconfig

CAUSELIBS=${CAUSELIBS:=${CAUSE}/lib}

return 0
