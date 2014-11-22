Introduction
============
PD2 Skill Profiler is a mod for the video game Payday 2. It adds an interface to
quickly change a player's skills.

This README covers the installation and usage of this mod.

**It is strongly recommended to backup your save file before using this mod.**
This is the first release of this mod, there may be bugs. Follow
[this steam guide](http://steamcommunity.com/sharedfiles/filedetails/?id=170416480)
to backup your save.

Installation
============

1. Click the *Download ZIP* button on the right pannel of this page;
2. Extract the content of the zipped file;
3. Copy the content of `PD2-Skill-Profiler-master` to your Payday 2 folder (typically `C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2`);
4. Do not overwrite `PD2hook.yml`. If you are asked to do so, that means you have other mods installed. In this case, merge the content of both files using a text editor.

After installation is done, a new option should appear in the game's menu under
"Skills and Perks". Click it to open the Skill Profiler.

Advanced features
=================

AKA features that aren't in the GUI yet, but can be done manually if you so desire.

Changing profile names
----------------------

Adding new profiles from the GUI automatically assigns them a generic name. To
change those names, open the `skillprofiles.txt` file in your Payday 2 folder.
Each profile takes 2 lines in this file, the first one being the name and the
second one describes the skills. Simply edit the line with the profile's name to
the name of your choice. Note that names need to be unique, otherwise one of them
will overwrite the other.

I recommend using *Notepad*, due to how it handles "newline" characters.
Using another text editor might make your file unusable by this mod.

Importing profiles from PD2skills.com
-------------------------------------
To import a skill build from pd2skills.com, open the `skillprofiles.txt` file in
your Payday 2 folder. First, add a new line at the end of the file and enter the
profile's name. Then, add another line and copy the pd2skills URL there.

I recommend using *Notepad*, due to how it handles "newline" characters.
Using another text editor might make your file unusable by this mod.

Known bugs and missing features
===============================

- Skill dependencies aren't check properly. This means a profile that has Joker but
  not Dominator, for example, will pass the safety test but fail to be assigned properly;
- Cash/skill values on the main menu don't update after changing profile;
- At the moment, there is no way to ask the users for input (e.g. for the profile name).

Special thanks
==============

- **gir489** for his Payday 2 source code [repository](https://bitbucket.org/gir489/payday-2-lua-repo/src);
- **stumpy3toes** for his CustomMenu class. You can find it [here](http://www.unknowncheats.me/forum/payday-2/122033-custom-mod-menu-class-using-gui-drawing.html);
- **MS HACK** and **notwa** for finding a simple way to add new options to the main menu. Their posts can be found
  [here](http://www.unknowncheats.me/forum/payday-2/121738-menumanager-its-possible-2.html).
