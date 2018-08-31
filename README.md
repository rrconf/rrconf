rrconf: require/replay configuration
====================================

The motto is [KISS](http://wiki.c2.com/?KissPrinciple). RRconf are two `bash` scripts executing your (or community built) modules, which are all stored somewhere as a git repository.

**Note:** This is still rather beta than production, but works for me for dozens of (mostly [Debian](https://debian.org/)) systems and containers already, actually run from `cron` as `require $(hostname --fqdn)`. I have almost replaced all ansible and puppet code with this project, for incredibly customized, diverse systems over the net.

Simple configuration management
-------------------------------

There are about 350 lines of shell code, properly commented (improvements welcomed), including empty lines. There is even a template rendering system included.

The `require` and `replay` take a module name as argument, clone it from the repository and execute it. All modules can recursively use `require` and `replay` if they depend on other modules.

If a module is `require`d, it is run only once, while `replay`ed modules can be invoked in loops, or to re-run `require`d module with different configuration.

The repositories for modules are searched in a `PATH`-like manner, **the first match wins**. Modules can thus be written by others, but your repositories should be in front.

Remote execution is possible via `ssh`. Its up to you to secure your configuration (e.g. different ssh keys, forcing remote commands, etc.). This way you can also collect metrics from remote systems, or implement simple monitoring.

Programing language is not enforced. As long as you can read environment variables, or export them for nested processes, you are fine. Make your module executable and thats all.

I have some strong use cases for ideas like classes or facts and plan to implement it, now there is nothing.

Documentation
-------------

More documentation will be written if needed, [just ask](http://www.catb.org/esr/faqs/smart-questions.html#before) and create issue on GitHub. No specific template.

### Installation

Clone the code:

```
$ git clone https://github.com/rrconf/rrconf ~/rrconf
```

Now update your `PATH` (remember also shell rc file). As an unprivileged user skip to configuration.

System-wide installation is left as an exercise for admins, with the hint that `/opt/rrconf` is my own default system-wide directory. You can pick your choice freely.

#### Configuration

The configuration is read from `/etc/rrconf.conf` or `/etc/rrconf/rrconf.conf`, later being preferred alternative. This is followed without complaints by reading `~/.rrconf`. The defaults -- if not present -- are as follows:

```
# installation path:
RRCONF=$(dirname $(realpath -e ${BASH_SOURCE}))
# repository search path files:
RRCONF_REPOS=/etc/rrconf/repos.d
```

As an ordinary user you do have to change some defaults, or completely change system defaults if they exist:

```
RRCONF_REPOS=${HOME}/repos.d
```

Last step is to create at least one repo file. The content of the file is partial name of the repository strings to try to clone modules. There can be multiple files and their names are enumerated and sorted by `run-parts`, so default backup files or package installer files are excluded.

```
mkdir /home/username/repos.d
echo 'https://github.com/rrconf/tutorial-' > /home/username/repos.d/99-last-resort
```

Please note that trailing dash is important, **and if it is a slash, even mandatory**, and is never stripped. Then you can store repositories for module in a project sub-groups (like devel and prod) and share module and repository names. You can still use `ssh://gitlab:2222/username/group/module-` and your own info module can have repository base name `module-info.git`.

The files in this directory are enumerated with `run-parts`. There is no default or blacklist implemented, you need at least one repo file.

### Tutorial

Both `require` and `replay` take one argument, and thats a name of a module to run. Before the module is run, it must be installed. This is done by cloning via git according to first match in repos.d file.

```
$ require info
```

This will first clone module [info](https://gitbub.com/rrconf/tutorial-info.git) and run the executable `main` in the source tree:

```
$ require info
fqdn:workbook.local
hostname:workbook
machine-id:d28679839dfe422d8274201f6f97c50d
$
```

### Contributing

Please note, that GitHub repo is a mirror from private server. You can use issues or make pull requests on GitHub.
