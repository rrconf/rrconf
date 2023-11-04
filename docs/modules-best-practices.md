# Modules Best Practices

## Simple and Short

Do one task and do it well.

Modules should be "short", whatever it means for given task. Typical module is few dozen of lines, occasionaly hundreds, but to deploy very complex application and its configuration files you may require megabytes if you distribute binary or packages from git repository of your module.

## Generic and Reusable

Repeatable work? Parametrize it and re-use. `require` and mainly `replay` is meant to be called from module itself.

Easier to say than doing copy paste, but over the time, copies of mostly identical modules makes it hard to maintain, fix, or even invent new name.

It can be hard to update existing modules, without breaking changes, ensuring production still runs. Instead, it is easier to just copy and invent slightly-fancier-module-name-fiting-my-task, but such names come hard to remember. Nobody comes with with pull request to half a dozen of similarly named modules.

## Reviews, unit tesing, integration testing

Patches wlcmed.

## Don't reinvent the weel

Nobody neetds a module for simple tasks, e.g. `require mkdir /hello/world` isn't even worth a tutorial.

As an example, there is [addgroup](https://github.com/rrconf/rr-addgroup) module. Even in a shell script it is easy to call `/usr/bin/addgroup` that making a module for it seems unnecessary, many tutorials for config management systems use it as example. In practice, do not wrap simple and common unix commands into a module without adding some meaningful add-on value or functionality.

----
[INDEX](./readme.md)
