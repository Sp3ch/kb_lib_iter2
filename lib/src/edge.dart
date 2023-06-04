import './new_predicate_relationships.dart';
import './new_variable_relationships.dart';
import './node.dart';

///
enum Direction {inwards, outwards}

///
enum NodeType {predicate, variable}

///
///
class Edge
{
  late Node _node;
  late final Enum _direction;
  late final Enum _type;

  Edge(Node node, Enum direction)
  {
    _node = node;
    if (!Direction.values.contains(direction))
    {
      throw FormatException('Непредвиденный объект перечисления: $direction. Ожидался объект перечисления Direction.');
    }
    if (node is PredicateNode) {_type = NodeType.predicate;}
    else if (node is VariableNode) {_type = NodeType.variable;}
    else
    {
      throw FormatException('Никакой тип не подходит для конца создаваемого ребра.');
    }
    _direction = direction;
  }

  bool sameWith(Edge edge) => edge._node==_node && edge._direction==direction;

  static Edge connectWith(Node node, Edge edge)
  {
    Edge retval = Edge
    (
      node, 
      edge._direction == Direction.inwards ? 
        Direction.outwards :
        Direction.inwards
    );
    node.edge=retval;
    return retval;
  }

  @override
  String toString() => "Edge: \n"+
  (
    _type == NodeType.predicate 
    ? "    from the P_node named: ${(_node as PredicateNode).predicate.identifier.substring(0,20)}\n"
    : _type == NodeType.variable
    ? "    from the V_node named: ${(_node as VariableNode).variable.identifier}\n"
    : ""
  )+
  "    direction: ${_direction==Direction.inwards ? "inwards" : "outwards"}, \n"+
  "    type: ${_type==NodeType.predicate ? "predicate" : "variable"}\n";

  get direction => _direction;
  Node get node => _node;
  get type => _type;
}
