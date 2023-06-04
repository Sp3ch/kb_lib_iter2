import './definition_content.dart';
import './new_predicate_relationships.dart';
import './new_variable_content.dart';
import './new_variable_relationships.dart';
import './representations/mask.dart';
import 'representations/new_thinginpredicate.dart';
import './edge.dart';

class DefinitionNode extends PredicateNode
{
  DefinitionNode
  (
    String phrase,
    String? identifier,
    List<Variable> toVariables,
    List<Mask> toMasks,
    {
      List<Variable?>? fromVariables,
      List< Mask? >? fromRepresentationMasks,
      int? appearesAtTopic, 
      int? obsoleteAtTopic,
    }
  )
  {
    super.topics=<int?>[appearesAtTopic,obsoleteAtTopic];
    super.predicate=Definition
    (
      phrase,
      identifier,
      toVariables,
      toMasks,
      fromMasks: fromRepresentationMasks, 
      fromVariables: fromVariables
    );
  }

  bool linkAFrom(VariableNode varnode, {Mask? mask})
  {
    ThingInPredicate? thing = super.predicate.findThingInPredicateByIdentifier
      (varnode.variable.identifier);
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

  void linkATo(VariableNode varnode, {Mask? mask})
  {
    ThingInPredicate? thing = super.predicate.findThingInPhraseByVariable
      (varnode.variable);
    super.edge=Edge(varnode,Direction.outwards);
    if (thing!=null)
    {
      if (mask!=null && thing.mask.isEmpty)
      {
        thing.setMask(mask, super.predicate.phrase);
      }
    }
    else
    {
      super.predicate.addThingInPredicate
      (
        ThingInPredicate
        (
          super.predicate.phrase,
          thing:varnode.variable,
          mask:mask
        )
      );
    }
  }

  @override
  String toString() {
    String retval = "DefinitionNode \n";
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
    List<Variable> toVariables=<Variable>[];
    List<Mask> toMasks=<Mask>[];
    List<Variable?> fromVariables=<Variable?>[];
    List<Mask?> fromMasks=<Mask?>[];
    List<Edge>? tmpedges;
    if (things!=null && things.isNotEmpty)
    {
      for (ThingInPredicate thing in things)
      {
        if (thing.thing!=null)
        {
          tmpedges = super.findAllEdgesByVariable(thing.thing!);
          if (tmpedges!=null && tmpedges.isNotEmpty)
          {
            for (Edge edge in tmpedges)
            {
              if (edge.direction==Direction.outwards)
              {
                toVariables.add(thing.thing!);
                toMasks.add(thing.mask);
                break;
              }
            }
          }
        }
      }
      return DefinitionNode
      (
        super.predicate.phrase,
        super.predicate.identifier,
        toVariables,
        toMasks,
        fromVariables: fromVariables,
        fromRepresentationMasks: fromMasks,
        appearesAtTopic: super.appearesAtTopic,
        obsoleteAtTopic: super.obsoleteAtTopic
      );  
    }
    else
    {
      throw FormatException('Попытка создать копию определения, которое ничего не определяло.');
    }
  }
}