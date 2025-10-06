package;

import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

import Sys.println as log;

using StringTools;
using util.WindowsCMDUtil;

@:publicFields
class Main {
	/** @return Output if command executed successfully, otherwise `null` */
	static function cmd(command:String, ?addToError:String = 'For fix you can just google it! If you lazy, just restart PC or reinstall Haxe / Git'):Null<String> {
		var pr = new Process(command);
		var out = pr.stdout.readAll().toString();
		out = out.substring(0, out.length - 2);
		var err = pr.stderr.readAll().toString();
		err = err.substring(0, err.length - 2);
		pr.close();

		if (err.length > 0) {
			log('[Setup] '.toCMD(MAGENTA_BOLD) + 'An error occurred!\n'.toCMD(RED_BOLD));

			err = err.replace('[0m', '');
			var arr = err.split('\n');
			for (i in 0...arr.length)
				arr[i] = ' |   ' + arr[i].toCMD(RED);
			if (addToError?.length > 0)
				arr.push(' | ' + addToError.toCMD(YELLOW));
			arr.push(' | ');

			log(arr.join('\n'));

			Sys.exit(1);
			return null;
		}
		return out;
	}

	static function main() {
		WindowsCMDUtil.isWindows = Sys.systemName() == "Windows";

		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Run '.toCMD(BLUE) + 'haxelib'.toCMD(BLUE_BOLD) + ' dependencies install? '.toCMD(BLUE) + '[y/n]');
		if (Sys.stdin().readLine() == 'y')
			loadLibs();

		if (WindowsCMDUtil.isWindows) {
			log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Run '.toCMD(BLUE) + 'VS Community'.toCMD(BLUE_BOLD) + ' libraries install? '.toCMD(BLUE) + '[y/n]');
			if (Sys.stdin().readLine() == 'y')
				vsCommunity();
		}

		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Finished!'.toCMD(GREEN));

		Sys.exit(0);
	}

	static function vsCommunity() {
		if (!WindowsCMDUtil.isWindows) return;

		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Installing '.toCMD(BLUE) + 'VS Community'.toCMD(BLUE_BOLD) + ' libraries...'.toCMD(BLUE));
		if (!FileSystem.exists('vs_Community.exe'))
			cmd('curl.exe -s https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe -O');
		cmd('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p', '');
		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Installing completed!'.toCMD(GREEN));
	}

