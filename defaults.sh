#
# distributed defaults
#
test ${__cause_defaults_sh:=no} = yes && return 0
__cause_defaults_sh=yes

SYSDEFDIR=/etc/default

test -f /etc/redhat-release &&
  SYSDEFDIR=/etc/sysconfig

CAUSELIBS=${MYHOME}/lib
CAUSEGITBASE=github.com:cause/cause

return 0
