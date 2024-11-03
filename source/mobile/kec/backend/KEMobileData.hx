package mobile.kec.backend;

import flixel.util.FlxSave;

class KEMobileData
{
	public static function initSave()
	{
		if (FlxG.save.data.mobileCMode == null)
			FlxG.save.data.mobileCMode = 'Hitbox';

		if (FlxG.save.data.mobileCAlpha == null)
			FlxG.save.data.mobileCAlpha = #if mobile 0.6 #else 0 #end;

		if (FlxG.save.data.hitboxType == null)
			FlxG.save.data.hitboxType = 0;
	}
}
