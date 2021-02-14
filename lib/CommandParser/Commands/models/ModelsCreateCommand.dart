import 'package:args/command_runner.dart';
import 'package:tomentosa/controllers/ModelsController.dart';

class ModelsCreateCommand extends Command{

  @override
  final name = 'create';

  @override
  final description = 'Creates a model and its resources in a project';

  ModelsCreateCommand();

  @override
  Future<void> run() async{
    if(argResults.arguments.length < 2){
      usageException('Missing arguments tomentosa models create <model.json> <projectRootPath>');
    }
    await ModelsController.createModel(argResults.arguments[0], argResults.arguments[1]);
  }

}