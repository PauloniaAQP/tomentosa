import 'package:test/test.dart';
import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/utils/constants/ModelConstants.dart';

void main(){

  group('Field functions', (){
    final Field field = Field(
      name: "Test field",
      fieldTypeOf: "",
      fields: [],
      description: "Test description",
    );

    test('getFieldTypeString() & setFieldType()', (){
      field.setFieldType("__NOT A FIELD__");
      expect(field.fieldType, FieldType.error);
      for(FieldType type in FieldType.values){
        field.fieldType = type;
        String fieldString = field.getFieldTypeString();
        field.fieldType = null;
        field.setFieldType(fieldString);
        expect(field.fieldType, type);
      }
    });

    test('setEnumExtras()', (){
      field.setEnumExtras();
      expect(field.enums.isEmpty, true);
      field.fieldTypeOf = 'enum1, enum2 ,enum3';
      field.setEnumExtras();
      expect(field.enums[0], 'enum1');
      expect(field.enums[1], 'enum2');
      expect(field.enums[2], 'enum3');
    });

    test('printField()', (){
      field.fieldType = FieldType.number;
      field.printField();
    });
  });


  group('Model functions', (){
    final Field field = Field(
      name: 'Test field',
      fieldTypeOf: '',
      fields: [],
      fieldType: FieldType.number,
      description: 'Test description',
    );

    final Model model = Model(
      name: 'Model test',
      fields: [field],
      parents: ['Test parent'],
      subcollections: ['Test subcollection']
    );

    test('printModel()', (){
      model.printModel();
    });

  });

}