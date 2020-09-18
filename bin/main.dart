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
  _processStdErr.cancel();
  _watcherSub.cancel();
  process.kill();

 }

 Future<void> setUpWatcher() async {
     color('Listening for File Changes',front: Styles.LIGHT_BLUE,isBold: true,isItalic: true);
    var absolutePath = p.absolute(p.dirname(Platform.script.path));
    var excludePathList = [];
    try{
      excludePathList = json.decode(File('$absolutePath/dartmonitor.config.json').readAsStringSync())['exclude'];
    } catch(e,s){
      print(e);
      print(s);
    }
    print(excludePathList);
    
    // print(absolutePath);
    var watcher = DirectoryWatcher(absolutePath);
    _watcherSub = watcher.events.listen((WatchEvent event) async {
      if (excludePathList.firstWhere((element) => event.path.contains(element),orElse: ()=>null)!=null){
        return;
      }
      restart();
    });
  }
