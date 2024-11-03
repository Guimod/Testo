package kec.substates;

import kec.backend.chart.TimingStruct;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import kec.backend.Controls;
import kec.backend.PlayerSettings;
import mobile.kec.objects.VirtualPad;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;

	// Tween And Timer Manager. Don't Mess With These.
	public var tweenManager:FlxTweenManager;
	public var timerManager:FlxTimerManager;

	public function new()
	{
		instance = this;

		// Setup The Tween / Timer Manager.
		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();
		super();
	}

	override function destroy()
	{
		removeVirtualPad();
		removeMobileControls();

		timerManager.clear();
		tweenManager.clear();

		super.destroy();
	}

	override function close() {
		//if (virtualPad != null)
			removeVirtualPad();

		super.close();
	}

	override function create()
	{
		FlxG.mouse.enabled = true;
		super.create();
	}

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var mobileControls:MobileControls;
	public var virtualPad:VirtualPad;
	public var camControls:FlxCamera;
	public var camVPad:FlxCamera;

	var trackedInputsMobileControls:Array<FlxActionInput> = [];
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		if (virtualPad != null)
			removeVirtualPad();

		virtualPad = new VirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPadUI(virtualPad, DPad, Action);
		trackedInputsVirtualPad = controls.trackedInputsUI;
		controls.trackedInputsUI = [];
	}

	public function removeVirtualPad():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addMobileControls(DefaultDrawTarget:Bool = false):Void
	{
		if (mobileControls != null)
			removeMobileControls();

		mobileControls = new MobileControls();

		switch (MobileControls.mode)
		{
			case 'Pad-Right' | 'Pad-Left' | 'Pad-Custom':
				controls.setVirtualPadNOTES(mobileControls.virtualPad, RIGHT_FULL, NONE);
			case 'Hitbox':
				controls.setHitbox(mobileControls.hitbox);
			default: // do nothing
		}

		trackedInputsMobileControls = controls.trackedInputsNOTES;
		controls.trackedInputsNOTES = [];

		camControls = new FlxCamera();
		camControls.bgColor.alpha = 0;
		FlxG.cameras.add(camControls, DefaultDrawTarget);

		mobileControls.cameras = [camControls];
		mobileControls.visible = false;
		add(mobileControls);
	}

	public function removeMobileControls()
	{
		if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

		if (mobileControls != null)
			remove(mobileControls);
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = false):Void
	{
		if (virtualPad == null)
			return;

		camVPad = new FlxCamera();
		camVPad.bgColor.alpha = 0;
		FlxG.cameras.add(camVPad, DefaultDrawTarget);
		virtualPad.cameras = [camVPad];
	}

	public function addThePads():Void {}

	var oldStep:Int = 0;

	var curDecimalBeat:Float = 0;

	override function update(elapsed:Float)
	{
		// DO NOT COMMENT THIS OUT.
		tweenManager.update(elapsed);
		timerManager.update(elapsed);

		curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
		curBeat = Math.floor(curDecimalBeat);
		curStep = Math.floor(curDecimalBeat * 4);

		if (oldStep != curStep)
		{
			stepHit();
			oldStep = curStep;
		}

		super.update(elapsed);

		var fullscreenBind = FlxKey.fromString(FlxG.save.data.fullscreenBind);

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = timerManager;
		return timer.start(Time, OnComplete, Loops);
	}
}
