import 'package:tomentosa/utils/constants/ModelConstants.dart';
import 'package:tomentosa/utils/utils.dart';

class Model {

  String name;
  List<Field> fields;
  List<String> parents;
  List<String> subcollections;

  Model({
    this.name,
    this.fields,
    this.parents,
    this.subcollections,
  });

  void printModel(){
    print('===================');
    print(name);
    print('===================');
    print('Fields: ');
    print('-------------------');
    for(Field field in fields) field.printField();
    print('===================');
    print('Parents: ' + parents.toString());
    print('===================');
    print('SubCollections: ' + subcollections.toString());
    print('===================');
  }

  /// Verifies if in [fields] has an enum type field
  bool hasEnum(){
    return _hasEnum(fields);
  }

  /// Verifies if in [fieldsList] has an enum type field
  bool _hasEnum(List<Field> fieldsList){
    return fieldsList.any((element){
      if(element.fields != null && element.fields.isNotEmpty){
        if(_hasEnum(element.fields)){
          return true;
        }
      }
      return element.fieldType == FieldType.enum_type;
    });
  }

}


class Field {

  String name;
  FieldType fieldType;
  String fieldTypeOf;
  String description;
  List<String> enums; // This is used with enums types
  List<Field> fields; // This is used with map and list types

  Field({
    this.name,
    this.fieldType,
    this.fieldTypeOf,
    this.description,
    this.enums,
    this.fields,
  });

  /// Prints a field
  void printField({int tabsNumber}){
    String tabs = '';
    if(tabsNumber != null){
      for(int i = 0; i < tabsNumber; i++) tabs += '\t';
    }
    print(tabs + name + '::' + getFieldTypeString());
    if(fieldTypeOf.isNotEmpty) print(tabs + '\tOf => ' + fieldTypeOf);
    if(description.isNotEmpty) print(tabs + '\tDescription => ' + description);
    if(enums != null && enums.isNotEmpty){
      String _enums = tabs + '\tEnums => [ ';
      for(String _enum in enums){
        _enums += _enum + ' ';
      }
      _enums += ']';
      print(_enums);
    }
    if(fields != null && fields.isNotEmpty){
      for(Field field in fields){
        field.printField(tabsNumber: tabsNumber == null ? 1 : tabsNumber + 1);
      }
    }
  }

  /// Parse the String [type] to a FieldType and saves into [fieldType]
  void setFieldType(String type){
    if(Utils.compareString(type, FieldTypeStrings.KEY_STRING)){
      fieldType = FieldType.key;
    }
    else if(Utils.compareString(type, FieldTypeStrings.STRING_STRING)){
      fieldType = FieldType.m_string;
    }
    else if(Utils.compareString(type, FieldTypeStrings.NUMBER_STRING)){
      fieldType = FieldType.number;
    }
    else if(Utils.compareString(type, FieldTypeStrings.INT_STRING)
              || Utils.compareString(type, FieldTypeStrings.INTEGER_STRING)){
      fieldType = FieldType.m_int;
    }
    else if(Utils.compareString(type, FieldTypeStrings.DOUBLE_STRING)
              || Utils.compareString(type, FieldTypeStrings.FLOAT_STRING)){
      fieldType = FieldType.m_double;
    }
    else if(Utils.compareString(type, FieldTypeStrings.BOOL_STRING) 
              || Utils.compareString(type, FieldTypeStrings.BOOLEAN_STRING)){
      fieldType = FieldType.boolean;
    }
    else if(Utils.compareString(type, FieldTypeStrings.MAP_STRING)){
      fieldType = FieldType.map_type;
    }
    else if(Utils.compareString(type, FieldTypeStrings.LIST_STRING)){
      fieldType = FieldType.list;
    }
    else if(Utils.compareString(type, FieldTypeStrings.TIMESTAMP_STRING)
              || Utils.compareString(type, FieldTypeStrings.DATETIME_STRING)){
      fieldType = FieldType.timestamp;
    }
    else if(Utils.compareString(type, FieldTypeStrings.GEOPOINT_STRING)){
      fieldType = FieldType.geopoint;
    }
    else if(Utils.compareString(type, FieldTypeStrings.REFERENCE_STRING)){
      fieldType = FieldType.reference;
    }
    else if(Utils.compareString(type, FieldTypeStrings.ENUM_STRING)){
      fieldType = FieldType.enum_type;
    }
    else{
      fieldType = FieldType.error;
    } 
  }

  /// Gets all enum values an sets it in [enums]
  void setEnumExtras(){
    enums = [];
    if(fieldTypeOf.isEmpty) return;
    enums = fieldTypeOf.split(',');
    for(int i = 0; i < enums.length; i++){
      enums[i] = enums[i].trim();
    }
  }

  /// Parse a FiledType with the corresponding String
  String getFieldTypeString(){
    switch (fieldType){
      case FieldType.key:
        return FieldTypeStrings.KEY_STRING;
      case FieldType.m_string:
        return FieldTypeStrings.STRING_STRING;
      case FieldType.number:
        return FieldTypeStrings.NUMBER_STRING;
      case FieldType.m_int:
        return FieldTypeStrings.INTEGER_STRING;
      case FieldType.m_double:
        return FieldTypeStrings.DOUBLE_STRING;
      case FieldType.boolean:
        return FieldTypeStrings.BOOLEAN_STRING;  
      case FieldType.map_type:
        return FieldTypeStrings.MAP_STRING;
      case FieldType.list:
        return FieldTypeStrings.LIST_STRING;
      case FieldType.timestamp:
        return FieldTypeStrings.TIMESTAMP_STRING;
      case FieldType.geopoint:
        return FieldTypeStrings.GEOPOINT_STRING;
      case FieldType.reference:
        return FieldTypeStrings.REFERENCE_STRING;
      case FieldType.enum_type:
        return FieldTypeStrings.ENUM_STRING;
      case FieldType.error:
        return '';  
    }
  }
}