# LoGiVi

LoGiVi is a git-repository visualisation tool inspired by [Gource](http://gource.io/) and __currently in development__. It was written from scratch using [Lua](http://www.lua.org/) and the [LÖVE](https://love2d.org/) framework.

![Example Visualization](https://github.com/rm-code/logivi/wiki/media/logivi_0312.gif)

# Instructions
When you run LoGiVi for the first time it will set up all necessary folders, an example git log and a config file in the save directory on your harddrive. 

The location of this save directory depends on the OS you are using:

- ***OSX*** ```/Users/user/Library/Application Support/LOVE/rmcode_LoGiVi```
- ***WINDOWS*** ```C:\Users\user\AppData\Roaming\LOVE``` or ```%appdata%\LOVE\```
- ***LINUX*** ```~/.local/share/love/```

A dialog will pop up which allows you to view the save directory on your computer.

## Generating git logs automatically
LoGiVi can generate git logs automatically when you specify a path to a git repository on your harddrive. Open the _settings.cfg_ file in the LoGiVi save directory and look for the _[repositories]_ section. Add the absolute path to the folder containing the git repository like this:

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
If you don't want the logs to be generated automatically, or if you don't have git in your PATH, you can also generate the git logs manually. 

Open your terminal and type in the following command (replace the path with your own path leading to a git repository):

```bash
git -C "Path/To/Your/Repository" log --reverse --numstat --pretty=format:"info: %an|%ae|%ct" --name-status --no-merges > log.txt
```
This will create the file _log.txt_ in the folder you are currently in. Take this newly created file and drop it into a folder in the _logs_ subfolder in the LoGiVi save directory:

```
/Users/Robert/Library/Application Support/LOVE/rmcode_LoGiVi/logs/yourProject/log.txt
```
LoGiVi will use the folder's name to identify the log so make it informative.

# LÖVE Version
Version 0351 and all prior versions of LoGiVi are written for Version 0.9.2 of the LÖVE framework. ___All future versions will be based on LÖVE 0.10.0 (currently unreleased).___

# License

The MIT License (MIT)

Copyright (c) 2014 - 2015 Robert Machmer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
