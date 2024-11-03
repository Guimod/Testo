package mobile.kec.objects;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import openfl.display.BitmapData;
import openfl.utils.Assets;

enum FlxDPadMode
{
	UP_DOWN;
	LEFT_RIGHT;
	LEFT_FULL;
	RIGHT_FULL;
	NONE;
}

enum FlxActionMode
{
	A;
	B;
	E;
	P;
	A_B;
	A_B_C;
	A_B_E;
	A_B_X_Y;
	A_B_C_X_Y;
	A_B_C_X_Y_Z;
	A_B_C_D_V_X_Y_Z;
	NONE;
}

/**
 * A gamepad.
 * It's easy to customize the layout.
 *
 * @author Ka Wing Chin
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class VirtualPad extends FlxTypedSpriteGroup<MobileButton>
{
	public var buttonLeft:MobileButton = new MobileButton(0, 0);
	public var buttonUp:MobileButton = new MobileButton(0, 0);
	public var buttonRight:MobileButton = new MobileButton(0, 0);
	public var buttonDown:MobileButton = new MobileButton(0, 0);

	public var buttonLeft2:MobileButton = new MobileButton(0, 0);
	public var buttonUp2:MobileButton = new MobileButton(0, 0);
	public var buttonRight2:MobileButton = new MobileButton(0, 0);
	public var buttonDown2:MobileButton = new MobileButton(0, 0);

	public var buttonA:MobileButton = new MobileButton(0, 0);
	public var buttonB:MobileButton = new MobileButton(0, 0);
	public var buttonC:MobileButton = new MobileButton(0, 0);
	public var buttonD:MobileButton = new MobileButton(0, 0);
	public var buttonE:MobileButton = new MobileButton(0, 0);
	public var buttonF:MobileButton = new MobileButton(0, 0);
	public var buttonG:MobileButton = new MobileButton(0, 0);
	public var buttonH:MobileButton = new MobileButton(0, 0);
	public var buttonI:MobileButton = new MobileButton(0, 0);
	public var buttonJ:MobileButton = new MobileButton(0, 0);
	public var buttonK:MobileButton = new MobileButton(0, 0);
	public var buttonL:MobileButton = new MobileButton(0, 0);
	public var buttonM:MobileButton = new MobileButton(0, 0);
	public var buttonN:MobileButton = new MobileButton(0, 0);
	public var buttonO:MobileButton = new MobileButton(0, 0);
	public var buttonP:MobileButton = new MobileButton(0, 0);
	public var buttonQ:MobileButton = new MobileButton(0, 0);
	public var buttonR:MobileButton = new MobileButton(0, 0);
	public var buttonS:MobileButton = new MobileButton(0, 0);
	public var buttonT:MobileButton = new MobileButton(0, 0);
	public var buttonU:MobileButton = new MobileButton(0, 0);
	public var buttonV:MobileButton = new MobileButton(0, 0);
	public var buttonX:MobileButton = new MobileButton(0, 0);
	public var buttonY:MobileButton = new MobileButton(0, 0);
	public var buttonZ:MobileButton = new MobileButton(0, 0);

	public var onButtonUp:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();
	public var onButtonDown:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		super();

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 255, 'up', 0x00FF00));
				add(buttonDown = createButton(0, FlxG.height - 135, 'down', 0x00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 135, 'left', 0xFF00FF));
				add(buttonRight = createButton(127, FlxG.height - 135, 'right', 0xFF0000));
			case LEFT_FULL:
				add(buttonUp = createButton(105, FlxG.height - 345, 'up', 0x00FF00));
				add(buttonLeft = createButton(0, FlxG.height - 243, 'left', 0xFF00FF));
				add(buttonRight = createButton(207, FlxG.height - 243, 'right', 0xFF0000));
				add(buttonDown = createButton(105, FlxG.height - 135, 'down', 0x00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 258, FlxG.height - 408, 'up', 0x00FF00));
				add(buttonLeft = createButton(FlxG.width - 384, FlxG.height - 309, 'left', 0xFF00FF));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 309, 'right', 0xFF0000));
				add(buttonDown = createButton(FlxG.width - 258, FlxG.height - 201, 'down', 0x00FFFF));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case B:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 135, 'b', 0xFFCB00));
			case E:
				add(buttonE = createButton(FlxG.width - 132, FlxG.height - 135, 'e', 0xFF7D00));
			case P:
				add(buttonP = createButton(FlxG.width - 132, 0, 'x', 0x99062D));
			case A_B:
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_C:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 'c', 0x44FF00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_E:
				add(buttonE = createButton(FlxG.width - 384, FlxG.height - 135, 'e', 0xFF7D00));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_X_Y:
				add(buttonX = createButton(FlxG.width - 510, FlxG.height - 135, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 384, FlxG.height - 135, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_C_X_Y:
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 'c', 0x44FF00));
				add(buttonX = createButton(FlxG.width - 258, FlxG.height - 255, 'x', 0x99062D));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 255, 'y', 0x4A35B9));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_C_X_Y_Z:
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case A_B_C_D_V_X_Y_Z:
				add(buttonV = createButton(FlxG.width - 510, FlxG.height - 255, 'v', 0x49A9B2));
				add(buttonD = createButton(FlxG.width - 510, FlxG.height - 135, 'd', 0x0078FF));
				add(buttonX = createButton(FlxG.width - 384, FlxG.height - 255, 'x', 0x99062D));
				add(buttonC = createButton(FlxG.width - 384, FlxG.height - 135, 'c', 0x44FF00));
				add(buttonY = createButton(FlxG.width - 258, FlxG.height - 255, 'y', 0x4A35B9));
				add(buttonB = createButton(FlxG.width - 258, FlxG.height - 135, 'b', 0xFFCB00));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 255, 'z', 0xCCB98E));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 135, 'a', 0xFF0000));
			case NONE: // do nothing
		}

		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();
		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), MobileButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}

	private function createButton(X:Float, Y:Float, Graphic:String, Color:Int = 0xFFFFFF):MobileButton
	{
		var graphic:FlxGraphic;

		if (Assets.exists(Paths.getPath('images/virtualpad/${Graphic}.png')))
			graphic = FlxG.bitmap.add(Paths.getPath('images/virtualpad/${Graphic}.png'));
		else
			graphic = FlxG.bitmap.add(Paths.getPath('images/virtualpad/default.png'));

		var button:MobileButton = new MobileButton(X, Y);
		button.frames = FlxTileFrames.fromGraphic(graphic, FlxPoint.get(Std.int(graphic.width / 2), graphic.height));
		button.solid = false;
		button.immovable = true;
		//button.moves = false;
		button.antialiasing = FlxG.save.data.antialiasing;
		button.scrollFactor.set();
		button.color = Color;
		button.alpha = FlxG.save.data.mobileCAlpha;
		button.onDown.callback = button.onOver.callback = () -> onButtonDown.dispatch(button);
		button.onUp.callback = button.onOut.callback = () -> onButtonUp.dispatch(button);
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		return button;
	}
}
