import 'package:args/command_runner.dart';
import 'package:tomentosa/controllers/DocsController.dart';

class DocsCreateCommand extends Command {

  @override
  final name = 'create';

  @override
  final description = 'Writes in output the documentation of a model in latex';

  static const ERASE_SECTION_NUMBERS = 'erase-section-number';
  static const ERASE_SECTION_NUMBERS_ARB = 'e';

  DocsCreateCommand(){
      argParser.addFlag(ERASE_SECTION_NUMBERS, abbr: ERASE_SECTION_NUMBERS_ARB);
  }

  @override
  Future<void> run() async{
    if(argResults.arguments.isEmpty){
      usageException('Missing arguments tomentosa docs create <model.json>');
    }
    print(await DocsController.getsDocsInLatex(
      argResults.arguments.first,
      eraseSectionNumbers: argResults[ERASE_SECTION_NUMBERS] ?? false,
    ));
  }


}