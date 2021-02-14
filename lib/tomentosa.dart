import 'package:tomentosa/CommandParser/CommandParser.dart';

void run(List<String> arguments){
  try{
    CommandParser.initParser();
    CommandParser.run(arguments);
  }
  catch (error){
    print(error);
  }
}
