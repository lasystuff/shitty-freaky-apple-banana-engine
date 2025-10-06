package macros;

#if macro
import sys.io.File;
import sys.FileSystem;

class ModVersion {
	inline static final VERSION_FORMAT:String = "v%ymd%.%buildNumber%";
	public static function add():Array<Field> {
		var curDate = Date.now();
		var ymd = DateTools.format(curDate, "%Y%m%d");
		var buildNumber:Int = 0;
		var val:String = VERSION_FORMAT;

		var isCompiling:Bool = Context.getDefines().exists('no_console');
		if (isCompiling) {
			var buildDir = #if debug 'export/debug/' #else 'export/release/' #end;
			if (!FileSystem.exists(buildDir))
				FileSystem.createDirectory(buildDir);

			var build = FileSystem.exists(buildDir + '.builddate') ? File.getContent(buildDir + '.builddate').split('\n') : [ymd, buildNumber + ''];

			if (build.length > 1) buildNumber = Std.parseInt(build[1]);
			if (build[0] == ymd)
				buildNumber++;
			else {
				buildNumber = 0;
				build[0] = ymd;
			}

			File.saveContent(buildDir + '.builddate', build[0] + '\n' + buildNumber);
		}
		val = val.replace('%ymd%', ymd).replace('%buildNumber%', '$buildNumber');
		if (isCompiling) Sys.println('Current version: '.toCMD(YELLOW_BOLD) + val.toCMD(YELLOW));
		return MacroUtils.addString('modVersion', val, 'public static');
	}
}
#end