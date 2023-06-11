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
      List<VariableNode?>? fromVariableNodes,
      List< Mask? >? fromRepresentationMasks,
      int? appearesAtTopic, 
      int? obsoleteAtTopic,
    }
  )
  {
    super.topics=<int?>[appearesAtTopic,obsoleteAtTopic];
    List<Variable?>? fromVariables = <Variable?>[];
    if (fromVariableNodes!=null)
    {
      for (VariableNode? fromNode in fromVariableNodes)
      {
        if (fromNode!=null) 
        {
          if (!inConstructorTopicsCheck(fromNode))
          {
            throw FormatException('Попытка создать Определение, для которого одно из используемых или определяемых понятий утрачивает силу или вводится поздно во время рассмотрения определения (\"${fromNode.variable.identifier}\" для \"$phrase\").');
          }
          fromVariables.add(fromNode.variable);
        }
      }
    }
    else {fromVariables = null;}
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
      List<VariableNode?> variableNodes=<VariableNode?>[];
      List<Mask?> masks=<Mask?>[];
      for (ThingInPredicate thing in things)
      {
        if (thing.thing!=null)
        {
          List<Edge>? searchval = findAllEdgesByVariable(thing.thing!);
          if (searchval!=null && searchval.isNotEmpty)
          {
            for (Edge edge in searchval)
            {
              if ((edge.node as VariableNode).variable==thing.thing)
              {
                variableNodes.add(edge.node as VariableNode);
                masks.add(thing.mask);
              }
            }
          }
        }
      }
      return FactNode
      (
        super.predicate.phrase,
        super.predicate.identifier,
        fromVariableNodes: variableNodes,
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
