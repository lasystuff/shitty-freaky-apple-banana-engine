package macros;

#if macro
import sys.io.File;
import sys.FileSystem;
#end

class CustomManifestFolder {
	inline public static final MANIFEST_PREFIX:String = "assets/."; // will be "assets/.manifest/default.json"
	#if macro
	public static function init() {
		if (!Context.getDefines().exists('no_console')) return;

		var output:String = Compiler.getOutput();
		output = output.substring(0, output.lastIndexOf('/') + 1) + 'bin';

		var src:String = '$output/manifest';
		var dest:String = '$output/${MANIFEST_PREFIX}manifest';

		if (FileSystem.exists(src)) {
			if (!FileSystem.exists(dest))
				FileSystem.createDirectory(dest);

			for (file in FileSystem.readDirectory(src)) {
				File.saveBytes('$dest/$file', File.getBytes('$src/$file'));
				FileSystem.deleteFile('$src/$file');
			}
			FileSystem.deleteDirectory(src);
		}
	}
	#end
}