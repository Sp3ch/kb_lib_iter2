import './new_variable_content.dart';
import './new_variable_relationships.dart';

class Term extends Variable
{
  Term(String mainAlias, String? identifier, {List<String>? aliases})
  {
    super.mainAlias=mainAlias;
    if (identifier==null) {super.identifier=mainAlias;}
    else {super.identifier=identifier;}
    if (aliases!=null)
    {
      super.aliases=aliases;
    }
  }
}

class TermNode extends VariableNode
{
  TermNode
  (
    Term term, 
    {
      int? appearesAtTopic, 
      int? obsoleteAtTopic
    }
  )
  {
    super.variable = term;
    super.topics=<int?>
    [
      appearesAtTopic ?? 0,
      obsoleteAtTopic
    ];
  }
}

