package mobile.kec.backend;

import kec.backend.Options.Option;
import kec.substates.OptionsMenu;

class MobileControlsOption extends Option
{
	public function new(desc:String)
	{
		super();
		acceptType = true;
		if (OptionsMenu.isInPause)
		{
			blocked = true;
			description = pauseDesc;
		}
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.state.openSubState(new mobile.kec.substates.MobileControlsSelectSubState());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Mobile Controls";
	}
}

class ScreensaverOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		lime.system.System.allowScreenTimeout = !lime.system.System.allowScreenTimeout;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Allow Phone Screensaver: < " + (!lime.system.System.allowScreenTimeout ? "Disabled" : "Enabled") + " >";
	}
}

class MobileControlsOpacityOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
		{
			blocked = true;
			description = pauseDesc;
		}
		else
		{
			description = desc;
			acceptValues = true;
		}
	}

	private function check():Void
	{
		if (FlxG.save.data.mobileCAlpha < 0)
			FlxG.save.data.mobileCAlpha = 0;

		if (FlxG.save.data.mobileCAlpha > 1)
			FlxG.save.data.mobileCAlpha = 1;
	}

	override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.mobileCAlpha += 0.1;

		check();

		return true;
	}

	override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.mobileCAlpha -= 0.1;

		check();

		return true;
	}

	override function getValue():String
	{
		return "Mobile Controls Opacity: " + kec.backend.util.HelperFunctions.truncateFloat(FlxG.save.data.mobileCAlpha, 1);
	}
}

class HitboxDesignOption extends Option
{
	final hintOptions:Array<String> = ["No Gradient", "No Gradient (Old)", "Gradient", "Hidden"];

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
		{
			blocked = true;
			description = pauseDesc;
		}
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.hitboxType--;
		if (FlxG.save.data.hitboxType < 0)
			FlxG.save.data.hitboxType = hintOptions.length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.hitboxType++;
		if (FlxG.save.data.hitboxType > hintOptions.length - 1)
			FlxG.save.data.hitboxType = 0;
		display = updateDisplay();
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}

	public override function updateDisplay():String
	{
		return "Current Hitbox Design: < " + hintOptions[FlxG.save.data.hitboxType] + " >";
	}
}
