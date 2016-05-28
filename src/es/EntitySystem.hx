package es;

import ds.Arr;
import haxe.macro.Expr.Function;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr.FunctionArg;
#end
import haxe.macro.ExprTools;

class EntitySystem extends EntitySystemLists
{
	var _entities:Arr<Entity> = new Arr();
	
	public function new()
	{
		
	}
	
	public inline function createEntity():Entity
	{
		var entity = new Entity(this);
		_entities.push(entity);
		return entity;
	}
	
	public inline function getEntities():ConstArr<Entity>
	{
		return _entities;
	}
	
	macro public function getEntitiesWithComponents(that:ExprOf<EntitySystem>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<ConstArr<Entity>>
	{
		types.push(type);
		var listField = EntityMacro.makeComponentListFieldFromTypeExprs(types);
		EntityMacro.updateFilesIfComponentListFieldMissing(listField);
		return macro new ds.Arr.ConstArr($that.$listField);
	}
	
	macro public function iterateComponents(that:ExprOf<EntitySystem>, funcExpr:ExprOf<Function>):ExprOf<Dynamic>
	{
		var func:ExprDef = funcExpr.expr;
		var func:Function = switch(func)
		{
			case ExprDef.EFunction(_, f): f;
			default: throw 'error';
		}
		var typeTools = func.args.map(function(arg:FunctionArg)
		{
			Assert.assert(arg.type != null, 'function has type for argument "${arg.name}"');
			return EntityMacro.TypeTool.fromType(Context.resolveType(arg.type, that.pos));
		});
		var fields = typeTools.map(function(typeTool) return EntityMacro.makeComponentFieldFromTypeName(typeTool.getName()));
		var listField = EntityMacro.makeComponentListFieldFromComponentFields(fields);
		var argExprs = fields.map(function(field) return macro entity.$field);
		var callExpr = { expr: ExprDef.ECall(funcExpr, argExprs), pos: Context.currentPos() };
		return macro
		{
			var entitySystem = $that;
			for (entity in entitySystem.$listField)
			{
				$callExpr;
			}
		};
	}
}