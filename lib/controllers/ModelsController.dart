import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/services/ErrorService.dart';
import 'package:tomentosa/utils/constants/JsonNames.dart';
import 'package:tomentosa/utils/constants/ModelConstants.dart';
import 'package:tomentosa/utils/constants/ProjectFiles.dart';
import 'package:tomentosa/utils/constants/SystemCommands.dart';
import 'package:tomentosa/utils/utils.dart';

class ModelsController {

  static Future<Model> createModel(String jsonFile, String projectRoot) async{
    Model model = loadModel(jsonFile);
    _actualProjectRoot = projectRoot;
    await _addCollectionNames(model.name);
    await _createCollectionFile(model);
    await _createEnumsFile(model);
    await _generateModelFile(model);
    return model;
  }


  /// Loads a model form a json file
  static Model loadModel(String jsonFile){
    _verifyJson(jsonFile);
    _actualFileName = jsonFile;
    File file = File(jsonFile);
    String jsonString = file.readAsStringSync();
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _verifyJsonValues(jsonMap);
    Model res = Model(
      name: jsonMap[JsonNames.NAME],
      parents: [],
      subcollections: [],
    );
    if(jsonMap.containsKey(JsonNames.PARENTS)){
      res.parents = jsonMap[JsonNames.PARENTS].cast<String>();
    }
    if(jsonMap.containsKey(JsonNames.SUB_COLLECTIONS)){
      res.subcollections = jsonMap[JsonNames.SUB_COLLECTIONS].cast<String>();
    }
    res.fields = _loadFields(jsonMap[JsonNames.FIELDS] as Map<String, dynamic>);
    return res;
  }

  /// Load fileds of [fieldMap]
  ///
  /// This function is recursive for field with map and list type with fields inside
  static List<Field> _loadFields(Map<String, dynamic> fieldMap){
    List<Field> res = [];
    fieldMap.forEach((key, value){
      Field field = Field(
        name: key,
        fieldTypeOf: "",
        description: "",
      );
      if(value is String){
        field.setFieldType(value);
        if(field.fieldType == FieldType.error){
          ModelErrorService.throwNotValidType(_actualFileName, value);
        }
        else if(field.fieldType == FieldType.enum_type){
          ModelErrorService.throwMustHaveOf(_actualFileName, value, field.name);
        }
      }
      else{
        if(!value.containsKey(JsonNames.TYPE)){
          ModelErrorService.throwMustHaveType(_actualFileName, field.name);
        }
        field.setFieldType(value[JsonNames.TYPE]);
        if(field.fieldType == FieldType.error){
          ModelErrorService.throwNotValidType(_actualFileName, value[JsonNames.TYPE]);
        }
        if(value.containsKey(JsonNames.OF)){
          field.fieldTypeOf = value[JsonNames.OF];
          if(field.fieldTypeOf.isEmpty){
            ModelErrorService.throwEmptyOption(_actualFileName, field.name, JsonNames.OF);
          }
          if(field.fieldType == FieldType.enum_type){
            field.setEnumExtras();
          }
        }
        else if(field.fieldType == FieldType.enum_type){
          ModelErrorService.throwMustHaveOf(
            _actualFileName,
            FieldTypeStrings.ENUM_STRING,
            field.name
          );
        }
        if(value.containsKey(JsonNames.DESCRIPTION)){
          field.description = value[JsonNames.DESCRIPTION];
        }
        if(value.containsKey(JsonNames.FIELDS)){
          if(field.fieldType != FieldType.map_type && 
              field.fieldType != FieldType.list){
            ModelErrorService.throwFieldsOption(_actualFileName, field.name);
          }
          field.fields = _loadFields(value[JsonNames.FIELDS] as Map<String, dynamic>);
        }
      }
      res.add(field);
    });
    return res;
  }

  /// Verify if [fileName] is a json file
  ///
  /// It throws an error if the file is not a json file
  static void _verifyJson(String jsonFile){
    if(jsonFile.split('.').last != JsonNames.JSON_EXTENSION){
      ModelErrorService.throwIsNotJson(jsonFile);
    }
  }

  /// Verifies the principal values of a json model file
  static void _verifyJsonValues(Map<String, dynamic> jsonMap){
    if(!jsonMap.containsKey(JsonNames.NAME)){
      ModelErrorService.throwHasNotValue(_actualFileName, JsonNames.NAME);
    }
    if(!jsonMap.containsKey(JsonNames.FIELDS)){
      ModelErrorService.throwHasNotValue(_actualFileName, JsonNames.FIELDS);
    }
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
    classBlock = 'class ' + className + '{\n\n';
    constructor = '\t' + className + '({\n';
    List<String> blocks = [];
    for(Field field in fields){
      switch(field.fieldType){
        case FieldType.key:
          classBlock += '\tString id;\n';
          constructor += '\t\tthis.id,\n';
          break;
        case FieldType.m_string:
          classBlock += '\tString ' + field.name + ';\n';
          break;
        case FieldType.boolean:
          classBlock += '\tbool ' + field.name + ';\n';
          break;
        case FieldType.m_int:
          classBlock += '\tint ' + field.name + ';\n';
          break;
        case FieldType.number:
          classBlock += '\tdouble ' + field.name + ';\n';
          break;
        case FieldType.m_double:
          classBlock += '\tdouble ' + field.name + ';\n';
          break;
        case FieldType.timestamp:
          classBlock += '\tDateTime ' + field.name + ';\n';
          break;
        case FieldType.list:
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
          classBlock += '\t' + modelName + temp + ' ' + field.name + ';\n';
          /// TODO imports
          break;
        case FieldType.map_type:
          String tempClassName = Utils.upperFirstLetter(field.name);
          classBlock += '\t' + modelName + tempClassName + ' ' + field.name + ';\n';
          if(field.fields != null && field.fields.isNotEmpty){
            blocks.addAll(_writeFieldsInModelFile(
              modelName,
              modelName + tempClassName,
              field.fields,
            ));
          }
          break;
        case FieldType.geopoint:
          classBlock += '\tCoordinates ' + field.name + ';\n';
          break;
        default:
          break;
      }
      if(field.fieldType != FieldType.key){
        constructor += '\t\tthis.' + field.name + ',\n';
      }
    }
    constructor += '\t});\n\n';
    classBlock += '\n' + constructor;
    classBlock += '}\n\n';
    blocks.add(classBlock);
    return blocks;
  }

  static String _actualFileName;
  static String _actualProjectRoot;


}