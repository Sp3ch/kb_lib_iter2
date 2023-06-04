import './node.dart';
import './new_variable_content.dart';
import './definition_relationships.dart';
import './new_predicate_content.dart';
import './new_predicate_relationships.dart';
import './edge.dart';

abstract class VariableNode extends Node
{
  late Variable _variable;
  bool _created = false;

  @override
  bool edgeIsWrong(Edge edge)
  {
    if 
    (
      edge.direction==Direction.outwards || 
      (
        edge.direction==Direction.inwards && 
        edge.node.runtimeType==DefinitionNode
      )
    )
    {
      return super.edgeIsWrong(edge);
    }
    else if (edge.direction==Direction.inwards)
    {
      return 
      (
        super.obsoleteAtTopic!=null && 
        super.obsoleteAtTopic!<=edge.node.appearesAtTopic
      ) || 
      (
        edge.node.obsoleteAtTopic!=null && 
        edge.node.obsoleteAtTopic!<=super.appearesAtTopic
      );
    }
    return false;
  }

  Edge? getCurrentDefinitionEdge(int topic)
  {
    List<Edge>? tmpEdges = super.edges;
    if (tmpEdges!=null)
    {
      for (Edge e in tmpEdges)
      {
        if (e.node.runtimeType==DefinitionNode)
        {
          if (e.node.isMeaningful(topic))
          {
            return e;
          }
        }
      }
    }
    return null;
  }

  DefinitionNode? getCurrentDefinition(topic) 
    => getCurrentDefinitionEdge(topic)?.node as DefinitionNode;

  List<Edge>? findAllEdgesByPredicate(Predicate predicate)
  {
    List<Edge> retval = <Edge>[];
    List<Edge>? superEdges = super.edges;
    if (superEdges!=null && superEdges.isNotEmpty)
    {
      for (Edge edge in superEdges)
      {
        if ((edge.node as PredicateNode).predicate==predicate)
        {
          retval.add(edge);
        }
      }
      return retval;
    }
    else{return null;}
  }

  set variable(Variable variable)
  {
    if (!_created)
    {
      _created=true;
      _variable = variable;
    }
  }

  set definition(DefinitionNode definition)
  {
    Edge setval = Edge(definition,Direction.inwards);
    if (edgeIsWrong(setval))
    {
      throw FormatException('Попытка задать невозможное по темам введения и актуальности отношение для двух вершин графа.');
    }
    List<Edge>? tmpEdges = super.edges;
    if (tmpEdges!=null)
    {
      for (Edge e in tmpEdges)
      {
        if (e.node.runtimeType==DefinitionNode)
        {
          if 
          (
            e.node.obsoleteAtTopic==null && definition.obsoleteAtTopic==null
            ||
            e.node.obsoleteAtTopic==null && definition.obsoleteAtTopic!=null &&
            definition.obsoleteAtTopic! > e.node.appearesAtTopic
            ||
            definition.obsoleteAtTopic==null && e.node.obsoleteAtTopic!=null && 
            e.node.appearesAtTopic>definition.appearesAtTopic
            ||
            e.node.obsoleteAtTopic!=null && definition.obsoleteAtTopic!=null &&
            (
              e.node.appearesAtTopic < definition.obsoleteAtTopic! &&
              e.node.obsoleteAtTopic! > definition.appearesAtTopic
            )
          )
          {
            throw FormatException('Попытка переопределить определение для переменной.');
          }
        }
      }
    }
    super.edge=setval;
  }

  @override
  String toString() 
  {
    String retval = "VariableNode \n";
    retval+='  variable: $_variable\n';
    retval+="  appeares at topic: ${super.appearesAtTopic}\n";
    retval+="  becomes obsolete at topic: ${super.obsoleteAtTopic==null ? 
      "never" : super.obsoleteAtTopic}\n";
    retval+="  edges: \n${super.edgesAsString}";
    return retval;
  }

  bool get hasDefinition
  {
    List<Edge>? tmpEdges = super.edges;
    if (tmpEdges!=null)
    {
      for (Edge e in tmpEdges)
      {
        if (e.node.runtimeType==DefinitionNode)
        {
          return true;
        }
      }
    }
    return false;
  }

  Variable get variable => _variable;
  
  List<Edge>? get allDefinitionEdges
  {
    List<Edge>? tmpEdges = super.edges;
    List<Edge> retval = <Edge>[];
    if (tmpEdges!=null)
    {
      for (Edge e in tmpEdges)
      {
        if (e.node.runtimeType==DefinitionNode)
        {
          retval.add(e);
        }
      }
    }
    if (retval.isEmpty)
    {
      return null;
    }
    return retval;
  }

  List<DefinitionNode>? get allDefinitions
  {
    List<Edge>? tmpEdges = allDefinitionEdges;
    List<DefinitionNode> retval = <DefinitionNode>[];
    if (tmpEdges!=null)
    {
      for (Edge e in tmpEdges)
      {
        if (e.node.runtimeType==DefinitionNode)
        {
          retval.add(e.node as DefinitionNode);
        }
      }
    }
    if (retval.isEmpty)
    {
      return null;
    }
    return retval;
  }
}
