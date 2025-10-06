## Useful tips to work with code
- to show cached assets in cmd just do `lime test windows -debug -D TRACE_CACHED_ASSETS`
- to load song in game start just do `lime test windows -debug -DSONG=<song>`
- to go to traced line just press Ctrl + LMB on name of file in terminal
<img src="setup/images/building_tracedfile.png" />

## Compiling
1. Install Haxe [4.3.2](https://haxe.org/download/version/4.3.2/)
2. Install [Git](https://git-scm.com/download/)
3. Go to [this](#setting-up-visual-studio-code-for-source-code-editing) if you wanna use VS Code for editing
4. Open cmd/powershell/terminal in folder where `Project.xml`
5. Run command: `haxe setup.hxml`
6. Run command: `lime test <target>`, replacing `<target>` with the platform you want to build to (`windows`, `mac`, `linux`) (i.e. `lime test windows`)
7. Now wait bunch of time (next compiles will be a much faster)
8. To send build to someone just go to folder: `export/release/<target>/bin` (if you added `-debug` flag then `export/debug/<target>/bin`)

## Setting up Visual Studio Code for source code editing
1. Install [VS Code](https://code.visualstudio.com/) with ALL checked checkboxes
2. Open VS Code in directory where `Project.xml`
- You can open it by pressing `Open with Code` when right click on folder
3. Install some useful extensions (press Ctrl+Shift+X):
- [Haxe](https://marketplace.visualstudio.com/items?itemName=nadako.vshaxe)
- [Haxe Extension Pack](https://marketplace.visualstudio.com/items?itemName=vshaxe.haxe-extension-pack)
- [Lime](https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension)
- [quick-run-panel](https://marketplace.visualstudio.com/items?itemName=davehart.quick-run-panel) - if you wanna have handy run tasks in explorer
- [Funkin Script AutoCompleter](https://marketplace.visualstudio.com/items?itemName=Snirozu.funkin-script-autocompleter) - if you wanna edit .lua files
- [Shader languages support for VS Code](https://marketplace.visualstudio.com/items?itemName=slevesque.shader) - if you wanna edit .frag/.vert files
4. Restart VS Code if needed
5. See that `HTML5` word below? Click on it and choose your compile target (i.e. `Windows`)
6. Now you have very useful autocompleter for functions, just start type smth like `Flx` in .hx files

## Known issues
- `Bind failed` => do in powershell: `Get-Process Powershell | Where-Object { $_.ID -ne $pid } | Stop-Process`
- `Type not found : openfl._internal.macros` => remove `export` folder and recompile again
- some of cpp errors => remove `export` folder and recompile again