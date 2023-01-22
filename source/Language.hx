package;

typedef LanguageString = {
	var s:String;
	@:optional var spanish:String;
}

typedef LanguageArray = {
	var a:Array<String>;
	@:optional var spanish:Array<String>;
}

/*typedef LanguageDynamic = {
	var d:Dynamic;
	@:optional var spanish:Dynamic;
}*/

class Language {
	public static function getLanguages():Array<String> {
		return ['English', 'Español'];
	}

	public static function getSpanish(s:LanguageString):String {
		if(s.spanish != null)
			return s.spanish;
		return s.s;
	}

	public static function getString(s:LanguageString):String {
		if(ClientPrefs.language == 'Spanish') {
			return getSpanish(s);
		}
		return s.s;
	}

	public static function getArraySpanish(a:LanguageArray):Array<String> {
		if(a.spanish != null)
			return a.spanish;
		return a.a;
	}

	public static function getArray(a:LanguageArray):Array<String> {
		if(ClientPrefs.language == 'Spanish') {
			return getArraySpanish(a);
		}
		return a.a;
	}
}