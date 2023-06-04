import './new_predicate_content.dart';
import './new_variable_content.dart';
import './representations/mask.dart';
import 'representations/new_thinginpredicate.dart';

class Fact extends Predicate
{
  Fact
  (
    String phrase,
    String? identifier,
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
      for (Mask? mask in fromMasks)
      {
        if(mask!=null)
        {
          nonnulMasks.add(mask);
        }
      }
    }
    if (!Mask.collide(nonnulMasks))
    {
      throw FormatException(' Попытка создания Факта с пересекающимися масками.');
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
        throw FormatException('Попытка создания факта, для которого не совпадают количества поданных понятий и их масок.');
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
    String retval="Fact (\"";
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
