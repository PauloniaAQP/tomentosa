import 'package:args/command_runner.dart';
import 'package:tomentosa/CommandParser/Commands/docs/DocsCreateCommand.dart';

class DocsCommand extends Command {

  @override
  final name = 'docs';

  @override
  final description = 'Make operations in docs';

  DocsCommand(){
    addSubcommand(DocsCreateCommand());
  }

}