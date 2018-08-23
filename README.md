rrconf: require/replay configuration
====================================

Simple configuration management
-------------------------------

The `require` and `replay` take one argument, and its a name of your or any common module written by others. The modules can use `require` and `replay` at will, recursively. This lets you write (or use any existing) deployment or configuration management scripts. Its also possible to run it from `cron` every day, or every couple of minutes to ensure consistent state of the system. It can be used by system administrator or an ordinary unprivileged user.

`RRCONF` tries to build on shoulders of giants, but stay KISS: reuse existing technologies, but not to invent any domain specific language, or enforce use of any specific programming languages or tools. Individual modules are plain executable files.

Both `require` and `replay` take one argument, and thats a name of a module to run. Before the module is run, it must be installed. This is done by cloning via git from configured git server. e.g.:

```
$ require info
```

This will first clone module [info](https://gitbub.com/rrconf/info.git) and run the executable `main` in the source tree:

```
$ require info
fqdn:workbook.local
hostname:workbook
machine-id:d28679839dfe422d8274201f6f97c50d
$
```

Documentation
-------------

There are about 350 lines of shell code, properly commented (improvements welcomed), including empty lines. There is even a template rendering system included.

Software which needs documentation is unnecessarily complex. Installation is simple, and more info will be written on demand or accepted as pull request.

### Installation

Steps for unprivileged user are documented here. System-wide installation is left as an exercise with the hint that `/opt/rrconf` is my own default system-wide directory, but you can pick your choice freely.

Clone the code:

```
$ git clone https://github.com/rrconf/rrconf ~/rrconf
```

Initial configuration is read from `/etc/rrconf.conf` or `/etc/rrconf/rrconf.conf`, later being preferred alternative. This is followed without complaints by reading `~/.rrconf`. As an ordinary user you do have to change some defaults:

```
RRCONF=/home/username/rrconf
RRCONF_REPOS=/home/username/repos.d
```

Last step is to create at least one repo file. The content of the file is partial name of the repository strings to try to clone modules. There can be multiple files and their names are enumerated and sorted by `run-parts`, so default backup files or package installer files are excluded.

```
mkdir /home/username/repos.d
echo 'https://github.com/rrconf/mod-' > /home/username/repos.d/99-last-resort
```

Then you can run

```
$ ~/rrconf/require info
```

Please note that trailing dash is important, and if it is slash, is **mandatory** and not stripped. Then you can store repositories for module in a project sub-group and share module and repository names. You can still use `ssh://gitlab:2222/username/group/module-` and your own info module can have repository base name `module-info.git`.

To name your repository files you should understand your `run-parts` and its sorting. Your repository files should follow convention that your private controlled repositories are the first in the list. There is no default or blacklist implemented, you need at least one repo file.

### Contributing

Please note, that GitHub repo is a mirror from private server. You can use issues or make pull requests here on GitHub.