	static function loadLibs() {
		if (cmd('haxelib --quiet --always update haxelib') != 'haxelib is up to date') {
			log('');
			log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Haxelib '.toCMD(WHITE_BOLD) + 'was updated!'.toCMD(GREEN));
		}

		if (!FileSystem.exists('.haxelib')) {
			log('');
			log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Creating '.toCMD(BLUE) + '.haxelib'.toCMD(WHITE_BOLD) + ' folder...'.toCMD(BLUE));
			cmd('haxelib --quiet --always --skip-dependencies newrepo');
		}

		log('');
		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Installing dependencies...'.toCMD(BLUE));
		for (xml in Xml.parse(File.getContent("Project.xml")).firstElement().elements()) if (xml.nodeName == 'haxelib') {
			log('');
			var name = xml.get('name');
			var version = xml.get('version') ?? '';
			switch(version) {
				case 'git':
					var url = xml.get('url');
					var branch = xml.get('branch') ?? '';
					var shortBranch = branch;
					if (shortBranch == '') shortBranch = 'Latest';
					else shortBranch = branch.substring(0, 7);

					log(name.toCMD(CYAN) + ' (git)');

					var result = getCommit(name, branch);
					switch(result) {
						case '0':
							log(' - ' + shortBranch.toCMD(WHITE_BOLD) + ' already installed!'.toCMD(GREEN));
							continue;
						case '1':
							log(' - ' + shortBranch.toCMD(WHITE_BOLD) + ' is not installed!'.toCMD(RED));
							log(' - ' + 'Downloading '.toCMD(BLUE) + shortBranch.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --always --skip-dependencies git $name $url $branch');
							log(' - ' + 'Successfully downloaded!'.toCMD(GREEN));
							onDownload(name, branch, result, true);
						default:
							var shortResult = result.substring(0, 7);
							log(' - ' + shortResult.toCMD(WHITE_BOLD) + ' is outdated!'.toCMD(RED));

							log(' - ' + 'Removing '.toCMD(BLUE) + shortResult.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --always --skip-dependencies remove $name');
							log(' - ' + 'Successfully removed!'.toCMD(GREEN));

							log(' - ' + 'Downloading '.toCMD(BLUE) + shortBranch.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --always --skip-dependencies git $name $url $branch');
							log(' - ' + 'Successfully downloaded!'.toCMD(GREEN));
							onDownload(name, branch, result, true);
					}
				default:
					log(name.toCMD(CYAN) + ' (haxelib)');

					var versionDisplay = version;
					if (versionDisplay == '') versionDisplay = 'Latest';
					var result = getVersion(name, version);
					switch(result) {
						case '0':
							log(' - ' + versionDisplay.toCMD(WHITE_BOLD) + ' already installed!'.toCMD(GREEN));
							onDownload(name, version, result, false);
							continue;
						case '1':
							log(' - ' + versionDisplay.toCMD(WHITE_BOLD) + ' is not installed!'.toCMD(RED));
							log(' - ' + 'Downloading '.toCMD(BLUE) + versionDisplay.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --always --skip-dependencies install $name $version');
							log(' - ' + 'Successfully downloaded!'.toCMD(GREEN));
							onDownload(name, version, result, false);
						default:
							log(' - ' + result.toCMD(WHITE_BOLD) + ' is outdated!'.toCMD(RED));

							log(' - ' + 'Removing '.toCMD(BLUE) + result.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --always --skip-dependencies remove $name');
							log(' - ' + 'Successfully removed!'.toCMD(GREEN));

							log(' - ' + 'Downloading '.toCMD(BLUE) + version.toCMD(WHITE_BOLD) + '...'.toCMD(BLUE));
							cmd('haxelib --quiet --never --skip-dependencies install $name $version');
							log(' - ' + 'Successfully downloaded!'.toCMD(GREEN));
							onDownload(name, version, result, false);
					}
			}
		}

		log('');
		log('[Setup] '.toCMD(MAGENTA_BOLD) + 'Installing completed!'.toCMD(GREEN));
	}

	static var limePatch = [' + "::resourceName::";', '+macros.CustomManifestFolder.MANIFEST_PREFIX+"::resourceName::";'];
	static function onDownload(name:String, version:String, result:String, isGit:Bool) {
		if (!isGit && WindowsCMDUtil.isWindows) {
			switch(name) {
				case 'lime':
					var folder = getHaxelibFolder(name);
					if (folder != null && FileSystem.exists(folder + 'templates/haxe/ManifestResources.hx')) {
						var content = File.getContent(folder + 'templates/haxe/ManifestResources.hx');
						if (content.contains(limePatch[0])) {
							content = content.replace(limePatch[0], limePatch[1]);
							File.saveContent(folder + 'templates/haxe/ManifestResources.hx', content);
							log(' - ' + 'Successfully patched!'.toCMD(GREEN));
						}
					}
			}
		}
	}

	/** @return if lib not found will return `null`, otherwise library path like: ".haxelib\flxanimate/git/" */
	static function getHaxelibFolder(name:String):Null<String> {
		var pr = new Process('haxelib libpath $name');
		var f = pr.stdout.readLine();
		pr.close();
		return f.startsWith('Error: ') ? null : f;
	}

	static function getCommit(name:String, neededCommit:String) {
		if (neededCommit == '') return '1';

		var folder = getHaxelibFolder(name);
		if (folder == null) return '1';

		var commit = File.getContent(folder + '.git/HEAD').trim();
		if (!commit.startsWith(neededCommit))
			return commit;
		return '0';
	}

	static function getVersion(name:String, neededVersion:String) {
		if (neededVersion == '') return '1';

		var folder = getHaxelibFolder(name);
		if (folder == null) return '1';

		folder = folder.substring(0, folder.length - 1);
		folder = folder.substring(0, folder.lastIndexOf('/') + 1);
		var version = File.getContent(folder + '.current').trim();
		if (!version.startsWith(neededVersion))
			return version;
		return '0';
	}
}