package;
import haxe.macro.Expr;
import haxe.macro.Printer;

class Assert {
        macro static public function assert(condition:ExprOf<Bool>, message:ExprOf<String>):Expr {
		var conditionText = new Printer().printExpr(condition);
                var conditionPos = Std.string(condition.pos);
                conditionPos = conditionPos.substring(4, conditionPos.length);
		return macro if (!$condition) {
			throw 'Assert ($conditionText) at $conditionPos is failed:\n' + $message;
		}
	}
}