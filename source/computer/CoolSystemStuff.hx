package computer;

// crazy system shit!!!!!
// lordryan wrote this :) (erizur added cross platform env vars)
// wither deleted it all, sorry but no!
import sys.io.File;
import sys.io.Process;
import haxe.io.Bytes;

class CoolSystemStuff
{
	public static function getUsername():String
	{
		return 'no more, thanks';
	}

	public static function getUserPath():String
	{
		return 'no more, thanks';
	}

	public static function getTempPath():String
	{
		return 'no more, thanks';
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