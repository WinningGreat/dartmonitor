import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:args/args.dart';
import 'package:watcher/watcher.dart';
import 'dart:convert';
import 'package:colorize/colorize.dart';
const dir = 'dir';
List<String> allFilePaths = [];
StreamSubscription _watcherSub;
StreamSubscription _processStdOut;
StreamSubscription _processStdErr;
ArgResults argResults;
String dirString;
Process process;

void main(List<String> arguments) {
  exitCode = 0;
  
  final parser = ArgParser()
                      ..addOption('runcmd',defaultsTo: 'bin/man.dart',abbr: 'r',);

  
  
  argResults = parser.parse(arguments);
  print(argResults.rest);
  start();
  setUpWatcher();

}

 void restart()async{
   color('Restarting.....',front:Styles.GREEN);
  close();
  await start();


 }

 void start()async{
   process = await Process.start('dart', [p.absolute(p.dirname(Platform.script.path),'bin/main.dart')],);
    _processStdOut = process.stdout
        .transform(utf8.decoder)
        .listen((data) { print(data); });
    _processStdErr = process.stderr
                  .transform(utf8.decoder)
        .listen((data) { print(data); });
 }

 void close(){
  _processStdOut.cancel();
  process.kill();

 }

 Future<void> setUpWatcher() async {
     color('Listening for File Changes',front: Styles.LIGHT_BLUE,isBold: true,isItalic: true);
    var absolutePath = p.absolute(p.dirname(Platform.script.path));
    // print(absolutePath);
    var watcher = DirectoryWatcher(absolutePath);
    _watcherSub = watcher.events.listen((WatchEvent event) async {
      // stdout.write('${event.type}\n');
      var dir = Directory(absolutePath);
      var files = <String>[];
      var lister = dir.list(recursive: true);
      await for (var file in lister) {
        files.add(file.path);
      }
      var newFiles = allFilePaths
          .where((String element) =>
              !files.contains(element) &&
              p.extension(element) != '.dart')
          .toList();
      // if (newFiles.isNotEmpty) {
      //   restart();
      // }
      // if (event.type == ChangeType.MODIFY) {
      //   if (newFiles.isEmpty) restart();
      // }
      // if (event.type == ChangeType.REMOVE) restart();
      // if (event.type == ChangeType.ADD) {
      //   if (newFiles.isEmpty) restart();
      // }
      restart();
      allFilePaths = files;
    });

    // });
  }
