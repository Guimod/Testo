package mobile.kec.backend.utils;

#if sys
import lime.system.System as LimeSystem;
import haxe.Exception;
import lime.app.Application;
import sys.io.File;
import sys.FileSystem;
import openfl.utils.Assets;

/**
 * A storage class for mobile.
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class SUtil
{
	public static function getStorageDirectory():String
	{
		var daPath:String = '';
		#if android
		daPath = AndroidVersion.SDK_INT > AndroidVersionCode.R ? AndroidContext.getObbDir() : AndroidContext.getExternalFilesDir();
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#else
		daPath = Sys.getCwd();
		#end

		return daPath;
	}

	public static function mkDirs(directory:String):Void
	{
		try {
			if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
				return;
		} catch (e:haxe.Exception) {
			trace('Something went wrong while looking at folder. (${e.message})');
		}

		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:Exception)
					trace('Error while creating folder. (${e.message}');
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgor to add somethin\' in yo code :3'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			showPopUp("Success!", fileName + " file has been saved.");
		}
		catch (e:Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	#if android
	public static function doPermissionsShit():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
				AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES'))
			|| (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU
				&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');

		try
		{
			if (!FileSystem.exists(SUtil.getStorageDirectory()))
				mkDirs(SUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			showPopUp('Please create directory to\n' + SUtil.getStorageDirectory() + '\nPress OK to close the game', 'Error!');
			LimeSystem.exit(1);
		}
	}
	#end

	public static function showPopUp(message:String, ?title:String):Void
	{
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#elseif windows
		kec.backend.cpp.CPPInterface.messageBox(message, title);
		#elseif (!ios || !iphonesim)
		lime.app.Application.current.window.alert(message, title);
		#else
		trace('$title - $message');
		#end
	}
}
#end
