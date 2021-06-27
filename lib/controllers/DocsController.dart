import 'package:tomentosa/models/model.dart';
import 'package:tomentosa/services/ModelsService.dart';
import 'package:tomentosa/utils/constants/ModelConstants.dart';
import 'package:tomentosa/utils/utils.dart';

class DocsController {

  /// Gets the docs of a json file model in latex language
  /// 
  /// Use [eraseSectionNumbers] to hide the numbers of the sections
  static String getsDocsInLatex(
    String jsonFile, {
    bool eraseSectionNumbers = false,
  }){
    Model model = ModelsService.loadModel(jsonFile);
    String res = '';
    if(eraseSectionNumbers){
      res += '\\subsection*{' + model.name + '}\n\n';
    }
    else{
      res += '\\subsection{' + model.name + '}\n\n';
    }
    if(model.parents != null && model.parents.isNotEmpty){
      if(eraseSectionNumbers){
        res += '\\subsubsection*{Parents:}\n\n';
      }
      else {
        res += '\\subsubsection{Parents:}\n\n';
      }
      
      res += '\\begin{itemize}\n';
      for(String parent in model.parents){
        res += '\t\\item ' + parent + '\n';
      }
      res += '\\end{itemize}\n\n';
    }
    if(model.subcollections != null && model.subcollections.isNotEmpty){
      if(eraseSectionNumbers){
        res += '\\subsubsection*{Subcollections:}\n\n';
      }
      else {
        res += '\\subsubsection{Subcollections:}\n\n';
      }
      
      res += '\\begin{itemize}\n';
      for(String sub in model.subcollections){
        res += '\t\\item ' + sub + '\n';
      }
      res += '\\end{itemize}\n\n';
    }
    if(eraseSectionNumbers){
      res += '\\subsubsection*{Fields:}\n\n';
    }
    else{
      res += '\\subsubsection{Fields:}\n\n';
    }
    
    res += '\\begin{itemize}\n';
    for(Field field in model.fields){
      res += _writeFieldContent(field, 1);
    }
    res += '\\end{itemize}\n';
    return res;
  }

  /// Returns the field content in latex language
  /// 
  /// It generates the item for a field in the form:
  /// 
  /// \item \textbf{fieldName}\textbf{:} Description
  /// \begin{itemize}
  /// <Enum values or recursive fields>
  /// \end{itemize}
  static String _writeFieldContent(Field field, int identation){
    bool dotsFlag = false;
    String res = '';
    res += Utils.addIdentation(
      '\\item \\textbf{' + field.name + ' (' + field.getFieldTypeString() + ')}',
      identation
    );
    if(field.fieldType == FieldType.key){
      if(field.description == null || field.description.isEmpty){
        res += '\\textbf{:} Id (key) of this model.';
      }
      else res += '\\textbf{:} ' + field.description;
    }
    else if(field.fieldType == FieldType.list){
      if(field.fieldTypeOf != null && field.fieldTypeOf.isNotEmpty){
        dotsFlag = true;
        res += '\\textbf{:} List of \\textbf{' + field.fieldTypeOf + '}. ';
      }
    }
    else if(field.fieldType == FieldType.map_type){
      if(field.fieldTypeOf != null && field.fieldTypeOf.isNotEmpty){
        dotsFlag = true;
        res += '\\textbf{:} Map of \\textbf{' + field.fieldTypeOf + '}. ';
      }
    }

    //// Description of non key values
    if(field.fieldType != FieldType.key && field.description != null
          && field.description.isNotEmpty){
      if(!dotsFlag){
        res += '\\textbf{:} ';
        dotsFlag = true;
      }
      res += field.description;
    }

    /// The enum values section must to be after the description
    if(field.fieldType == FieldType.enum_type){
      if(!dotsFlag){
        res += '\\textbf{:} ';
        dotsFlag = true;
      }
      res += '\n';
      res += Utils.addIdentation('\\begin{itemize}\n', identation);
      for(String _enum in field.enums){
        res += Utils.addIdentation('\\item ' + _enum + '\n', identation + 1);
      }
      res += Utils.addIdentation('\\end{itemize}', identation);
    }

    if(field.fields != null && field.fields.isNotEmpty){
      if(!dotsFlag){
        res += '\\textbf{:} ';
        dotsFlag = true;
      }
      res += '\n';
      res += Utils.addIdentation('\\begin{itemize}\n', identation);
      for(Field _field in field.fields){
        res += _writeFieldContent(_field, identation + 1);
      }
      res += Utils.addIdentation('\\end{itemize}\n', identation);
    }
    else res += '\n';
    return res;
  }


  


}