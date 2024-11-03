package;

import flixel.FlxGame;
import openfl.display.DisplayObject;
import haxe.ui.Toolkit;
import kec.objects.FrameCounter;
#if FEATURE_DISCORD
import kec.backend.Discord;
#end
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;
#if VIDEOS
import hxvlc.util.Handle;
#end
import openfl.utils.AssetCache;

using StringTools;

class Main extends Sprite
{
	final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: Init, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var mainClassState:Class<FlxState> = Init; // yoshubs jumpscare (I am aware of *the incident*)
	public static var focusMusicTween:FlxTween;
	public static var focused:Bool = true;

	public var hasWifi:Bool = true;

	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	// You can pretty much ignore everything from here on - your code should go in your states.
	private var curGame:FlxGame;

	public static var gameContainer:Main = null; // Main instance to access when needed.

	public var frameCounter:FrameCounter = null;

	public function new()
	{
		#if mobile
		#if android
		SUtil.doPermissionsShit();
		#end
		Sys.setCwd(SUtil.getStorageDirectory());
		#end

		mobile.kec.backend.CrashHandler.init();

		super();
		setupGame();
	}

	private function setupGame():Void
	{
		gameContainer = this;

		initHaxeUI();

		// Run this first so we can see logs.
		kec.backend.Debug.onInitProgram();

		frameCounter = new FrameCounter(10, 3, 0xFFFFFF);
		game.framerate = 60;
		curGame = new Game(game.width, game.height, game.initialState, game.framerate, game.skipSplash, game.startFullscreen);

		@:privateAccess
		curGame._customSoundTray = flixel.FunkinSoundTray;
		addChild(curGame);

		FlxG.fixedTimestep = false;

		addChild(frameCounter);
		fpsVisible(FlxG.save.data.fps);

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		FlxG.signals.gameResized.add(function(w, h)
			if (frameCounter != null)
				frameCounter.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height)));

		#if VIDEOS
		Handle.initAsync();
		#end

		// Finish up loading debug tools.
		Debug.onGameStart();
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
	}

	public function setFPSCap(cap:Int)
	{
		FlxG.updateFramerate = cap;
		FlxG.drawFramerate = FlxG.updateFramerate;
	}

	public inline function fpsVisible(visible:Bool)
		return gameContainer.frameCounter.visible = visible;

	public inline function setFPSPos(x:Int, y:Int)
	{
		gameContainer.frameCounter.x = x;
		gameContainer.frameCounter.y = y;
	}

	public inline function setFPSColor(col:Int)
		return gameContainer.frameCounter.textColor = col;

	public function checkInternetConnection()
	{
		Debug.logInfo('Checking Internet connection Through URL: "https://www.example.com".');
		var http = new haxe.Http("https://www.example.com");
		http.onStatus = function(status:Int)
		{
			switch status
			{
				case 200: // success
					hasWifi = true;
					Debug.logInfo('Connected.');
				default: // error
					hasWifi = false;
					Debug.logInfo('No Internet Connection.');
			}
		};

		http.onError = function(e)
		{
			hasWifi = false;
			Debug.logInfo('No Internet Connection.');
		}

		http.request();
	}

	function onWindowFocusOut()
	{
		focused = false;

		// Lower global volume when unfocused
		oldVol = FlxG.sound.volume;
		if (oldVol > 0.3)
			newVol = 0.3;
		else
		{
			if (oldVol > 0.1)
				newVol = 0.1;
			else
				newVol = 0;
		}

		if (focusMusicTween != null)
			focusMusicTween.cancel();
		focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

		// Conserve power by lowering draw framerate when unfocuced
		// was 30 but it might cause bugs
		FlxG.drawFramerate = 60;
	}

	function onWindowFocusIn()
	{
		FlxTimer.wait(0.2, function()
		{
			focused = true;
		});

		// Lower global volume when unfocused
		// Normal global volume when focused
		if (focusMusicTween != null)
			focusMusicTween.cancel();

		focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

		// Bring framerate back when focused
		gameContainer.setFPSCap(FlxG.save.data.fpsCap);
	}

	function initHaxeUI():Void
	{
		Toolkit.init();
		Toolkit.theme = 'dark'; // don't be cringe
		Toolkit.autoScale = false;
	}

	// Get rid of hit test function because mouse memory ramp up during first move (-Bolo)
	@:noCompletion private override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool,
			hitObject:DisplayObject):Bool
		return true;

	@:noCompletion override private function __hitTestHitArea(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool,
			hitObject:DisplayObject):Bool
		return true;

	@:noCompletion private override function __hitTestMask(x:Float, y:Float):Bool
		return true;
}
