# LoGiVi

LoGiVi is a git-repository visualisation tool inspired by [Gource](https://code.google.com/p/gource/) and __currently in development__. It was written from scratch using [Lua](http://www.lua.org/) and the [LÖVE](https://love2d.org/) framework.

# Instructions
LoGiVi can't read from a .git repository directly ([yet](https://github.com/rm-code/logivi/issues/3)). Instead you will have to create a git-log which needs to have a specific format. Please use this command to create the file:

```bash
git log --reverse --numstat --pretty=format:"author: %an|%ae%ndate: %ct%n" --name-status --no-merges > log.txt
```

This will create a log file in the same directory as the .git repository (If you want to write the log to a different location add its path after the '>' in the command above).

When you run LoGiVi for the first time it will automatically open the folder in which you need to place the log. Depending on your operating system this can be one of the following locations:

- Windows XP: C:\Documents and Settings\user\Application Data\LOVE\rmcode_logivi
- Windows Vista and 7: C:\Users\user\AppData\Roaming\LOVE\rmcode_logivi
- Linux: $XDG_DATA_HOME/love/ or ~/.local/share/love/rmcode_logivi
- Mac: /Users/user/Library/Application Support/LOVE/rmcode_logivi

For more information about the filesystem check the [LÖVE wiki](https://love2d.org/wiki/love.filesystem).

As soon as the file is in the correct folder you can start LoGiVi and watch as it creates a visual representation of your git repository.

Check the [wiki](https://github.com/rm-code/logivi/wiki) for instructions and further information.

# License

The MIT License (MIT)

Copyright (c) 2014 - 2015 Robert Machmer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.