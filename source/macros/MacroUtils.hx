package macros;

#if macro
class MacroUtils {
	public static function addStringFromCompiler(Class:String, variableName:String, value:String, access:String = '')
		Compiler.addGlobalMetadata(Class, "@:build(macros.MacroUtils.addString('" + variableName + "', '" + value + "', '" + access + "'))");

	/**
	 * Adds string variable `variableName` with value `value`
	 * @param callbackName Name of variable
	 * @param value Value of variable
	 */
	public static function addString(variableName:String, value:String, access:String = ''):Array<Field> {
		#if macro
		var acc:Array<Access> = [];
		for (a in access.split(' '))
			acc.push(Reflect.getProperty(Access, 'A' + a.charAt(0).toUpperCase() + a.substring(1)));

		var fields:Array<Field> = Context.getBuildFields();
		fields.push({
			pos: Context.currentPos(),
			name: variableName,
			kind: FVar(macro:String, MacroStringTools.formatString(value, Context.currentPos())),
			access: acc
		});
		return fields;
		#end
	}
}
#end