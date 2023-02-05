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
	/**
	 * Returns all the languages
	 * English, Español
	 * @return Array<String>
	 */
	public static function getLanguages():Array<String> {
		return ['English', 'Español'];
	}

	// strings
	/**
	 * Returns the spanish in the selected LanguageString. If the string's spanish is null, returns the english one
	 * @param s 
	 * @return String
	 */
	public static function getSpanish(s:LanguageString):String {
		if(s.spanish != null)
			return s.spanish;
		return s.s;
	}
	/**
	 * Returns the german in the selected LanguageString. If the string's german is null, returns the english one
	 * @param s 
	 * @return String
	 */
	public static function getGerman(s:LanguageString):String {
		if(s.german != null)
			return s.german;
		return s.s;
	}

	/**
	 * Returns the correct string depending of ClientPrefs.language
	 * @param s 
	 * @return String
	 */
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
	/**
	 * Returns the spanish in the selected LanguageArray. If the array's spanish is null, returns the english one
	 * @param a 
	 * @return Array<String>
	 */
	public static function getArraySpanish(a:LanguageArray):Array<String> {
		if(a.spanish != null)
			return a.spanish;
		return a.a;
	}
	/**
	 * Returns the spanish in the selected Array<LanguageString> (array of LanguageString). If the array's spanish is null, returns the english one
	 * @param a 
	 * @return Array<LanguageString>
	 */
	public static function getStringArraySpanish(a:Array<LanguageString>):Array<String> {
		var t:Array<String> = [];
		for(i in a) {
			t.push(getSpanish(i));
		}
		return t;
	}
	/**
	 * Returns the german in the selected LanguageArray. If the array's german is null, returns the english one
	 * @param a 
	 * @return Array<String>
	 */
	public static function getArrayGerman(a:LanguageArray):Array<String> {
		if(a.german != null)
			return a.german;
		return a.a;
	}
	/**
	 * Returns the german in the selected Array<LanguageString> (array of LanguageString). If the array's german is null, returns the english one
	 * @param a 
	 * @return Array<LanguageString>
	 */
	public static function getStringArrayGerman(a:Array<LanguageString>):Array<String> {
		var t:Array<String> = [];
		for(i in a) {
			t.push(getGerman(i));
		}
		return t;
	}

	/**
	 * Returns the correct array depending of ClientPrefs.language
	 * @param a 
	 * @return Array<String>
	 */
	public static function getArray(a:LanguageArray):Array<String> {
		switch(ClientPrefs.language) {
			case 'Español':
				return getArraySpanish(a);
			case 'Deutsch':
				return getArrayGerman(a);
		}
		return a.a;
	}
	/**
	 * Returns the correct Array depending of ClientPrefs.language
	 * @param a 
	 * @return Array<String>
	 */
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
