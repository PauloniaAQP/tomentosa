import 'dart:collection';
import 'dart:io';

import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/services/ModelsService.dart';
import 'package:tomentosa/utils/constants/ModelConstants.dart';
import 'package:tomentosa/utils/constants/ProjectFiles.dart';
import 'package:tomentosa/utils/constants/SystemCommands.dart';
import 'package:tomentosa/utils/utils.dart';

class ModelsController {

  /// Creates all components of a model in [projectRoot] from [jsonFile]
  static Future<Model> createModel(String jsonFile, String projectRoot) async{
    Model model = ModelsService.loadModel(jsonFile);
    _actualProjectRoot = projectRoot;
    await _addCollectionNames(model.name);
    await _createCollectionFile(model);
    await _createEnumsFile(model);
    await _generateModelFile(model);
    return model;
  }

  /// Adds the collection name to the Firestore Constans file
  static Future<void> _addCollectionNames(String collectionName) async{
    String path = _actualProjectRoot + ProjectFiles.FIRESTORE_CONSTANTS_FILE_PATH;
    String uppperName = Utils.splitNameToUpper(collectionName);
    String command = SystemCommands.SED_COMMAND + "-i \"0,/}/s//" +
          '  static const String ' + uppperName + "_COLLECTION = '" + 
          collectionName + "';\\n}/\" " + path;
    await Utils.runCommand(command);
  }

  /// Creates the collection file with the names of the fields
  static Future<void> _createCollectionFile(Model model) async{
    HashSet<String> namesSet = HashSet();
    String collectionName = Utils.upperFirstLetter(model.name);
    String path = _actualProjectRoot + ProjectFiles.COLLECTIONS_DIR_PATH
                   + collectionName + ProjectFiles.DART_EXTENSION;
    File file = File(path);
    await file.create(recursive: true);
    IOSink collectionFile = file.openWrite();
    collectionFile.write('class ');
    collectionFile.write(collectionName);
    collectionFile.write('CollectionNames {\n');
    _writeCollectionNames(model.fields, collectionFile, namesSet);
    collectionFile.write('}\n');
    collectionFile.close();
  }

  /// Creates the enum file for the model
  ///
  /// If there are not enums in the model, then the file is not created
  static Future<void> _createEnumsFile(Model model) async{
    if(!model.hasEnum()) return;
    String modelName = Utils.upperFirstLetter(model.name);
    String path = _actualProjectRoot + ProjectFiles.ENUMS_DIR_PATH 
                  + modelName + ProjectFiles.ENUMS_POSTFIX_FILE_NAME;
    File file = File(path);
    await file.create(recursive: true);
    IOSink enumsFile = file.openWrite();
    _writeEnums(model.fields, enumsFile, modelName);
    enumsFile.close();
  }

  /// Write enums field in [enumFile]
  ///
  /// This function is recursive for field with map type with fields inside
  static void _writeEnums(
    List<Field> fields,
    IOSink enumsFile,
    String modelName,
  ) async{
    String fieldName;
    for(Field field in fields){
      if(field.fields != null && field.fields.isNotEmpty){
        _writeEnums(field.fields, enumsFile, modelName);
        continue;
      }
      if(field.fieldType != FieldType.enum_type) continue;
      fieldName = Utils.upperFirstLetter(field.name);
      enumsFile.write('enum ');
      enumsFile.write(modelName + fieldName + '{\n');
      for(String enumString in field.enums){
        enumsFile.write(' ' + enumString + ',\n');
      }
      enumsFile.write('}\n\n');
    }
  }

  /// Write the field names on [collectionFile]
  ///
  /// This function is recursive for field with map type with fields inside
  /// [namesMap] is used to avoid repeat field names
  static HashSet<String> _writeCollectionNames(
    List<Field> fields,
    IOSink collectionFile,
    HashSet<String> namesSet,
  ){
    String fieldNameUpper = '';
    for(Field field in fields){
      if(namesSet.contains(field.name.toLowerCase())) continue;
      if(field.fieldType == FieldType.key) continue;
      namesSet.add(field.name.toLowerCase());
      fieldNameUpper = Utils.splitNameToUpper(field.name);
      if(field.description != null && field.description.isNotEmpty){
        collectionFile.write('  /// ');
        collectionFile.write(field.description);
        collectionFile.write('\n');
      }
      collectionFile.write('  static const String ');
      collectionFile.write(fieldNameUpper);
      collectionFile.write(" = '");
      collectionFile.write(field.name);
      collectionFile.write("';\n");
      if(field.fields != null && field.fields.isNotEmpty){
        namesSet = _writeCollectionNames(field.fields, collectionFile, namesSet);
      }
    }
    return namesSet;
  }

