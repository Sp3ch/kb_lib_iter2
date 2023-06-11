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
    List<VariableNode> toVariableNodes,
    List<Mask> toMasks,
    {
      List<VariableNode?>? fromVariableNodes,
      List< Mask? >? fromRepresentationMasks,
      int? appearesAtTopic, 
      int? obsoleteAtTopic,
    }
  )
  {
    super.topics=<int?>[appearesAtTopic,obsoleteAtTopic];
    List<Variable> toVariables = <Variable>[];
    List<Variable?>? fromVariables = <Variable>[];
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
        else {fromVariables.add(null);}
      }
    }
    else {fromVariables=null;}
    for (VariableNode toNode in toVariableNodes)
    {
      if (!inConstructorTopicsCheck(toNode))
      {
        throw FormatException('Попытка создать Определение, для которого одно из используемых или определяемых понятий утрачивает силу или вводится поздно во время рассмотрения определения (\"${toNode.variable.identifier}\" для \"$phrase\").');
      }
      toVariables.add(toNode.variable);
    }
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
    List<VariableNode> toVariableNodes = <VariableNode>[];
    List<VariableNode?>? fromVariableNodes;
    List<ThingInPredicate>? things = super.predicate.things;
    List<Mask> toMasks=<Mask>[];
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
              if ((edge.node as VariableNode).variable==thing.thing)
              {
                if (edge.direction==Direction.outwards)
                {
                  toVariableNodes.add(edge.node as VariableNode);
                  toMasks.add(thing.mask);
                  break;
                }
                else if (edge.direction==Direction.inwards)
                {
                  fromVariableNodes ??= <VariableNode?>[];
                  fromVariableNodes.add(edge.node as VariableNode);
                }
              }
            }
          }
        }
      }
      return DefinitionNode
      (
        super.predicate.phrase,
        super.predicate.identifier,
        toVariableNodes,
        toMasks,
        fromVariableNodes: fromVariableNodes,
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