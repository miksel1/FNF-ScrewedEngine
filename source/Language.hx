package;

@:structInit
typedef LanguageString = {
	var s:String;
	@:optional var spanish:String;
	@:optional var german:String;
}

@:structInit
typedef LanguageArray = {
	var a:Array<String>;
	@:optional var spanish:Array<String>;
	@:optional var german:Array<String>;
}

@:structInit
typedef LanguageDynamic = {
	var d:Dynamic;
	@:optional var spanish:Dynamic;
	@:optional var german:Dynamic;
}

class Language {
	public static function getLanguages():Array<String> {
		return ['English', 'Español'];
	}

	// strings
	public static function getSpanish(s:LanguageString):String {
		if(s.spanish != null)
			return s.spanish;
		return s.s;
	}
	public static function getGerman(s:LanguageString):String {
		if(s.german != null)
			return s.german;
		return s.s;
	}

	public static function getString(s:LanguageString):String {
		switch(ClientPrefs.language) {
			case 'Español':
				return getSpanish(s);
			case 'Deutsch':
				return getGerman(s);
		}
		return s.s;
	}
	public static function stringEqual(s:LanguageString, a:Array<String>) {
		return a.contains(getString(s));
	}

	// arrays
	public static function getArraySpanish(a:LanguageArray):Array<String> {
		if(a.spanish != null)
			return a.spanish;
		return a.a;
	}
	public static function getStringArraySpanish(a:Array<LanguageString>):Array<String> {
		var t:Array<String> = [];
		for(i in a) {
			t.push(getSpanish(i));
		}
		return t;
	}
	public static function getArrayGerman(a:LanguageArray):Array<String> {
		if(a.german != null)
			return a.german;
		return a.a;
	}
	public static function getStringArrayGerman(a:Array<LanguageString>):Array<String> {
		var t:Array<String> = [];
		for(i in a) {
			t.push(getGerman(i));
		}
		return t;
	}

	public static function getArray(a:LanguageArray):Array<String> {
		switch(ClientPrefs.language) {
			case 'Español':
				return getArraySpanish(a);
			case 'Deutsch':
				return getArrayGerman(a);
		}
		return a.a;
	}
	public static function getStringArray(a:Array<LanguageString>):Array<String> {
		switch(ClientPrefs.language) {
			case 'Español':
				return getStringArraySpanish(a);
			case 'Deutsch':
				return getStringArrayGerman(a);
		}
		var t:Array<String> = [];
		for(i in a) {
			t.push(i.s);
		}
		return t;
	}

	// dynamics
	public static function getDynamicSpanish(d:LanguageDynamic):Dynamic {
		if(d.spanish != null)
			return d.spanish;
		return d.d;
	}
	public static function getDynamicGerman(d:LanguageDynamic):Dynamic {
		if(d.german != null)
			return d.german;
		return d.d;
	}
	public static function getDynamic(d:LanguageDynamic):Dynamic {
		switch(ClientPrefs.language) {
			case 'Español':
				return getDynamicSpanish(d);
			case 'Deutsch':
				return getDynamicGerman(d);
		}
		return d.d;
	}
}
