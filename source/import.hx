#if !macro
import haxe.CallStack;
import backend.Json;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

import backend.FlxTextNoAntialiasing as FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
// you cant do flixel.text.FlxText.*; >:((((

import backend.ui.*; // Psych-UI
import backend.transition.BaseTransition;
#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end
import backend.Language;
import backend.Discord;
import backend.Song;
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Difficulty;
import backend.Mods;

import objects.Note;
import objects.Alphabet;
import objects.BGSprite;
import states.PlayState;
import stages.BaseStage.Countdown;

using shaders.Shaders;
import shaders.Shaders;
#end

using StringTools;
using util.StaticExtensions;
import util.StaticExtensions;
import util.WindowsCMDUtil.CMDFormat;