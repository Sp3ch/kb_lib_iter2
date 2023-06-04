import './new_predicate_content.dart';
import './new_variable_relationships.dart';
import './new_variable_content.dart';
import './edge.dart';
import './node.dart';

abstract class PredicateNode extends Node 
{
  late Predicate _predicate;
  bool _created = false;

  List<Edge>? findAllEdgesByVariable(Variable variable)
  {
    List<Edge> retval = <Edge>[];
    List<Edge>? superEdges = super.edges;
    if (superEdges!=null && superEdges.isNotEmpty)
    {
      for (Edge edge in superEdges)
      {
        if ((edge.node as VariableNode).variable==variable)
        {
          retval.add(edge);
        }
      }
      return retval;
    }
    else{return null;}
  }
  
  set predicate(Predicate predicate)
  {
    if (!_created)
    {
      _predicate=predicate;
      _created=true;
    }
  }

  @override
  String toString() 
  { 
    String retval = "PredicateNode \n";
    retval+="  predicate: $_predicate\n";
    retval+="  appeares at topic: ${super.appearesAtTopic}\n";
    retval+="  becomes obsolete at topic: ${super.obsoleteAtTopic==null ? 
      "never" : super.obsoleteAtTopic}\n";
    retval+="  edges: \n${super.edgesAsString}";
    return retval;
  }

  Predicate get predicate => _predicate;
  bool get hasDependencies
  {
    if (super.edges==null || super.edges!.isEmpty)
    {
      return false;
    }
    for (Edge edge in super.edges!)
    {
      if (edge.direction==Direction.inwards) {return true;}
    }
    return false;
  }

  bool get isImportantToDescendants
  {
    if (super.edges==null || super.edges!.isEmpty)
    {
      return false;
    }
    for (Edge edge in super.edges!)
    {
      if (edge.direction==Direction.outwards) {return true;}
    }
    return false;
  }

  /// Should return the object of the descendant of [PreicateNode], in which 
  /// the descendant of [Predicate] object is preserved the same, however the
  /// returned object is different. The logic of transfering the edges should
  /// depend on the type of the [Node] and the context of making a copy.
  /// One of it's uses is to make a copy of the [Graph], which will share the
  /// same terms and knowledge with the origin, but will be the separate graph,
  /// in which case the terms and knowledge will stick to the shared [Predicate]
  /// objects.
  PredicateNode get copyWithNoEdges;
}
