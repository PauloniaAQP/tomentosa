class ProjectFiles {

  static const String FLUTTER_TEMPLATE_PATH = './flutter_project_template/';
  static const String LIB_DIR_NAME = 'lib/';
  static const String UTILS_DIR_NAME = 'utils/';
  static const String CONSTANTS_DIR_NAME = 'constants/';
  static const String ENUMS_DIR_NAME = 'enums/';

  static const String FIRESTORE_DIR_NAME = 'firestore/';
  static const String COLLECTIONS_DIR_NAME = 'collections/';
  static const String MODELS_DIR_NAME = 'models/';
  static const String FIRESTORE_CONSTANTS_FILE_NAME = 'FirestoreConstants.dart';
  static const String ENUMS_POSTFIX_FILE_NAME = 'Enums.dart';

  static const String DART_EXTENSION = '.dart';
  static const String MODEL_POSTFIX = 'Model';

  static const String FIRESTORE_CONSTANTS_FILE_PATH = LIB_DIR_NAME + 
        UTILS_DIR_NAME + CONSTANTS_DIR_NAME + FIRESTORE_DIR_NAME +
        FIRESTORE_CONSTANTS_FILE_NAME;
  static const String COLLECTIONS_DIR_PATH = LIB_DIR_NAME + 
        UTILS_DIR_NAME + CONSTANTS_DIR_NAME + FIRESTORE_DIR_NAME +
        COLLECTIONS_DIR_NAME;
  static const String ENUMS_DIR_PATH = LIB_DIR_NAME + UTILS_DIR_NAME + CONSTANTS_DIR_NAME
        + ENUMS_DIR_NAME;
  static const String MODELS_DIR_PATH = LIB_DIR_NAME + MODELS_DIR_NAME;

}