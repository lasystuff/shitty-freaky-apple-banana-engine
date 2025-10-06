# Changes, compared to psych engine

## Global changes
- Changed building guide to be a MORE better
1. Uses libs from project.xml as hmm.json
2. Warns or throws error if your haxe is outdated

- Removed useless files like `assets/exclude` and things from `art`
- Libs uses only one specific version
- manifest folder now in assets/.manifest, works by `macros.CustomManifestFolder`
- Added some watches to flixel debugger in debug build
- you can access to `ClientPrefs.data` with `prefs` in states/substates/stages!
- you can access to `ClientPrefs.data.gameplaySettings` with `gameplayPrefs` in states/substates/stages!
- antialiasing sets in all sprites by default, i.e. you dont need `sprite.antialiasing = ClientPrefs.data.antialiasing;` shit
- fixed `Warning : Potential typo detected (expected similar values are flixel.addons.ui.SortMethod.ID)` shit
- `skipNextTransOut` / `skipNextTransIn` vars in states
- code now uses haxe 4.3+ !!! u cant compile on haxe 4.2.5- !!!!
- fullscreen on F11
- ACCEPT now not triggers if you do alt+Enter (fullscreen key)
- prettier error traces
- increased fps cap to 1000 !!!
- fixes for flixel 5.6.0+
- added `onQuit` callback in stages/lua/hscript, executes on quitting `PlayState` entirely (for example from pause or ending song)


