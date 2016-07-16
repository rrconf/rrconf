#
# distributed defaults
#
test ${__cause_defaults_sh:=no} = yes && return 0
__cause_defaults_sh=yes

SYSDEFDIR=/etc/default

test -f /etc/redhat-release &&
  SYSDEFDIR=/etc/sysconfig

# MYHOME is set to a library home so use CAUSE location for libs by default
CAUSELIBS=${CAUSE}/lib
CAUSEGITBASE=github.com:cause/cause

return 0
