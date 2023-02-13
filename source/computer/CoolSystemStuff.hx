package computer;

// crazy system shit!!!!!
// lordryan wrote this :) (erizur added cross platform env vars)
// wither made this more stable
import sys.io.File;
import sys.io.Process;
import haxe.io.Bytes;

/** BE CAREFUL!!! THIS COULD FLAG YOUR MOD AS VIRUS IF YOU DONT USE IT WISELY!!!!
*/
class CoolSystemStuff
{
	public static function getUsername():String
	{
		if(!ClientPrefs.safeMode) {
			// uhh this one is self explanatory
			#if windows
			return Sys.getEnv("USERNAME");
			#else
			return Sys.getEnv("USER");
			#end
		}
		return 'NOPE';
	}

	public static function getUserPath():String
	{
		if(!ClientPrefs.safeMode) {
			// this one is also self explantory
			#if windows
			return Sys.getEnv("USERPROFILE");
			#else
			return Sys.getEnv("HOME");
			#end
		}
		return 'NOPE';
	}

	public static function getTempPath():String
	{
		if(!ClientPrefs.safeMode) {
			// gets appdata temp folder lol
			#if windows
			return Sys.getEnv("TEMP");
			#else
			// most non-windows os dont have a temp path, or if they do its not 100% compatible, so the user folder will be a fallback
			return Sys.getEnv("HOME");
			#end
		}
		return 'NOPE';
	}
	public static function executableFileName()
	{
		#if windows
		var programPath = Sys.programPath().split("\\");
		#else
		var programPath = Sys.programPath().split("/");
		#end
		return programPath[programPath.length - 1];
	}
}
