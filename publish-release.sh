#!/bin/bash

# Get the version numbers from the lua file and store them in an array.
i=0
while read line ; do
    no=${line//[!0-9]/}
    if [ ! -z "$no" ]; then
        version[$i]=${line//[!0-9]/}
        i=$((i+1))
    fi
done < version.lua

# Assign to variables.
major=${version[0]}
minor=${version[1]}
patch=${version[2]}
build=${version[3]}

formatted="$major$minor$patch-$build"
title="logivi_"

# Zip files. Exclude git folder and DS_Store files.
echo "Packing .love file for $major.$minor.$patch.$build"
zip -r -q $title$formatted.love ./ -x *.git* -x *.DS_Store* -x *.sh*

# Move to releases folder and cd to releases.
mkdir ../releases/$title$formatted
mv -i -v $title$formatted.love ../releases/$title$formatted
cd ../releases/$title$formatted || exit

## CREATE WINDOWS EXECUTABLE
# Unzip the LÖVE binaries.
unzip -q ../LOVE_bin.zip -d LOVE_WIN

# Create the executable.
echo "Creating .exe"
cp ./$title$formatted.love ./LOVE_WIN
cd LOVE_WIN || exit
cat love.exe $title$formatted.love > $title$formatted.exe

rm -rf __MACOSX
rm lovec.exe
rm love.exe
rm $title$formatted.love
cd ..

# Zip all files.
echo "Zipping .exe and binary files"
zip -r -q $title$formatted-WIN.zip LOVE_WIN/ -x *.git* -x *.DS_Store*

# Remove the folder.
rm -r LOVE_WIN

## CREATE MAC OS APPLICATION
echo "Creating Mac OS Application"
unzip -q ../LOVE_bin_OSX.zip -d LOVE_OSX

# Rename Application
cd LOVE_OSX || exit
mv love.app $title$formatted.app

# Move .love file into the .app
cp ../$title$formatted.love $title$formatted.app/Contents/Resources

# Copy modifed plist
cp ../../Info.plist $title$formatted.app/Contents/

# There probably is a wayyy better way to do this ...
echo "<key>CFBundleShortVersionString</key>" >> $title$formatted.app/Contents/Info.plist
echo "<string>$major.$minor.$patch.$build</string>" >> $title$formatted.app/Contents/Info.plist
echo "</dict>" >> $title$formatted.app/Contents/Info.plist
echo "</plist>" >> $title$formatted.app/Contents/Info.plist

# Move to the parent folder
mv -i -v $title$formatted.app ../$title$formatted-OSX.app

# Remove the temporary folder.
cd ..
rm -r LOVE_OSX
