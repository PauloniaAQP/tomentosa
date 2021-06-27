import 'package:args/command_runner.dart';
import 'package:tomentosa/CommandParser/Commands/docs/DocsCommand.dart';
import 'package:tomentosa/CommandParser/Commands/models/ModelsCommand.dart';

class CommandParser {

  static final _runner = CommandRunner('tomentosa', 'Tomentosa');

  static void initParser(){
    _runner.addCommand(ModelsCommand());
    _runner.addCommand(DocsCommand());
  }

  static void run(List<String> arguments){
    _runner.run(arguments);
  }

}