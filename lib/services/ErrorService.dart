class ModelErrorService{

  static void throwIsNotJson(String fileName){
    throw Exception('File ' + fileName + ' is not a json file');
  }

  static void throwHasNotValue(String fileName, String field){
    throw Exception('File ' + fileName + "' has not a value in '" + field + "'");
  }

  static void throwNotValidType(String fileName, String type){
    throw Exception('Error in ' + fileName + ", field type '" + type +
                  "' is not a valid type");
  }

  static void throwMustHaveOf(String fileName, String type, String fieldName){
    throw Exception('Error in ' + fileName + ", field type '" + type + 
                  "' in '" + fieldName + "' must have the 'of' opiton");
  }

  static void throwMustHaveType(String fileName, String fieldName){
    throw Exception('Error in ' + fileName + ", the field '" + fieldName +
                  "' must have the 'type' option");
  }

  static void throwEmptyOption(String fileName, String fieldName, String option){
    throw Exception('Error in ' + fileName + ", field '" + fieldName +
                    "' has an empty '" + option + "' option");
  }

  static void throwFieldsOption(String fileName, String fieldName){
    throw Exception('Error in ' + fileName + ", the field '" +
              fieldName + "has to be 'Map' or 'List' to contain 'fields'");
  }

}