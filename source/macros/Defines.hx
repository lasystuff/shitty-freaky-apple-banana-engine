package macros;

#if macro
class Defines {
	public static function add():Array<Field> {
		var fields = Context.getBuildFields();

		var a = Context.getDefines();
		for (noleaks in ['ANDROID-NDK-ROOT', 'ANDROID-SDK', 'ANDROID_NDK_ROOT', 'ANDROID_SDK', 'JAVA-HOME', 'JAVA_HOME'])
			a.remove(noleaks);
		var s = a.get('SONG');
		if (s != null)
			Sys.println('Game will load song '.toCMD(YELLOW) + s.toCMD(YELLOW_BOLD) + ' on start!'.toCMD(YELLOW));
		var d = macro $v{a};
		fields.push({
			pos: Context.currentPos(),
			name: 'defines',
			kind: FVar(macro:Map<String, String>, d),
			access: [APublic, AStatic]
		});
		return fields;
	}
}
#end