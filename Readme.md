# LoGiVi

LoGiVi is a git repository visualisation tool inspired by [Gource](https://code.google.com/p/gource/). 

## Instructions
LoGiVi (LÖVE Git Viewer) can't read from a .git repository directly. Instead you will have to create a git-log which needs to have a specific format. Please use this command to create the file:

    git log --reverse --date=iso -m --pretty=format:'logivi_commit%nauthor: %an%ndate: %ad%n' --name-status > log.txt

This will create a log file in the same directory as the .git repository (of course you can write the log to any other location if you want to).

Now you have to move this file to a folder from which it can be read by the LÖVE framework. Depending on your operating system this can be one of the following locations:

- Windows XP: C:\Documents and Settings\user\Application Data\LOVE\rmcode_logivi
- Windows Vista and 7: C:\Users\user\AppData\Roaming\LOVE\rmcode_logivi
- Linux: $XDG_DATA_HOME/love/ or ~/.local/share/love/rmcode_logivi
- Mac: /Users/user/Library/Application Support/LOVE/rmcode_logivi

For more information check the [LÖVE wiki](https://love2d.org/wiki/love.filesystem).

As soon as the file is at the correct folder you can start LoGiVi and watch as it creates a visual representation of your git repository.