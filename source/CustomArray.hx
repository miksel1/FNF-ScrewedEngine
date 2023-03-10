package;

/**
 * Just trying to make freeplay sections work...
 * @author Wither362
 */
class CustomArray<E> {
	public var elements:Array<E> = [];

	/**
	 * If it returns `false`, the item is not added.
	 */
	public var whenPushed:(element:E)->Null<Bool>;
	public var whenWannaIterate:()->Null<Array<E>>;
	public var whenWannaGet:()->Null<Array<E>>;
	public var whenWannaLength:()->Null<Array<E>>;



	public var length(get, null):Int;
	inline function get_length():Int {
		var toIterate:Array<E> = this.elements;
		var maybeIterator = whenWannaLength();
		if(maybeIterator != null) {
			toIterate = maybeIterator;
		}
		return toIterate.length;
	}
	public function new(elements: Array<E>) {
		this.elements = elements;
		this.whenWannaIterate = function() {return this.elements;};
		this.whenWannaGet = function() {return this.elements;};
		this.whenPushed = function(_) {return true;}
	}
	/**
		Returns an iterator of the Array values.
	**/
	@:runtime inline public function iterator():haxe.iterators.ArrayIterator<E> {
		var toIterate:Array<E> = this.elements;
		var maybeIterator = whenWannaIterate();
		if(maybeIterator != null) {
			toIterate = maybeIterator;
		}
		return new haxe.iterators.ArrayIterator(toIterate);
	}

	public function push(element:E) {
		var yess = whenPushed(element);
		if(yess || yess == null) {
			elements.push(element);
		}
	}
	public function get(index:Int):E {
		var toGet:Array<E> = this.elements;
		var maybeGet = whenWannaGet();
		if(maybeGet != null) {
			toGet = maybeGet;
		}
		return toGet[index];
	}

	public static function getArray(map:Map<Dynamic, Dynamic>) {
		var ska:Array<String> = [];
		if(map != null)
			if(map.keys() != null)
				for (i in map.keys()) {
					ska.push(map.get(i));
				}
		return ska;
	}
}