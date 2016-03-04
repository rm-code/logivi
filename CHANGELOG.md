# WIP

### Additions
- Added [Graphoon](https://github.com/rm-code/Graphoon) library

### Removals
- Removed loading of custom avatars

### Other Changes
- Improve warning message displayed when running LoGiVi for the first time

---

# Version 0432 - 2015-12-14

### Additions
- Added scaling for folder and name labels based on the camera's zoom factor
- Added MessageBox which displays a warning in case git isn't found on the user's system (Closes [#50](https://github.com/rm-code/logivi/issues/50))
- Added mouse panning and scaling (Closes [#45](https://github.com/rm-code/logivi/issues/45))
    - The mouse can be used to drag around the camera while the left button is pressed
    - The mouse wheel can be used to zoom in and out

### Fixes
- Fixed [#51](https://github.com/rm-code/logivi/issues/51) - Fixed crash caused by faulty variable
- Fixed [#48](https://github.com/rm-code/logivi/issues/48) - Got rid of the timer for color fading
- Fixed [#35](https://github.com/rm-code/logivi/issues/35) - Made large graphs more stable
- Fixed minor issue with folder labels being drawn multiple times per frame

### Other Changes
- LoGiVi now starts in windowed mode on first start
- Changed design of the file panel to be less intrusive

---

# Version 0404 - 2015-11-24

### Additions
- Added option to add a repository by dropping its folder onto LoGiVi (Closes [#46](https://github.com/rm-code/logivi/issues/46))
- Added automatic camera zoom (Closes [#47](https://github.com/rm-code/logivi/issues/47))
- Added fading of deleted files. They will no longer be removed instantly, but instead fade out until they are invisible (Closes [#49](https://github.com/rm-code/logivi/issues/49))
- Added animation of files when they are rearranged around their parent nodes

### Fixes
- Fixed [#44](https://github.com/rm-code/logivi/issues/44) - File paths are validated after the config has been validated
- Fixed direction of camera rotation

---

# Version 0375 - 2015-11-11

**Important**: With this version LoGiVi now ***requires*** LÖVE Version [0.10.0](https://love2d.org/wiki/0.10.0) to run and will no longer work with LÖVE 0.9.2! LÖVE 0.10.0 has not yet been officially released, but can be compiled from the source. For more information check out the [official LÖVE repository](https://bitbucket.org/rude/love/overview).

### Fixes
- Fixed [#43](https://github.com/rm-code/logivi/issues/43) - Allow more printable characters as keys in config file
- Fixed [#42](https://github.com/rm-code/logivi/issues/42) - Prevent crash with faulty info files
- Fixed [#41](https://github.com/rm-code/logivi/issues/41) - Make sure paths lead to a valid git repository

### Other Changes
- Updated LoGiVi to run on LÖVE 0.10.0

---

# Version 0351 - 2015-08-01

### Additions
- Added authors' names to their avatars
- Added functionality to load custom information about projects from a special file (Closes [#34](https://github.com/rm-code/logivi/issues/34))

### Fixes
- Fixed [#37](https://github.com/rm-code/logivi/issues/37) - FilePanel can no longer be scrolled endlessly
- Fixed [#36](https://github.com/rm-code/logivi/issues/36) - FilePanel can no longer be interacted with when it is hidden
- Fixed [#24](https://github.com/rm-code/logivi/issues/24) - Use io.popen instead of os.execute to check for git
- Fixed [#14](https://github.com/rm-code/logivi/issues/14) - Improved timeline for repos with less than 128 commits
- Fixed timeline label being slightly off center
- Fixed timeline label being drawn multiple times each frame

### Other Changes
- Display a default string when no custom information about a project can be loaded

---

# Version 0312 - 2015-04-20

### Additions
- Added keybinding for easy exiting
- Added selection screen
    - LoGiVi can keep track of multiple git logs
    - User can select which log to visualize on the selections screen
    - User can use "exit"-key to return to the selection screen
    - Log-selection list is scrollable with the mouse wheel
    - Added watch button which takes the user to the visualization of the selected log
- Added example log which will be written to the save directory if no logs are found
- Added option to specify a custom color for a file extension in the config file
- Git logs can now be created from within LoGiVi (Closes [#3](https://github.com/rm-code/logivi/issues/3))
    - The user can specify the path to a local repository in the config file
    - LoGiVi will automatically create a log and load this repository on start
    - Information about the repository will be automatically written to the project folder (first commit, latest commit, total number of commits)
        - This currently doesn't work on Windows (See [#28](https://github.com/rm-code/logivi/issues/28))
        - Information is displayed on the info panel
    - Added a refresh button to the SelectionScreen's info panel, which can be used to update the selected log
- Added function to sort files based on their extension while placing them around their folder node (Closes [#22](https://github.com/rm-code/logivi/issues/22))
- Added button to SelectionScreen which opens the save directory
- Added tooltips
- Added custom colors for links between authors and files
- Added new high quality sprites (Closes [#17](https://github.com/rm-code/logivi/issues/17))
- Added config file validation after it has been loaded (Closes [#26](https://github.com/rm-code/logivi/issues/26))

### Fixes
- Fixed [#33](https://github.com/rm-code/logivi/issues/33) - Ignore lines in config file which aren't formatted correctly
- Fixed [#32](https://github.com/rm-code/logivi/issues/32) - Resize Timeline when MainScreen is resized
- Fixed [#31](https://github.com/rm-code/logivi/issues/31) - Directly pass the repository's path to the git command
- Fixed [#30](https://github.com/rm-code/logivi/issues/30) - Ignore files when no changes were applied
- Fixed [#29](https://github.com/rm-code/logivi/issues/29) - Reset the FileManager when MainScreen is closed
- Fixed [#27](https://github.com/rm-code/logivi/issues/27) - Replace escape characters in the path to a repository
- Fixed [#23](https://github.com/rm-code/logivi/issues/23) - Increase speed at which example is written to the HDD
- Fixed [#20](https://github.com/rm-code/logivi/issues/20) - Center the screen when it is resized in the config
- Fixed [#19](https://github.com/rm-code/logivi/issues/19) - Allow multiple key bindings
- Fixed [#5](https://github.com/rm-code/logivi/issues/5) - Improve author movement
- Fixed crash when the file list wasn't updated after creating the example

### Other Changes
- Updated the warning message which is displayed when no logs are found
- Logs are now located in the 'logs' subfolder in the save directory of LoGiVi
- Reduced time before authors start fading
- Config file now uses a custom format based on ini-files

---

# Version 0204 - 2015-04-10

### Additions
- Added option to set the visibility of folder labels in the config file
- Added keybinding for hiding / unhiding folder labels while LoGiVi is running
- Added keybinding for pausing the automatic commit loading
- Added keybinding for manually loading the next commit
- Added keybinding for manually loading the previous commit
- Added keybinding for reversing the graph creation (will run back until it reaches the first commit)
- Added keybinding for toggling fullscreen mode
- Added a timeline
    - Indicates the current position of the log compared to the total commit history and shows the date of the currently indexed commit
    - Allows the user to quickly jump around in time (forward and backwards) while still rendering the full graph (Closes [#10](https://github.com/rm-code/logivi/issues/10))
    - Can be hidden via keybinding or in the config file
- Added option to the config file which makes the visualization start at the end of the git log (so it starts with the newest commit and moves towards the oldest)
- Added option to disable autoplay in the config file

### Fixes
- Fixed [#18](https://github.com/rm-code/logivi/issues/18) - Prevents crash when no git log is found
- Fixed [#15](https://github.com/rm-code/logivi/issues/15) - Files no longer overlap folder labels
- Fixed [#13](https://github.com/rm-code/logivi/issues/13) - Links between authors and files will fade after a certain period of inactivity

### Other Changes
- Labels now use the folder's name instead of its path
- Config is now set to use the fullscreen mode by default
- Increased width of the "beam" between authors and files
- Files list is now sorted by the amount of files of the same extension (Closes [#14](https://github.com/rm-code/logivi/issues/14))
- Files now are marked with different colors depending on the applied git modifier (addition = green, modification = orange, deletion = red)

---

# Version 0142 - 2015-04-01

### Additions
- Added more options to the logivi config file
- Added ui panel which can be moved, resized and scrolled which now contains the file list
- Added keybindings for camera controls to the config file
- Added option to hide commit authors in the config file
- Added keybinding to hide / unhide commit authors while LoGiVi is running
- Added option to set the speed at which commits are loaded in the config file
- Added option to set the width of the graph's edges in the config file
- Added option to set visibility of the file panel in the config file
- Added keybinding to hide / unhide the file panel while LoGiVi is running
- Added labels which are drawn next to their respective node

### Fixes
- Fixed [#9](https://github.com/rm-code/logivi/issues/9) - Use radius of a node in mass calculation to make sure small nodes get pushed away far enough from bigger nodes
- Fixed [#8](https://github.com/rm-code/logivi/issues/8) - Prevent crash when trying to modify a file which doesn't exist (anymore)
- Fixed [#7](https://github.com/rm-code/logivi/issues/7) - Parents are removed correctly if they became empty after their last child had been removed
- Fixed [#6](https://github.com/rm-code/logivi/issues/6) - Avatars no longer rotate with the camera
- Fixed [#2](https://github.com/rm-code/logivi/issues/2) - Edges are removed correctly when a node is killed

### Other Changes
- Updated message box when no git log is found and added a button to directly open the LoGiVi wiki
- Improved graph layout by tweaking the mass calculation and charge of each node (edges should now be shorter which reduces the total size of the graph)
- Increased width of the graph's edges
- Replaced old movement code for authors with physical based approach (Closes [#5](https://github.com/rm-code/logivi/issues/5))

---

# Version 0104 - 2015-03-30

### Additions
- Added debug information about the user's system and supported features of the LÖVE framework which will be printed to the console
- Added configuration file reader which will contain all options for LoGiVi
    - This means we can get rid of the _aliases_ and _avatars_ files since they now are bundled in the config file
- Added option to set a background color in the configuration file
- Added option for setting a resolution in the configuration file
- Added possibility use local images as avatars
- Added counter for the total amount of files
- Added SpriteBatch to draw file sprites
- Added higher quality file sprites
- Added a proper force directed layout which uses attraction and repulsion forces between all nodes of the graph
- Added manual camera controls (Closes [#1](https://github.com/rm-code/logivi/issues/1))

### Removals
- Removed folder node sprites, which were located at the center of each folder node

### Fixes
- Fixed [#3](https://github.com/rm-code/logivi/commit/0060125b03ceb5c31d57a4bed4cadeaf98140785) (From Bitbucket) - Files which use multiple full stops are logged correctly now
- Fixed [#2](https://github.com/rm-code/logivi/commit/a7ebb57bd77c5355fc92233be0633ad012a24dba) (From Bitbucket) - Catch error when trying to access an invalid file
- Closed [#1](https://github.com/rm-code/logivi/commit/7dcee77a168b1267ec6b8d0abce9a3eb8c714583) (From Bitbucket) - Removed box2d remnants

### Other Changes
- Rewrote most of the graph system
    - The graph is structured and handled completely different than before with files, folder nodes and edges being independent from each other
    - Gets rid of a lot of issues like edges overlaying other nodes
    - The arrangement of files around folder nodes is no longer updated every frame
    - Major improvements in memory usage, performance and garbage production
- Updated log reader to separate commits based on the author tag instead of looking for the "special" logivi_commit tag (which was pretty useless anyway)
- Updated log reader to digest unix timestamps and transform them into human readable dates
- Updated arrangement of file nodes to make them fill up the empty space where the folder nodes used to be
- Updated AuthorManager to write user avatars to a subfolder in the save-directory
- Authors circle the node instead of moving around randomly
- Authors are logged based on their email addresses _and_ their nicknames
- Update FileManager to ignore the case of a file extension
- Debug information is hidden by default, but can be toggled via the F1-Key
- Repositioned file list
- Reduce memory usage by storing date as a string instead of as a table
- Extended debug information

---

# Version 0052 - 2015-01-18

### Additions
- Added (rudimentary) Force-Directed Graph which - visualizes the files and folders of a git repository at a given point in time
    - Files are represented as evenly distributed leaves around their parent folder node
        - Depending on the amount of files in one folder new folders will be created automatically)
        - Modified files are colored red and fade back to their original color over time
    - Folders are represented as single green dots (this will be changed in one of the next releases) and are connected by lines
- Added list of all authors contributing to the project
- Added list of all file extensions found in the project
- Added coloring of file nodes based on their file extensions
- Added camera which keeps tracking the generated graph automatically
- Added floating authors
    - Authors will show links to the files they currently edit
    - Authors can be assigned an alias
    - Authors can be assigned an avatar (grabbed online)
- Added warning message if no log file can be found
