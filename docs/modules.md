# Modules

Modules for RRconf are stored in git repos. The only requirement for repository to be usable as module is that it contains exaecutable file called `main` in root of the repo working tree, in default branch.

Typicaly this is a `bash` script, but using shee-bang lets you use any interpreted language. The executable bits can be also used on compiled binaries, but RRconf makes no checks on architecture compatibility (patches welcomed, just try exec `main.armhf` if it exists, fallback to `main`).

If the module is already installed, RRconf pulls new changes if `RRMODPULL` is `true`, otherwise it will use existing copy of module, regardles of upstream changes.

If the module is not yet installed, the full path to repository is composed from files in the repository search path (which defaults to `/etc/rrconf/repos.d/*`) and the name of module located on command line. The first line of files in repository search path is prepended to the module name:

```
# cat /etc/rrconf/repos.d/33-corporate
ssh://git.corp/modules/
#
# cat /etc/rrconf/repos.d/88-github
https://github.com/rrconf/mod-
#
```
Note that trailing slash is important. Repository files are sorted alphabetically, so the same module name can present in more repositories, but only the first match is used by RRconf.

----
[INDEX](./readme.md)
