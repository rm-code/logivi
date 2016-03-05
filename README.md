# LoGiVi

[![Version](https://img.shields.io/badge/Version-0432-blue.svg)](https://github.com/rm-code/logivi/releases/latest)
[![LOVE](https://img.shields.io/badge/L%C3%96VE-0.10.1-EA316E.svg)](http://love2d.org/)
[![License](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE.md)

LoGiVi is a [Git](https://git-scm.com/)-respository visualisation tool inspired by [Gource](http://gource.io/) and __currently in development__. It was written from scratch using [Lua](http://www.lua.org/) and the [LÖVE](https://love2d.org/) framework.

Note: Since version [0375](https://github.com/rm-code/logivi/releases/tag/0375) LoGiVi uses version [0.10.0](https://love2d.org/wiki/0.10.0) of the LÖVE framework.

![Example Visualization](https://cloud.githubusercontent.com/assets/11627131/13007242/29da1fd0-d18f-11e5-9615-96cf0e4c2b3d.gif)

# Instructions
When you run LoGiVi for the first time it will set up all necessary folders, an example git log and a configuration file in the save directory on your harddrive.

The location of this save directory depends on the OS you are using:

- ***OSX*** ```/Users/user/Library/Application Support/LOVE/rmcode_LoGiVi```
- ***WINDOWS*** ```C:\Users\user\AppData\Roaming\LOVE``` or ```%appdata%\LOVE\```
- ***LINUX*** ```~/.local/share/love/```

A dialog will pop up which allows you to view the save directory on your computer.

## Generating Git logs automatically
LoGiVi can create all the files it needs to display your Git repositories on its own, but this requires that Git is installed in your PATH.

### Drag and drop
Since version [0404](https://github.com/rm-code/logivi/releases/tag/0404) you can add a repository by dropping a folder containing a Git-repository directly onto LoGiVi's main menu. The repository will be added to the list automatically and can then be watched directly.

(_Note: Repositories added via drag and dropped can not be updated inside of LoGiVi_)

### Specifying a location
The other way of adding a repository is by specifying the path in the _settings.cfg_ in the save directory LoGiVi creates on your harddrive. Open the file and look for the _[repositories]_ section. Add the absolute path to the folder containing the git repository like this:

```
[repositories]
logivi = /Users/Robert/Coding/Lua/LÖVE/LoGiVi/
```
The name on the left side of the equals sign will be used as the project name to identify this repository so make sure you use unique names here.

LoGiVi can also handle Windows paths:

```
[repositories]
logivi = C:\Users\rmcode\Documents\Coding Projects\LoGiVi\
```
After you have added the paths of your project to the config file, the log and info files will be created the next time you run LoGiVi (this may take a few seconds depending on how large the repositories are).

## Generating git logs manually
If you don't want the logs to be generated automatically, or if you don't have Git in your PATH, you can also generate the logs manually.

Open your terminal and type in the following command (replace the path with your own path leading to a git repository):

```bash
git -C "Path/To/Your/Repository" log --reverse --numstat --pretty=format:"info: %an|%ae|%ct" --name-status --no-merges > log.txt
```
This will create the file _log.txt_ in the folder you are currently in. Take this newly created file and drop it into a folder in the _logs_ subfolder in the LoGiVi save directory.

LoGiVi will use the folder's name to identify the log so make it informative.
