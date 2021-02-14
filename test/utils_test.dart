import 'dart:math';

import 'package:test/test.dart';
import 'package:tomentosa/utils/utils.dart';

void main() async{

  test('compareString()', (){
    expect(Utils.compareString('StringA', 'StringB'), false);
    expect(Utils.compareString('StringA', 'StringA'), true);
    expect(Utils.compareString('stringa', 'stringa'), true);
    expect(Utils.compareString('StRingA', 'stRINGa'), true);
  });

  test('upperFirstLetter()', (){
    expect(Utils.upperFirstLetter('testString'), 'TestString');
    expect(Utils.upperFirstLetter('tEST_STRING'), 'TEST_STRING');
    expect(Utils.upperFirstLetter('TestString'), 'TestString');
  });

  test('splitNameToUpper()', (){
    expect(Utils.splitNameToUpper('stringTest'), 'STRING_TEST');
    expect(Utils.splitNameToUpper('stringTestDos'), 'STRING_TEST_DOS');
    expect(Utils.splitNameToUpper('string'), 'STRING');
  });

  test('isUpper()', (){
    expect(Utils.isUpper('String', 0), true);
    expect(Utils.isUpper('String', 1), false);
    expect(Utils.isUpper('StRInG', 5), true);
  });

  await test('runCommand()', () async{
     var result = await Utils.runCommand('echo Test Command');
     expect(result.isNotEmpty, true);
     expect(result.first.exitCode, 0);
  });

}