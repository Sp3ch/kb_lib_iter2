import './new_predicate_content.dart';
import './new_variable_content.dart';
import './representations/mask.dart';
import 'representations/new_thinginpredicate.dart';

class Definition extends Predicate
{
  Definition
  (
    String phrase,
    String? identifier,
    List<Variable> toVariables,
    List<Mask> toMasks,
    {
      List<Mask?>? fromMasks,
      List<Variable?>? fromVariables
    }
  )
  {
    super.phrase=phrase;
    if (identifier==null) {super.identifier=phrase;}
    else {super.identifier=identifier;}
    List<Mask> nonnulMasks=<Mask>[];
    if (fromMasks!=null && fromMasks.isNotEmpty)
    {
      for (Mask? mask in fromMasks+toMasks)
      {
        if(mask!=null && !mask.isEmpty)
        {
          nonnulMasks.add(mask);
        }
      }
    }
    if (Mask.collide(nonnulMasks))
    {
      throw FormatException('Попытка создания Определения с пересекающимися масками.');
    }
    if (toVariables.length==toMasks.length)
    {
      for (int i=0;i<toVariables.length;i++)
      {
        super.addThingInPredicate(
          ThingInPredicate
          (
            phrase,
            thing:toVariables[i],
            mask:toMasks[i]
          )
        );
      }
    }
    else
    {
      throw FormatException('Попытка создания определения, для которого не совпали количества поданных определяемых терминов и масок для них.');
    }
    if (fromVariables!=null && fromMasks!=null)
    {
      if (fromVariables.length == fromMasks.length)
      {
        for (int i=0;i<fromVariables.length;i++)
        {
          super.addThingInPredicate
          (
            ThingInPredicate
            (
              phrase,
              thing: fromVariables[i],
              mask: fromMasks[i]
            )
          );
        }
      }
      else
      {
        throw FormatException('Попытка создания определения, для которого не совпали количества поданных определяющих терминов и масок для них.');
      }
    }
    else if (fromVariables!=null)
    {
      for (Variable? variable in fromVariables)
      {
        super.addThingInPredicate
        (
          ThingInPredicate
          (
            phrase,
            thing:variable
          )
        );
      }
    }
    else if (fromMasks!=null)
    {
      
      for (Mask? mask in fromMasks)
      {
        super.addThingInPredicate
        (
          ThingInPredicate
          (
            phrase,
            mask:mask
          )
        );
      }
    }
    clearAllEmptyThingInPredicates();
  }

  @override
  String toString() {
    String retval="Definition (\"";
    if (identifier.length<20){retval+=super.identifier;}
    else {retval+="${super.identifier.substring(0,20)}...";}
    retval+='")\n';
    if (things==null){retval+="    things: null";}
    else
    {
      retval+="    things:";
      for (ThingInPredicate thing in things!)
      {
        retval+="\n      $thing";
      }
    }
    return retval;
  }
}
