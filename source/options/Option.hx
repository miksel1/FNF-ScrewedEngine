package options;

import Language.LanguageString;

using StringTools;

class Option
{
	private var child:Alphabet;
	public var text(get, set):String;
	/**
	 * Pressed enter (on Bool type options) or pressed/held left/right (on other types)
	 */
	public var onChange:Void->Void = null;

	/**
	 * bool, int (or integer), float (or fl), percent, string (or str)
	 * Bool will use checkboxes
	 * Everything else will use a text
	 */
	public var type(get, default):String = 'bool';

	public var showBoyfriend:Bool = false;
	/**
	 * Only works on int/float, defines how fast it scrolls per second while HOLDING left/right
	 */
	public var scrollSpeed:Float = 50;

	/**
	 * Variable from ClientPrefs.hx
	 */
	private var variable:String = null;
	public var defaultValue:Dynamic = null;

	/**
	 * Dont change this
	 */
	public var curOption:Int = 0;
	/**
	 * Only used in string type
	 */
	public var options:Array<String> = null;
	/**
	 * Only used in int/float/percent type, how much is changed when you PRESS
	 */
	public var changeValue:Dynamic = 1;
	/**
	 * Only used in int/float/percent type, how much is changed when you HOLD and PRESS SHIFT
	 */
	public var changeValueShift:Dynamic = 2;
	/**
	 * Only used in int/float/percent type
	 */
	public var minValue:Dynamic = null;
	/**
	 * Only used in int/float/percent type
	 */
	public var maxValue:Dynamic = null;
	/**
	 * Only used in float/percent type
	 */
	public var decimals:Int = 1;

	/**
	 * How String/Float/Percent/Int values are shown
	 * %v = Current value, %d = Default value
	 */
	public var displayFormat:String = '%v';
	public var description:LanguageString = {s: ''};
	public var name:LanguageString = {s: 'Unknown', spanish: 'Desconocido'};

	/**
	 * If its like that, change alpha no a lower value
	 */
	public var notShowIf:Null<{clientName:String, value:Dynamic}> = null;

	public var id:String = '';
	public function new(name:LanguageString, description:LanguageString, variable:String, type:String = 'bool', defaultValue:Dynamic = 'null variable value', ?options:Array<String>)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;

		if(defaultValue == 'null variable value')
		{
			switch(type)
			{
				case 'bool':
					defaultValue = false;
				case 'int' | 'float':
					defaultValue = 0;
				case 'percent':
					defaultValue = 1;
				case 'string':
					defaultValue = '';
					if(/*Language.getArray(*/options/*)*/.length > 0) {
						defaultValue = /*Language.getArray(*/options/*)*/[0];
					}
			}
		}

		if(getValue() == null) {
			setValue(defaultValue);
		}

		switch(type)
		{
			case 'string':
				var num:Int = /*Language.getArray(*/options/*)*/.indexOf(getValue());
				if(num > -1) {
					curOption = num;
				}
	
			case 'percent':
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
		}
	}

	public function change()
	{
		//nothing lol
		if(onChange != null) {
			onChange();
		}
	}

	public function getValue():Dynamic
	{
		return Reflect.getProperty(ClientPrefs, variable);
	}
	public function setValue(value:Dynamic)
	{
		Reflect.setProperty(ClientPrefs, variable, value);
	}

	public function setChild(child:Alphabet)
	{
		this.child = child;
	}

	private function get_text()
	{
		if(child != null) {
			return child.text;
		}
		return null;
	}
	private function set_text(newValue:String = '')
	{
		if(child != null) {
			child.text = newValue;
		}
		return null;
	}

	private function get_type()
	{
		var newValue:String = 'bool';
		switch(type.toLowerCase().trim())
		{
			case 'int' | 'float' | 'percent' | 'string': newValue = type;
			case 'integer': newValue = 'int';
			case 'str': newValue = 'string';
			case 'fl': newValue = 'float';
		}
		type = newValue;
		return type;
	}
}