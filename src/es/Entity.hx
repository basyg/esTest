package es;

import haxe.macro.Expr.ExprOf;

class Entity extends EntityComponents
{
	public var entitySystem(default, null):EntitySystem;
	
	public function new(entitySystem:EntitySystem)
	{
		this.entitySystem = entitySystem;
	}
	
	macro public function setComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>, component:ExprOf<T>):ExprOf<Entity>
	{
		var field = EntityMacro.makeComponentFieldFromTypeExpr(type);
		EntityMacro.updateFilesIfComponentFieldMissing(field);
		var listFields = EntityMacro.getComponentListFields().filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EntityMacro.makeComponentListNoFieldFromListField);
		
		var updateListExprs = [
			for (i in 0...listFields.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				
				var componentFields = EntityMacro.parseComponentFieldsFromComponentListField(listField);
				componentFields.remove(field);
				
				var expr = macro entity.$listNoField = entitySystem.$listField.push(entity);
				if (componentFields.length > 0)
				{
					var hasComponentsExpr = makeHasComponentsExprFromFields(macro entity, componentFields);
					expr = macro if ($hasComponentsExpr)
					{
						$expr;
					}
				}
				expr;
			}
		];
		
        return macro
		{
			var entity = $that;
			var component = $component;
			var entitySystem = entity.entitySystem;
			Assert.assert(component != null, 'Component for adding is not null');
			
			if (entity.$field == null) $b{updateListExprs};
			
			entity.$field = component;
			entity;
        };
	}
	
	macro public function removeComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T>
	{
		var field = EntityMacro.makeComponentFieldFromTypeExpr(type);
		var listFields = EntityMacro.getComponentListFields().filter(function(list) return list.indexOf(field) >= 0);
		var listNoFields = listFields.map(EntityMacro.makeComponentListNoFieldFromListField);
		
		var updateListExprs = [
			for (i in 0...listFields.length) 
			{
				var listField = listFields[i];
				var listNoField = listNoFields[i];
				
				var listFields = EntityMacro.parseComponentFieldsFromComponentListField(listField);
				listFields.remove(field);
				
				var expr0 = macro var no = entity.$listNoField;
				var expr = macro
				{
					var list = entitySystem.$listField;
					list.spliceByLast(no);
					if (no < list.length)
					{
						list[no].$listNoField = no;
					}
					entity.$listNoField = -1;
				}
				if (listFields.length > 0)
				{
					expr = macro if (no >= 0) $expr;
				}
				expr = macro
				{
					$expr0;
					$expr;
				}
			}
		];
		
        return macro
		{
			var entity = $that;
			var component = $that.$field;
			var entitySystem = entity.entitySystem;
			Assert.assert(component != null, 'Component for removing is not null');
			
			$b{updateListExprs};
			
			entity.$field = null;
			entity;
        };
	}
	
	macro public function getComponent<T>(that:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Null<T>>
	{
		var field = EntityMacro.makeComponentFieldFromTypeExpr(type);
        return macro $that.$field;
	}
        
    macro public function hasComponents(that:ExprOf<Entity>, type:ExprOf<Class<Dynamic>>, types:Array<ExprOf<Class<Dynamic>>>):ExprOf<Bool>
	{
		types.push(type);
		var fields = types.map(EntityMacro.makeComponentFieldFromTypeExpr);
		return macro
		{
			var entity = $that;
			${makeHasComponentsExprFromFields(macro entity, fields)};
		};
    }
	
	#if macro
	
	static function makeHasComponentsExprFromFields(entity:ExprOf<Entity>, fields:Array<String>):ExprOf<Bool>
	{
		var conditions = fields.map(function(field) return macro $entity.$field != null);
		
		if (conditions.length == 1)
		{
			return conditions[0];
		}
		
		var and = conditions.pop();
		for (condition in conditions) 
		{
			and = macro $and && $condition;
		}
		return and;
	}
	
	#end
}