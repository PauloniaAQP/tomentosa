import 'package:args/command_runner.dart';
import 'package:tomentosa/CommandParser/Commands/models/ModelsCreateCommand.dart';

class ModelsCommand extends Command {

  @override
  final name = 'models';

  @override
  final description = 'Make operations in models';

  ModelsCommand(){
    addSubcommand(ModelsCreateCommand());
  }


}