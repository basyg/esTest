package;

import ds.Arr.ConstArr;
import es.Entity;
import es.EntitySystem;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import flash.events.Event;
import flash.geom.Rectangle;
import haxe.Timer;

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		start();
		stage.addEventListener(Event.ENTER_FRAME, function(e) update());
	}
	
	static var es = new EntitySystem();
	static var movingSystem = new MovingSystem(es);
	static var boundingSystem = new BoundingSystem(es);
	static var displaySystem = new DisplaySystem(es);
	
	static function start()
	{
		for (i in 0...10000) 
		{
			var entity = es.createEntity();
			makeSquare(entity);
		}
		Lib.current.addChild(displaySystem.bitmap);
	}
	
	static function update()
	{
		movingSystem.update();
		boundingSystem.update();
		displaySystem.update();
	}
	
	static function makeSquare(entity:Entity)
	{
		var stage = Lib.current.stage;
		entity.setComponent(Position, Position.fromRandom(0, stage.stageWidth, 0, stage.stageHeight));
		entity.setComponent(Size, new Size(10, 10));
		entity.setComponent(VectorSpeed, VectorSpeed.fromRandomPolar(100));
		entity.setComponent(Color, Color.fromRandom());
	}
	
}

class TimeDeltaSystem
{
	var _time:Float = Math.NaN;
	var _deltaTime:Float = Math.NaN;
	
	function update():Void
	{
		if (Math.isNaN(_time))
		{
			_time = Timer.stamp();
		}
		var newTime = Timer.stamp();
		_deltaTime = newTime - _time;
		_time = newTime;
	}
}

class MovingSystem extends TimeDeltaSystem
{
	var _es:EntitySystem;
	
	public function new(es:EntitySystem)
	{
		_es = es;
	}
	
	override public function update():Void
	{
		super.update();
		
		for (entity in _es.getEntitiesWithComponents(Position, VectorSpeed))
		{
			var position = entity.getComponent(Position);
			var vectorSpeed = entity.getComponent(VectorSpeed);
			
			position.x += vectorSpeed.x * _deltaTime;
			position.y += vectorSpeed.y * _deltaTime;
		}
	}
}

class BoundingSystem
{
	var _es:EntitySystem;
	
	public function new(es:EntitySystem)
	{
		_es = es;
	}
	
	public function update():Void
	{
		var right = Lib.current.stage.stageWidth;
		var bottom = Lib.current.stage.stageHeight;
		
		_es.iterateComponents(function(position:Position, size:Size)
		{
			if (position.x > right) 
			{
				position.x = -size.x;
			}
			else if (position.x + size.x < 0) 
			{
				position.x = right;
			}
			
			if (position.y > bottom) 
			{
				position.y = -size.y;
			}
			else if (position.y + size.y < 0) 
			{
				position.y = bottom;
			}
		});
	}
}

class DisplaySystem extends TimeDeltaSystem
{
	static var _tempRect:Rectangle = new Rectangle();
	
	public var bitmap:Bitmap = new Bitmap();
	
	var _bitmapData:BitmapData;
	
	var _es:EntitySystem;
	
	public function new(es:EntitySystem)
	{
		_es = es;
	}
	
	override public function update():Void
	{
		super.update();
		
		var width = Lib.current.stage.stageWidth;
		var height = Lib.current.stage.stageHeight;
		
		if (_bitmapData != null && (_bitmapData.width != width || _bitmapData.height != height))
		{
			_bitmapData.dispose();
			_bitmapData = null;
		}
		if (_bitmapData == null)
		{
			_bitmapData = new BitmapData(width, height, false);
			bitmap.bitmapData = _bitmapData;
		}
		
		_bitmapData.lock();
		var rect = _tempRect;
		rect.setTo(0, 0, width, height);
		_bitmapData.fillRect(_tempRect, 0xFFFFFFFF);
		_es.iterateComponents(function(position:Position, size:Size, color:Color)
		{
			rect.x = position.x;
			rect.y = position.y;
			rect.width = size.x;
			rect.height = size.y;
			_bitmapData.fillRect(rect, color.int);
		});
		_bitmapData.unlock();
	}
}

class Position
{
	static public inline function fromRandom(minX:Float, maxX:Float, minY:Float, maxY:Float):Position
	{
		var x = minX + Math.random() * (maxX - minX);
		var y = minY + Math.random() * (maxY - minY);
		return new Position(x, y);
	}
	
	public var x:Float;
	public var y:Float;
	
	public inline function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}
}

class Size
{
	public var x:Float;
	public var y:Float;
	
	public inline function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}
}

class VectorSpeed
{
	static public inline function fromRandomPolar(minSpeed:Float = 0, maxSpeed:Float = 0, minAngle:Float = 0, maxAngle:Float = 2 * 3.141592653589793):VectorSpeed
	{
		var speed = minSpeed + Math.random() * (maxSpeed - minSpeed);
		var angle = minAngle + Math.random() * (maxAngle - minAngle);
		return fromPolar(speed, angle);
	}
	
	static public inline function fromPolar(speed:Float, angle:Float):VectorSpeed
	{
		var x = speed * Math.cos(angle);
		var y = speed * Math.sin(angle);
		return new VectorSpeed(x, y);
	}
	
	public var x:Float;
	public var y:Float;
	
	public inline function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}
}

class Color
{
	static public inline function fromRandom(isRandomAlpha:Bool = false):Color
	{
		var color = Std.int(isRandomAlpha ? 0xFFFFFFFF * Math.random() : 0xFF000000 | Std.int(0xFFFFFF * Math.random()));
		return new Color(color);
	}
	
	public var int:Int;
	
	public inline function new(c:Int)
	{
		this.int = c;
	}
}