## [states.MainMenuState](source/debug/MainMenuState.hx)
1. **static** psychEngineLastCommit:[String](https://api.haxe.org/String.html)
- contains the commit id to which psych engine was updated for this mod core

2. **static** modVersion:[String](https://api.haxe.org/String.html)
- variable added by `macros.ModVersion`, usually contains date of when this build was compiled: `"v%yearmonthday%.%buildNumber%"`


## [psychlua](source/psychlua)
- funk.set instead of Lua_helper.add_callback


## [shaders.Shaders](source/shaders/Shaders.hx) (New)
- cool api for simple adding shaders to source
- game sets `iTime` of shader automatically


## [stages](source/stages)
- this is my stage system instead of psych 0.7+
- states.stages now in stages package
- works almost like lua but with haxe syntax


## [debug.FPSCounter](source/debug/FPSCounter.hx)
- `updateText` was rewritted to do these changes
- displays GPU memory usage now

- changed how fps is calculated (got from flixel debugger)
1. textFormat:[String](https://api.haxe.org/String.html)
- format of fps counter text, resets to default on calling `resetTextFormat()`

2. lowFPSColor:[FlxColor](https://api.haxeflixel.com/flixel/util/FlxColor.html)
- if fps less `FlxG.drawFramerate / 2` then fps counter will turn to this color

3. normalColor:[FlxColor](https://api.haxeflixel.com/flixel/util/FlxColor.html)
- if fps higher or equals `FlxG.drawFramerate / 2` then fps counter will turn to this color

4. tweenToColor(color:[FlxColor](https://api.haxeflixel.com/flixel/util/FlxColor.html), ?withDelay:[Bool](https://api.haxe.org/Bool.html)):[Void](https://api.haxe.org/Void.html)
- tweens color of fps counter to `color` color
- usually used before `MusicBeatState.switchState` or in start of `create()`

5. pressedF3:[Bool](https://api.haxe.org/Bool.html)
- if `true`, then fps counter will show more info, can be switched by pressing F3 everywhere in game

6. pressedF3Lines:[Array](https://api.haxe.org/Array.html)<[String](https://api.haxe.org/String.html)>
- contains which lines will be displayed on fps counter if `pressedF3` is `true`


## [debug.GPUStats](source/debug/GPUStats.hx) (New)
- this class was created for displaying gpu memory usage in memory counter

1. **static** totalMemory:[Float](https://api.haxe.org/Float.html)
- total dedicated GPU memory in bytes

2. **static** memoryUsage:[Float](https://api.haxe.org/Float.html)
- current dedicated GPU memory usage in bytes of this application

3. **static** globalMemoryUsage:[Float](https://api.haxe.org/Float.html)
- current dedicated GPU memory usage in bytes of all applications on PC

4. **static** usage:[Float](https://api.haxe.org/Float.html)
- current GPU utilization percentage of this application

5. **static** globalUsage:[Float](https://api.haxe.org/Float.html)
- current GPU utilization percentage of all applications on PC

6. **static** onUpdate:[FlxSignal](https://api.haxeflixel.com/flixel/util/FlxSignal.html)
- will be dispatched on update of variables. Usually dispatched each second

7. **static** onError:[FlxSignal](https://api.haxeflixel.com/flixel/util/FlxSignal.html)
- will be dispatched on error

8. **static** wasStarted:[Bool](https://api.haxe.org/Bool.html)
- if `true` then GPU stats tracking is running

9. **static** errorMessage:[String](https://api.haxe.org/String.html)

10. **static** init():[Void](https://api.haxe.org/Void.html)
- starts tracking GPU stats, can be gotten with static variables in this class

11. **static** close():[Void](https://api.haxe.org/Void.html)
- terminates tracking GPU stats


## Static extensions, [wait wtf is it?](https://haxe.org/manual/lf-static-extension.html)
- WARNING: these methods wont work in hscript!

1. roundDecimal(n:[Float](https://api.haxe.org/Float.html), decimals:[Int](https://api.haxe.org/Int.html)):[Float](https://api.haxe.org/Float.html)
- works like [FlxMath.roundDecimal](https://api.haxeflixel.com/flixel/math/FlxMath.html#roundDecimal)
- for example: `(0.32531).roundDecimal(2)` will return `0.33`

2. floorDecimal(n:[Float](https://api.haxe.org/Float.html), decimals:[Int](https://api.haxe.org/Int.html)):[Float](https://api.haxe.org/Float.html)
- works like [FlxMath.roundDecimal](https://api.haxeflixel.com/flixel/math/FlxMath.html#roundDecimal), but it uses [Math.ffloor](https://api.haxe.org/Math.html#ffloor)
- for example: `(0.32531).floorDecimal(2)` will return `0.32`

3. toDouble(n:[Float](https://api.haxe.org/Float.html)):[Float](https://api.haxe.org/Float.html)
- for example: `(0.32531).toDouble()` will return `0.33`

4. clearArray(array:[Array](https://api.haxe.org/Array.html)<[Any](https://api.haxe.org/Any.html)>):[Array](https://api.haxe.org/Array.html)<[Any](https://api.haxe.org/Any.html)>
- clears array
- for example: `['asdasd', 'vcxbvcbx'].clearArray()` will return `[]`

5. destroyArray(array:[Array](https://api.haxe.org/Array.html)<[IFlxDestroyable](https://api.haxeflixel.com/flixel/util/IFlxDestroyable.html)>):[Array](https://api.haxe.org/Array.html)<[IFlxDestroyable](https://api.haxeflixel.com/flixel/util/IFlxDestroyable.html)>
- clears array and destroys each object in array
- for example: `[new FlxObject(), new FlxObject()].destroyArray()`

6. destroyGroup(group:[FlxTypedGroup](https://api.haxeflixel.com/flixel/group/FlxTypedGroup.html)<[FlxBasic](https://api.haxeflixel.com/flixel/FlxBasic.html)>):[FlxTypedGroup](https://api.haxeflixel.com/flixel/group/FlxTypedGroup.html)<[FlxBasic](https://api.haxeflixel.com/flixel/FlxBasic.html)>
- clears group and destroys each object in group
- for example: `var g = new FlxGroup(); g.add(new FlxObject()); g.destroyGroup();`

7. disableAntialiasing(spr:[FlxSprite](https://api.haxeflixel.com/flixel/FlxSprite.html)):[FlxSprite](https://api.haxeflixel.com/flixel/FlxSprite.html)
- for example: `new FlxSprite().disableAntialiasing()`

8. setID(spr:[FlxBasic](https://api.haxeflixel.com/flixel/FlxBasic.html), id:[Int](https://api.haxe.org/Int.html)):[FlxBasic](https://api.haxeflixel.com/flixel/FlxBasic.html)
- for example: `new FlxSprite().setID(3)`

9. setOffset(c:[ColorTransform](https://api.haxeflixel.com/openfl/geom/ColorTransform.html), red:[Float](https://api.haxe.org/Float.html) = 0, green:[Float](https://api.haxe.org/Float.html) = 0, blue:[Float](https://api.haxe.org/Float.html) = 0):[Void](https://api.haxe.org/Void.html)
- for example: `sprite.colorTransform.setOffset(1, 3, 6)`

10. setMultiplier(c:[ColorTransform](https://api.haxeflixel.com/openfl/geom/ColorTransform.html), red:[Float](https://api.haxe.org/Float.html) = 1, green:[Float](https://api.haxe.org/Float.html) = 1, blue:[Float](https://api.haxe.org/Float.html) = 1):[Void](https://api.haxe.org/Void.html)
- for example: `sprite.colorTransform.setMultiplier(1.2, 0.2, 0.6)`

11. pow(n:[Float](https://api.haxe.org/Float.html), ?exp:[Float](https://api.haxe.org/Float.html) = 2):[Float](https://api.haxe.org/Float.html)
- works like [Math.pow](https://api.haxe.org/Math.html#pow)
- for example: `(10).pow(2)` will return `100`

12. floatToInt(n:[Float](https://api.haxe.org/Float.html)):[Int](https://api.haxe.org/Int.html)
- for example: `(22.32).toInt()` will return `22`

13. boolToInt(n:[Bool](https://api.haxe.org/Bool.html)):[Int](https://api.haxe.org/Int.html)
- for example: `(true).toInt()` will return `1`

14. toInt(n:[Null](https://api.haxe.org/Null.html)<[OneOfTwo](https://api.haxeflixel.com/flixel/util/typeLimit/OneOfTwo.html)<[Int](https://api.haxe.org/Int.html), [String](https://api.haxe.org/String.html)>>):[Null](https://api.haxe.org/Null.html)<[Int](https://api.haxe.org/Int.html)>
- works like `Std.parseInt()`, but returns `null` if `Std.parseInt()` returns `NaN`
- for example: `"22".toInt()` will return `22`

15. toFloat(n:[Null](https://api.haxe.org/Null.html)<[OneOfTwo](https://api.haxeflixel.com/flixel/util/typeLimit/OneOfTwo.html)<[Float](https://api.haxe.org/Float.html), [String](https://api.haxe.org/String.html)>>):[Null](https://api.haxe.org/Null.html)<[Float](https://api.haxe.org/Float.html)>
- works like `Std.parseFloat()`, but returns `null` if `Std.parseFloat()` returns `NaN`
- for example: `"22.32".toFloat()` will return `22.32`

16. arrIsEmpty(str:[Array](https://api.haxe.org/Array.html)<[Dynamic](https://api.haxe.org/Dynamic.html)>, ?length:[Int](https://api.haxe.org/Int.html) = 1):[Bool](https://api.haxe.org/Bool.html)
- for example: `[].isEmpty()` returns `true`, `['123123'].isEmpty()` returns `false`

17. strIsEmpty(str:[String](https://api.haxe.org/String.html), ?length:[Int](https://api.haxe.org/Int.html) = 1):[Bool](https://api.haxe.org/Bool.html)
- for example: `"".isEmpty()` returns `true`, `"34".isEmpty()` returns `false`

18. toCMD(str:[String](https://api.haxe.org/String.html), format:[CMDFormat](util/WindowsCMDUtil.hx)):[String](https://api.haxe.org/String.html)
- formats `str` for using it in trace


## [Main](source/Main.hx)
- changes a default haxe trace to be colorable by methods `"sadds".toCMD(WHITE)`
- checks for default audio device disconnect and connects to new default audio device, can be got by `AudioUtil.currentAudioDevice` variable
- checks for dark mode change of windows (can be got by `isDarkMode` variable) and changes window color to dark if dark mode enabled
- changes title window color, can be changed by `titleWindowColorMode` variable
- adds `FlxG.cameras.cameraAdded` callback to set each new camera's `filters` variable to empty array
- adds some classes of this game to flixel debugger
- adds event listener on keyDown to do `onFullscreenChange.dispatch()` on fullscreen change, also sets `FlxG.stage.application.__backend.toggleFullscreen` to `false` of `fullscreenAllowed` is `false`

1. **static** defines:[Map](https://api.haxe.org/Map.html)<[String](https://api.haxe.org/String.html), [String](https://api.haxe.org/String.html)>
- variable added by `macros.Defines`, contains all defines of compiler even in runtime

2. **static** isDarkMode:[Bool](https://api.haxe.org/Bool.html)
- returns if dark mode is allowed on this system, works on Windows target only

3. **static** titleWindowColorMode:[Main.TitleWindowColorMode](source/Main.hx)
- Color mode of title window, works on Windows target only

4. **static** fullscreenAllowed:[Bool](https://api.haxe.org/Bool.html)
- if `false`, you cant change fullscreen by `Alt+Enter` or `F11`

5. **static** onFullscreenChange:[FlxSignal](https://api.haxeflixel.com/flixel/util/FlxSignal.html)
- dispatches on each fullscreen change

6. **static** setFramerate(value:[Int](https://api.haxe.org/Int.html)):[Void](https://api.haxe.org/Void.html)
- sets framerate of game and updates fps graph of flixel debugger

7. **static** println(str:[Dynamic](https://api.haxe.org/Dynamic.html)):[Void](https://api.haxe.org/Void.html)
- just a basic `Sys.println` but works on each target


## [backend.native.Windows](source/backend/native/Windows.hx) (New)
- cool api for Windows, able to changing border/caption/text color, removing maximize/minimize buttons
- will work only if player has windows 11 tho
- just go to that class to check all methods


## [backend.AudioUtil](source/backend/AudioUtil.hx) (New)
- default audio device switch fix, also traces connected audio device, has some bugs in song but on restart of song everything fine!


## [backend.ClientPrefs](source/backend/ClientPrefs.hx)
- added description to all vars in `ClientPrefs.data` / `ClientPrefs.gameplaySettings`
- rewritten `ClientPrefs.gameplaySettings`: now you can use `ClientPrefs.gameplaySettings.scrollspeed`


## [backend.CoolUtil](source/backend/CoolUtil.hx)
- `dominantColor` was rewritted cuz it dont work if gpu caching enabled, but now it works!
1. **static** setTextBorderFromString(text:[FlxText](https://api.haxeflixel.com/flixel/text/FlxText.html), border:[String](https://api.haxe.org/String.html)):[Void](https://api.haxe.org/Void.html)
- changes text border style from string, used by `setTextBorder` lua function

2. **static** tweenColor(Object:[Dynamic](https://api.haxe.org/Dynamic.html), Values:[Dynamic](https://api.haxe.org/Dynamic.html), ?Duration:[Float](https://api.haxe.org/Float.html) = 1, ?Options:Null<TweenOptions>):[NumTween](https://api.haxeflixel.com/flixel/tweens/misc/NumTween.html)
- Works like `FlxTween.color` and `FlxTween.tween`, but it can tween colors in every structure (`FlxTween.color` can work only with `FlxSprite`)

3. **static** getClassNameWithoutPath(obj:[Dynamic](https://api.haxe.org/Dynamic.html)):[String](https://api.haxe.org/String.html)
- returns class name without package path
- for example: `CoolUtil.getClassNameWithoutPath(new FlxObject())` will return `"FlxObject"`

4. **static** prettierNotFoundException(e:[Exception](https://api.haxe.org/haxe/Exception.html)):[String](https://api.haxe.org/String.html)
- returns haxe exception as string, but if error will be about file not existing it will return just `"Not found"`

5. **static** changeVarLooped(arr:[Array](https://api.haxe.org/Array.html)<[Dynamic](https://api.haxe.org/Dynamic.html)>, varr:[String](https://api.haxe.org/String.html), value:[Dynamic](https://api.haxe.org/Dynamic.html)):[Void](https://api.haxe.org/Void.html)
- changes variable with name `varr` to `value` value from `arr` array recursively (if member of `arr` array has `members` variable it will change from them too)


## [backend.transition](source/backend/transition)
- cool api for making transitions


## [backend.DiscordClient](source/backend/Discord.hx)
1. **static** presence.makeButton(id:[Int](https://api.haxe.org/Int.html), label:[String](https://api.haxe.org/String.html), url:[String](https://api.haxe.org/String.html)):[DiscordButton](https://github.com/MAJigsaw77/hxdiscord_rpc/blob/187c445/hxdiscord_rpc/Types.hx#L169)
- makes discord rpc button, `id` can be 0 or 1


## [backend.NullSafeJson](source/backend/NullSafeJson.hx) (New)
- this class works like basic Json class but doesnt crash when json parse error is occurred


## [backend.Paths](source/backend/Paths.hx)
- it was almost completely rewritted just go to that class to check how it works now lol
- support of loading .jpg images
- `trace` shows actual line where Paths method was called


## [backend.Song.SwagSong](source/Song.hx)
- accessible with `PlayState.SONG`
- to set song name properly use `Song.setSongName` method

1. **optional** songDisplay:[String](https://api.haxe.org/String.html)
- this will be displayed as song name everywhere, if `null` then will use `song`

2. **optional** path:[String](https://api.haxe.org/String.html)
- just a shortcut to `Paths.formatToSongPath(SONG.song)`


## [backend.WindowUtil](source/backend/AudioUtil.hx) (New)
- cool api for changing game size absolutely (without initial ratio)