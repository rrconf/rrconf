rrconf: require/replay configuration
====================================

Configuration management written with [KISS](http://wiki.c2.com/?KissPrinciple) in mind. The scripts can be used as root or an unprivileged user. RRconf are two `bash` scripts named `require` and `replay`. Each takes a module name as argument - where module is a git repository which contains executable named `main`. Each module may recursively use `require` or `replay`. Complex tasks can be split into smaller, reusable modules. Bootstrapping newly provisioned cloud VM's or even bare metal servers then becomes automated, unattended routine.

In addition to bootstrapping fresh installations, `require` can be run from `cron` at regular intervals. This enables keeping systems updated, reporting periodically or executing add-hoc tasks following a pull-model - much more scalable than a push-model based configuration management systems. Remote execution is possible via `ssh`. Its good to harden your configuration (e.g. different ssh keys, forcing remote commands, etc.).

There are about 350 lines of shell code, properly commented (improvements welcomed), including empty lines. There is even a template rendering system included.

Simple configuration management
-------------------------------

Top-level invocation of `require` or `replay` is rather identical, but nested calls from top-level module differ: once a module is `require`d, any subsequent `require` from this or any other module in the same run is skipped. To execute module several times in the same run, use `replay` - potentially with different arguments for each `replay`:

```
$ require webserver
$ for user in joe jack jane
> do
>    replay admin-user $user
> done
$
```

Modules are always in git repositories. The repository name is constructed form a prefix, e.g. `ssh://github.com/myorg/mod-` and the module name. The prefix is of configurable - and can be a list of prefixes. They are stored in plain files in `/etc/rrconf/repos.d/` and is searched in a `PATH`-like manner, **the first match wins**. The first in the list should be your private repos, followed by hub of community repos.

Please note that trailing character of prefix is not stripped, **and if it is a slash, even mandatory**. Then you can store repositories for module in a project sub-groups (like devel and prod) and share module and repository names. You can use prefix like `ssh://gitlab:2222/username/devel/module-` and your own info module can have repository base name `module-admin-user.git`.

Programing language is not enforced. As long as you can read environment variables, or export them for nested processes, you are fine. Just place executable `main` in the root of your module repository and thats all.

Installation
------------

Clone the code:

```
$ git clone https://github.com/rrconf/rrconf ~/rrconf
```

Now update your `PATH` (remember also your own shell rc file). Alternatively, place symlinks to files in directory which is already in your `PATH` (e.g. into `~/bin`).

System-wide installation is left as an exercise for admins, with the hint that `/opt/rrconf` is my own default system-wide directory. You can pick your choice freely.

### Configuration

Optional configuration is `source`d from `/etc/rrconf/rrconf.conf`, followed by `~/.config/rrconf.conf`. The defaults -- if neither file is present -- are as follows:

```
# installation path:
RRCONF=$(dirname $(realpath -e ${BASH_SOURCE}))
# repository search path files:
RRCONF_REPOS=/etc/rrconf/repos.d
```

An unprivileged user can change some defaults, e.g.:

```
RRCONF_REPOS=${HOME}/repos.d
```

Last step is to create at least one repo file, which should contain repo prefix. There can be multiple files and their names are enumerated and sorted by `run-parts`, so default backup files or package installer files are excluded.

```
mkdir /home/username/repos.d
echo 'https://github.com/rrconf/tutorial-' > /home/username/repos.d/99-last-resort
```

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

Future and Final notes
======================

I have some strong use cases for ideas like classes or facts and plan to implement it, now there is nothing.

More documentation will be written if needed, [just ask](http://www.catb.org/esr/faqs/smart-questions.html#before) and create issue on GitHub. No specific template.

This is still rather beta than production, but works for me for dozens of (mostly [Debian](https://debian.org/)) systems and containers already, actually run from `cron` as `require $(hostname --fqdn)`. I have almost replaced all ansible and puppet code with this project, for incredibly customized, diverse systems over the net.