  /// Generates and writes the model file of [model]
  static Future<void> _generateModelFile(Model model) async{
    String modelName = Utils.upperFirstLetter(model.name) + ProjectFiles.MODEL_POSTFIX;
    String classPath = _actualProjectRoot + ProjectFiles.MODELS_DIR_PATH +  
                        modelName + 
                        ProjectFiles.DART_EXTENSION;
    File file = File(classPath);
    IOSink modelFile = await file.openWrite();
    List<String> blocks = _writeFieldsInModelFile(
      modelName,
      modelName,
      model.fields,
    );
    for(String block in blocks.reversed){
      modelFile.write(block);
    }
    modelFile.close();
  }

  /// Gets the blocks fields for write in the model file
  static List<String> _writeFieldsInModelFile(
    String modelName,
    String className,
    List<Field> fields,
  ){
    String constructor = '';
    String classBlock = '';
    String copyWith = '';
    String copyWithReturn = '';
    classBlock = 'class ' + className + '{\n\n';
    constructor = '\t' + className + '({\n';
    copyWith = '\t' + className + ' copyWith({\n';
    copyWithReturn = '\t\treturn ' + className + '(\n';
    List<String> blocks = [];
    String typeString = '';
    for(Field field in fields){
      switch(field.fieldType){
        case FieldType.key:
          classBlock += '\tString id;\n';
          constructor += '\t\tthis.id,\n';
          break;
        case FieldType.m_string:
          typeString = 'String';
          classBlock += '\tString ' + field.name + ';\n';
          break;
        case FieldType.boolean:
          typeString = 'bool';
          classBlock += '\tbool ' + field.name + ';\n';
          break;
        case FieldType.m_int:
          typeString = 'int';
          classBlock += '\tint ' + field.name + ';\n';
          break;
        case FieldType.number:
          typeString = 'double';
          classBlock += '\tdouble ' + field.name + ';\n';
          break;
        case FieldType.m_double:
          typeString = 'double';
          classBlock += '\tdouble ' + field.name + ';\n';
          break;
        case FieldType.timestamp:
          typeString = 'DateTime';
          classBlock += '\tDateTime ' + field.name + ';\n';
          break;
        case FieldType.list:
          typeString = 'List<dynamic>';
          classBlock += '\tList<dynamic> ' + field.name + '; // The type cannot be deduced,change the type\n';
          if(field.fields != null && field.fields.isNotEmpty){
            blocks.addAll(_writeFieldsInModelFile(
              modelName,
              modelName + Utils.upperFirstLetter(field.name),
              field.fields,
            ));
          }
          break;
        case FieldType.reference:
          // TODO
          break;
        case FieldType.enum_type:
          String temp = Utils.upperFirstLetter(field.name);
          typeString = modelName + temp;
          classBlock += '\t' + modelName + temp + ' ' + field.name + ';\n';
          /// TODO imports
          break;
        case FieldType.map_type:
          String tempClassName = Utils.upperFirstLetter(field.name);
          classBlock += '\t' + modelName + tempClassName + ' ' + field.name + ';\n';
          typeString = modelName + tempClassName;
          if(field.fields != null && field.fields.isNotEmpty){
            blocks.addAll(_writeFieldsInModelFile(
              modelName,
              modelName + tempClassName,
              field.fields,
            ));
          }
          break;
        case FieldType.geopoint:
          typeString = 'tCoordinates';
          classBlock += '\tCoordinates ' + field.name + ';\n';
          break;
        default:
          break;
      }
      if(field.fieldType != FieldType.key){
        constructor += '\t\tthis.' + field.name + ',\n';
        copyWith += '\t\t' + typeString + ' ' + field.name + ',\n';
        copyWithReturn += '\t\t\t' + field.name + ': ' + field.name + ' ?? this.' + field.name + ',\n';
      }
    }
    constructor += '\t});\n\n';
    copyWithReturn += '\t\t);\n';
    copyWith += '\t}){\n' + copyWithReturn + '\t}\n\n';
    classBlock += '\n' + constructor + copyWith;
    classBlock += '}\n\n';
    blocks.add(classBlock);
    return blocks;
  }

  
  static String _actualProjectRoot;


}