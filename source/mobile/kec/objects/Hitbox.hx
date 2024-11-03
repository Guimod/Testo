package mobile.kec.objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class Hitbox extends FlxSpriteGroup
{
	public var buttonLeft:MobileButton = new MobileButton(0, 0);
	public var buttonDown:MobileButton = new MobileButton(0, 0);
	public var buttonUp:MobileButton = new MobileButton(0, 0);
	public var buttonRight:MobileButton = new MobileButton(0, 0);

	public var onHintUp:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();
	public var onHintDown:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();

	/**
	 * Create the zone.
	 * 
	 * @param ammo The ammount of hints you want to create.
	 * @param perHintWidth The width that the hints will use.
	 * @param perHintHeight The height that the hints will use.
	 * @param colors The color per hint.
	 */
	public function new():Void
	{
		super();

		add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
		add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
		add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
		add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));

		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):MobileButton
	{
		final guh:Float = FlxG.save.data.mobileCAlpha >= 0.9 ? FlxG.save.data.mobileCAlpha - 0.2 : FlxG.save.data.mobileCAlpha;
		final guh2:Float = 0.00001;
		var hint:MobileButton = new MobileButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.label = new FlxSprite();
		hint.labelStatusDiff = (FlxG.save.data.hitboxType != '3') ? guh : guh2;
		hint.label.loadGraphic(createHintGraphic(Width, Math.floor(Height * 0.035), Color, true));
		hint.label.offset.y -= (hint.height - hint.label.height);
		hint.solid = false;
		hint.multiTouch = true;
		hint.immovable = true;
		hint.moves = false;
		hint.antialiasing = FlxG.save.data.antialiasing;
		hint.scrollFactor.set();
		hint.label.alpha = hint.alpha = guh2;
		hint.canChangeLabelAlpha = false;
		if (FlxG.save.data.hitboxType != '3')
		{
			var hintTween:FlxTween = null;
			var hintLaneTween:FlxTween = null;

			hint.onDown.callback = function()
			{
				onHintDown.dispatch(hint);

				if (hintTween != null)
					hintTween.cancel();

				if (hintLaneTween != null)
					hintLaneTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: guh}, guh / 100, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});

				hintLaneTween = FlxTween.tween(hint.label, {alpha: guh2}, guh / 10, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}

			hint.onOut.callback = hint.onUp.callback = function()
			{
				onHintUp.dispatch(hint);

				if (hintTween != null)
					hintTween.cancel();

				if (hintLaneTween != null)
					hintLaneTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: guh2}, guh / 10, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});

				hintLaneTween = FlxTween.tween(hint.label, {alpha: guh}, guh / 100, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF, ?isLane:Bool = false):BitmapData
	{
		var guh:Float = FlxG.save.data.mobileCAlpha;
		if (guh >= 0.9)
			guh = FlxG.save.data.mobileCAlpha - 0.07;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		if (FlxG.save.data.hitboxType == '0')
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(Width, Height, 0, 0, 0);

			if (isLane)
				shape.graphics.beginFill(Color);
			else
				shape.graphics.beginGradientFill(RADIAL, [Color, Color], [0, guh], [60, 255], matrix, PAD, RGB, 0);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else if (FlxG.save.data.hitboxType == '1')
		{
			shape.graphics.lineStyle(10, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else // if (FlxG.save.data.hitboxType == '2')
		{
			shape.graphics.lineStyle(3, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			if (isLane)
				shape.graphics.beginFill(Color);
			else
				shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}
		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape, true);
		return bitmap;
	}
}
