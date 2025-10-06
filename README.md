## im not interested in psych engine anymore so no updates!
- use codename engine it has softcoded everything!

# Leer's Psych Mod Core
- i guess now it works properly

## Built on [Psych Engine 1.0](https://github.com/ShadowMario/FNF-PsychEngine/tree/7addb9c)
### [CHANGES](setup/changes.md)
### [BUILDING](setup/building.md)
- tl;dr - upgrade haxe to 4.3 or higher and do `haxe setup.hxml`

## Known issues
- `[WARNING] Could not parse frame number of %nameSub% in frame named %name%` => try use full prefix name (before `0001` and etc) in animation.addByPrefix
- `Bind failed` => do in powershell: `Get-Process Powershell | Where-Object { $_.ID -ne $pid } | Stop-Process`
- `Type not found : openfl._internal.macros` => remove `export` folder and recompile again
- some of cpp errors => remove `export` folder and recompile again
