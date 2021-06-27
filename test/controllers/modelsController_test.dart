import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tomentosa/controllers/ModelsController.dart';
import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/services/ModelsService.dart';
import 'package:tomentosa/utils/constants/JsonNames.dart';
import 'package:tomentosa/utils/constants/ProjectFiles.dart';

void main(){

  group('load model functionality', (){

    Map<String, dynamic> testMap = {};
    String fileName = 'testModel.json';
    File jsonFile = File(fileName);
    String nameModel = 'testModel';

    test('_verifyJson()', (){
      expect(() => ModelsService.loadModel('test.test'), throwsException);
    });

    test('_verifyJsonValues()', (){
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap = {
        JsonNames.NAME: nameModel,
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap = {
        JsonNames.FIELDS: {

        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap = {
        JsonNames.NAME: 'testModel',
        JsonNames.FIELDS: {

        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
    });

    test('loadModel() & _loadFields()', (){
      testMap = {
        JsonNames.NAME: 'testModel',
        JsonNames.FIELDS: {
          
        }
      };
      testMap[JsonNames.FIELDS]['id'] = 'Nothing';
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['id'] = 'String';
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['states'] = 'Enum';
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['states'] = {
        'type': 'Enum',
        'of': 'start, end'
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['states'] = {
        'of': 'start, end'
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['states'] = {
        'type': 'Enum',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['states'] = {
        'type': 'Enum',
        'of': 'start, end'
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['counts'] = {
        'type': 'Nothing',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['counts'] = {
        'type': 'List',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['counts'] = {
        'type': 'List',
        'of': '',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['counts'] = {
        'type': 'List',
        'of': 'Map',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['views'] = {
        'type': 'Number',
        'description': 'Number of views',
        'fields': {

        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), throwsException);
      testMap[JsonNames.FIELDS]['views'] = {
        'type': 'Number',
        'description': 'Number of views',
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
      testMap[JsonNames.FIELDS]['counts'] = {
        'type': 'List',
        'of': 'Map',
        'fileds': {
          'id': 'Key'
        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      expect(() => ModelsService.loadModel(fileName), returnsNormally);
    });

    test('createModel() & _addCollectionNames()'
      '& _createCollectionFile() & __writeCollectionNames()'
      '& _createEnumsFile() & _writeEnums()'
      '& _writeFieldsInModelFile() & _generateModelFile()', () async{
      testMap = {
        JsonNames.NAME: nameModel,
        JsonNames.FIELDS: {
          'id': 'Key',
          'counts': 'Number',
          'name': 'String',
        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      Model model = await ModelsController.createModel(
        fileName,
        ProjectFiles.FLUTTER_TEMPLATE_PATH
      );
      expect(model.name, nameModel);
      String upperName = nameModel.replaceRange(0, 1, nameModel[0].toUpperCase());
      String path = ProjectFiles.FLUTTER_TEMPLATE_PATH + ProjectFiles.COLLECTIONS_DIR_PATH +
                    upperName + ProjectFiles.DART_EXTENSION;
      String modelPath = ProjectFiles.FLUTTER_TEMPLATE_PATH + ProjectFiles.MODELS_DIR_PATH
                            + upperName + ProjectFiles.MODEL_POSTFIX + 
                              ProjectFiles.DART_EXTENSION;
      File file = File(path);
      File modelFile = File(modelPath);
      expect(file.existsSync(), true);
      expect(modelFile.existsSync(), true);
      String enumsPath = ProjectFiles.FLUTTER_TEMPLATE_PATH + ProjectFiles.ENUMS_DIR_PATH +
                    upperName + ProjectFiles.ENUMS_POSTFIX_FILE_NAME;
      File enumsFile = File(enumsPath);
      print(enumsPath);
      expect(enumsFile.existsSync(), false);
      testMap = {
        JsonNames.NAME: nameModel,
        JsonNames.FIELDS: {
          'id': 'Key',
          'counts': 'Number',
          'name': 'String',
          'state': {
            'type': 'Enum',
            'of': 'start, end',
          }
        }
      };
      jsonFile.writeAsStringSync(json.encode(testMap));
      await ModelsController.createModel(
        fileName,
        ProjectFiles.FLUTTER_TEMPLATE_PATH
      );
      enumsFile = File(enumsPath);
      expect(file.existsSync(), true);
      enumsFile.deleteSync();
      jsonFile.deleteSync();
      file.deleteSync();
      modelFile.deleteSync();
    });

  });


}

