import './new_predicate_relationships.dart';
import './new_variable_content.dart';
import './new_variable_relationships.dart';
import './representations/mask.dart';
import 'representations/new_thinginpredicate.dart';
import './edge.dart';
import './fact_content.dart';

class FactNode extends PredicateNode
{
  FactNode
  (
    String phrase,
    String? identifier,
    {
      List<Variable?>? fromVariables,
      List< Mask? >? fromRepresentationMasks,
      int? appearesAtTopic, 
      int? obsoleteAtTopic,
    }
  )
  {
    super.topics=<int?>[appearesAtTopic,obsoleteAtTopic];
    super.predicate=Fact
    (
      phrase,
      identifier,
      fromMasks: fromRepresentationMasks, 
      fromVariables: fromVariables
    );
  }

  bool linkAFrom(VariableNode varnode, {Mask? mask})
  {
    ThingInPredicate? thing = super.predicate.findThingInPhraseByVariable
      (varnode.variable);
    if (thing!=null)
    {
      super.edge=Edge(varnode,Direction.inwards);
      if (mask!=null && thing.mask.isEmpty)
      {
        thing.setMask(mask, super.predicate.phrase);
      }
      return true;
    }
    else
    {
      super.edge=Edge(varnode,Direction.inwards);
      super.predicate.addThingInPredicate
      (
        ThingInPredicate
        (
          super.predicate.phrase,
          thing:varnode.variable,
          mask:mask
        )
      );
      return true;
    }
  }
  
  @override
  String toString() {
    String retval = "FactNode \n";
    retval+="  predicate: ${super.predicate}\n";
    retval+="  appeares at topic: ${super.appearesAtTopic}\n";
    retval+="  becomes obsolete at topic: ${super.obsoleteAtTopic==null ? 
      "never" : super.obsoleteAtTopic}\n";
    retval+="  edges: \n${super.edgesAsString}";
    return retval;
  }

  @override
  PredicateNode get copyWithNoEdges
  {
    List<ThingInPredicate>? things = super.predicate.things;
    if (things!=null && things.isNotEmpty)
    {
      List<Variable?> variables=<Variable?>[];
      List<Mask?> masks=<Mask?>[];
      for (ThingInPredicate thing in things)
      {
        variables.add(thing.thing);
        masks.add(thing.mask);
      }
      return FactNode
      (
        super.predicate.phrase,
        super.predicate.identifier,
        fromVariables: variables,
        fromRepresentationMasks: masks,
        appearesAtTopic: super.appearesAtTopic,
        obsoleteAtTopic: super.obsoleteAtTopic
      );  
    }
    else
    {
      return FactNode
      (
        super.predicate.phrase,
        super.predicate.identifier,
        appearesAtTopic: super.appearesAtTopic,
        obsoleteAtTopic: super.obsoleteAtTopic
      );
    }
  }
}
