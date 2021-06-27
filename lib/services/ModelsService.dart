import 'dart:convert';
import 'dart:io';

import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/services/ErrorService.dart';
import 'package:tomentosa/utils/constants/JsonNames.dart';
import 'package:tomentosa/utils/constants/ModelConstants.dart';

class ModelsService {

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

  static String _actualFileName;

}