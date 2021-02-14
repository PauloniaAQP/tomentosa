enum FieldType{
  key,
  m_string,
  number,
  m_int,
  m_double,
  boolean,
  map_type,
  list,
  timestamp,
  geopoint,
  reference,
  enum_type,
  error,
}

class FieldTypeStrings {

  static const String KEY_STRING = 'Key';
  static const String STRING_STRING = 'String';
  static const String NUMBER_STRING = "Number";
  static const String INT_STRING = "Int";
  static const String INTEGER_STRING = "Integer";
  static const String DOUBLE_STRING = "Double";
  static const String FLOAT_STRING = "Float";
  static const String BOOLEAN_STRING = "Boolean";
  static const String BOOL_STRING = "Bool";
  static const String MAP_STRING = "Map";
  static const String LIST_STRING = "List";
  static const String TIMESTAMP_STRING = "Timestamp";
  static const String DATETIME_STRING = "DateTime";
  static const String GEOPOINT_STRING = "Geopoint";
  static const String REFERENCE_STRING = "Reference";
  static const String ENUM_STRING = "Enum";

}