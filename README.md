# Friday Night Funkin' - Screwed Engine
Engine originally created for (Screwed Edition)[link soon...] (a mod of Dave And Bambi), but it can be used for your mod too! Just credit us.

**This engine adds languages!!!!**

### [Click here to skip this and go to **Features**.](#features)

## How to compile:
Please, keep in mind that you can not seem to compile FNF on Windows 7.

open up a Command Prompt/PowerShell or Terminal, type `haxelib install hmm`

after it finishes, simply type `haxelib run hmm install` in order to install all the needed libraries for *Psych Engine!*

### Customization:

if you wish to disable things like *Lua Scripts* or *Video Cutscenes*, you can read over to `Project.xml`

inside `Project.xml`, you will find several variables to customize Psych Engine to your liking

to start you off, disabling Videos should be simple, simply Delete the line `"VIDEOS_ALLOWED"` or comment it out by wrapping the line in XML-like comments, like this `<!-- YOUR_LINE_HERE -->`

same goes for *Lua Scripts*, comment out or delete the line with `LUA_ALLOWED`, this and other customization options are all available within the `Project.xml` file

### Old Customization:

Just watch longestsoloever's video, I've used his tutorial and I've been successful with it.
https://www.youtube.com/watch?v=4IuC8ti6_4o _-miksel_

If you get an error about StatePointer when using Lua, run `haxelib remove linc_luajit` into Command Prompt/PowerShell, then _re-install linc_luajit_ via `haxelib git linc_luajit https://github.com/superpowers04/linc_luajit`.

If you want video support on your mod, simply do `haxelib install hxCodec 2.5.1` on a Command prompt/PowerShell

otherwise, you can delete the "VIDEOS_ALLOWED" Line on Project.xml

## Screwed Engine Credits:
* [@Wither362](https://github.com/Wither362) - Basically making everything on the engine.
* [@Moxie](https://github.com/moxie-coder) - Additional Programmer and Deleting-Coder. <- This guy is awesome. I just can't explain all this guy has made to this engine. Without him, any of this would be possible.
* [@miksel](https://github.com/miksel1) - The one who broke most of the code at the beginning
* Dante - Strident Engine coder
* not capcha - Helping with _Legacy_ Freeplay Sections
* CrowPlexus - Help with winning icons

## Psych Engine Credits:
* Shadow Mario - Programmer
* RiverOaken - Artist

### Special Thanks
* bbpanzu - Ex-Programmer
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Note Splash Animations
* Smokey - Sprite Atlas Support
* Nebula the Zorua - Some Lua reworks
* Superpowers04 - Lua JIT Fork
_____________________________________

# Features
  * Some new Achievements for good spammers.
  * A lot of new options for getting ***no lag***.
  * Markdown event's description (go to the [WIKI](https://github.com/miksel1/FNF-ScrewedEngine/wiki) to see how it works).

# D&B Features:
   * Adds multiple features from mods like Strident Crisis like:
### Freeplay Sections:
   * Explains itself, Freeplay Sections with a ***new system***: all the **songs that start with "--" and ends with "--"**, it will add it to a new section for organization.
### A search bar in Freeplay

### "Screw you!" and credits text:
   * Once again, self-explainable.
  
![](https://media.discordapp.net/attachments/1025448192491388998/1036759283724976232/unknown.png)
![](https://media.discordapp.net/attachments/936741759210389555/1036928314163613737/327416939.2150001_image.png)
### Chart Editor:
   * In the chart editor, I (Wither) added a few new features like:
     * Manual Zoom.
     * More Zoom.
     * Drawing (press C to put notes where is the mouse). (miksel)
     * Autosave.
     * More buttons.
     * Strident Engine.
     * **More events (use them for _lot-of-notes_ songs!)**
     * Some new inputs.
### 7 events:
   * Upon pressing 7 on any song, **by default it goes to the chart editor.**
   * You can change it in the chart editor.
### Shaders:
   * **Glitch Effect:**
     * Added into **lua**!
   * **Customizable Grain Effect (WIP):**
     * Source for now.
   * **Mosaic Effect:**
     * For Lua it isn't full done yet.
### Eyesores:
   * Rainbow Eyesore from Polygonized and Glitch, added into Psych (credits for ***Delta***)!
   * I may've forgotten a few...


## Atleast one change to every week:
### Week 1:
  * New Dad Left sing sprite
  * Unused stage lights are now used
### Week 2:
  * Both BF and Skid & Pump does "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool new colors flash during that sick part of the song
### Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

## Cool new Chart Editor changes and countless bug fixes
![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/chart.png?raw=true)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with two example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.

## Multiple editors to assist you in making your own Mod
![Screenshot_3](https://user-images.githubusercontent.com/44785097/144629914-1fe55999-2f18-4cc1-bc70-afe616d74ae5.png)
* Working both for Source code modding and Downloaded builds!

## Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

## Credits menu
![Screenshot_1](https://user-images.githubusercontent.com/44785097/144632635-f263fb22-b879-4d6b-96d6-865e9562b907.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

## Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

## Options menu:
* You can change Note colors, Delay and Combo Offset, Controls and Preferences there.
 * On Preferences you can toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.

## Other gameplay features:
* When the enemy hits a note, their strum note also glows.
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note splashes)
* You can reset your Score on Freeplay/Story Mode by pressing Reset button.
* You can listen to a song or adjust Scroll Speed/Damage taken/etc. on Freeplay by pressing Space.
