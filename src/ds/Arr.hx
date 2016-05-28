package ds;

import haxe.macro.Expr.ExprOf;

#if (flash || as3)

abstract Arr<T>(flash.Vector<T>) from flash.Vector<T>
{
	public var length(get, never):Int;
	
	public inline function new(?length:UInt)
	{
		this = new flash.Vector<T>(length, false);
	}
		
	@:arrayAccess
	public inline function get(no:Int):T
	{
		return this[no];
	}
	
	@:arrayAccess
	public inline function set(no:Int, item:T):Void
	{
		this[no] = item;
	}
		
	public inline function iterator():ArrIterator<T>
	{
		return new ArrIterator(this, 0);
	}
	
	public inline function push(item:T):Int
	{
		var l = this.length;
		this[l] = item;
		return l;
	}
	
	public inline function pop(item:T):T
	{
		return this[this.length-- - 1];
	}
	
	public inline function indexOf(item:T):Int
	{
		var result = -1;
		var i = 0;
		var l = this.length;
		while (i < l)
		{
			if (item == this[i++])
			{
				result = i - 1;
				break;
			}
		}
		return result;
	}
	
	public inline function lastIndexOf(item:T):Int
	{
		var result = -1;
		var i = this.length - 1;
		while (i > 0)
		{
			if (item == this[i--])
			{
				result = i + 1;
				break;
			}
		}
		return result;
	}
	
	public inline function has(item:T):Bool
	{
		return indexOf(item) >= 0;
	}
	
	public inline function remove(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			splice(i);
		}
		return isFinded;
	}
	
	public inline function removeByLast(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			spliceByLast(i);
		}
		return isFinded;
	}
	
	public inline function splice(i:Int):Void
	{
		var newLength = this.length - 1;
		while (i < newLength)
		{
			this[i] = this[i + 1];
			i++;
		}
		this.length = newLength;
	}
	
	public inline function spliceByLast(i:Int):Void
	{
		var newLength = this.length - 1;
		this[i] = this[newLength];
		this.length = newLength;
	}
	
	inline function get_length():Int
	{
		return this.length;
	}
}

#else

abstract Arr<T>(Array<T>) from Array<T>
{
	public var length(get, never):Int;
	
	public inline function new(length:UInt = 0)
	{
		this = [];
	}
		
	@:arrayAccess
	public inline function get(no:Int):T
	{
		return this[no];
	}
	
	@:arrayAccess
	public inline function set(no:Int, item:T):Void
	{
		this[no] = item;
	}
		
	public inline function iterator():ArrIterator<T>
	{
		return new ArrIterator(this, 0);
	}
	
	public inline function push(item:T):Int
	{
		var l = this.length;
		this[l] = item;
		return l;
	}
	
	public inline function pop(item:T):T
	{
		return this.pop();
	}
	
	public inline function indexOf(item:T):Int
	{
		var result = -1;
		var i = 0;
		var l = this.length;
		while (i < l)
		{
			if (item == this[i++])
			{
				result = i - 1;
				break;
			}
		}
		return result;
	}
	
	public inline function lastIndexOf(item:T):Int
	{
		var result = -1;
		var i = this.length - 1;
		while (i > 0)
		{
			if (item == this[i--])
			{
				result = i + 1;
				break;
			}
		}
		return result;
	}
	
	public inline function has(item:T):Bool
	{
		return indexOf(item) >= 0;
	}
	
	public inline function remove(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			splice(i);
		}
		return isFinded;
	}
	
	public inline function removeByLast(item:T):Bool
	{
		var i = indexOf(item);
		var isFinded = i >= 0;
		if (isFinded)
		{
			spliceByLast(i);
		}
		return isFinded;
	}
	
	public inline function splice(i:Int):Void
	{
		this.splice(i, 1);
	}
	
	public inline function spliceByLast(i:Int):Void
	{
		var newLength = this.length - 1;
		this[i] = this[newLength];
		this.splice(i, newLength);
	}
	
	inline function get_length():Int
	{
		return this.length;
	}
}

#end

class ArrIterator<T>
{
	public inline function new(arr:ConstArr<T>, firstNo:Int)
	{
		_arr = arr;
		_no = firstNo;
	}
	
	public inline function hasNext():Bool
	{
		return _no < _arr.length;
	}
	
	public inline function next():T
	{
		return _arr[_no++];
	}
	
	var _arr:ConstArr<T>;
	var _no:Int;
}

@:forward(length, iterator)
abstract ConstArr<T>(Arr<T>) from Arr<T>
{
	public inline function new(arr:Arr<T>)
	{
		this = arr;
	}
	
	@:arrayAccess public inline function get(no:Int):T
	{
		return this[no];
	}
}