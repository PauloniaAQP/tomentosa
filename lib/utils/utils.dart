import 'dart:io';

import 'package:process_run/shell.dart';

class Utils{

  /// Compare two strings with lower case
  static bool compareString(String s_a, String s_b){
    return s_a.toLowerCase() == s_b.toLowerCase();
  }

  /// Converts all name to Upper and split with '_'
  ///
  /// Ej. productEntity => PRODUCT_ENTITY
  static String splitNameToUpper(String word){
    String res = "";
    for(int i = 0; i < word.length; i++){
      if(isUpper(word, i)){
        res += '_';
      }
      res += word[i].toUpperCase();
    }
    return res;
  }

  /// Returns the same [word] with the first letter to upper
  /// 
  /// Ej. stringTest => StringTest
  static String upperFirstLetter(String word){
    return word.replaceRange(0, 1, word[0].toUpperCase());
  }

  /// Verifies 
  static bool isUpper(String word, int indexWord){
    return word[indexWord].toUpperCase() == word[indexWord];
  }

  /// Runs a command
  static Future<List<ProcessResult>> runCommand(String command){ 
    final shell = Shell();
    return shell.run(command);
  }

}