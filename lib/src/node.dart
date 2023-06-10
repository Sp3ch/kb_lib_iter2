import './edge.dart';

abstract class Node
{
  int _appearesAtTopic = 0;
  int? _obsoleteAtTopic;
  List<Edge>? _edges;

  bool isMeaningful(int topic) 
  {
    if (obsoleteAtTopic!=null) 
    {
      return (topic>=_appearesAtTopic && topic<obsoleteAtTopic!);
    }
    else
    {
      return (topic>=appearesAtTopic);
    }
  } 

  bool edgeIsWrong(Edge edge)
  {
    return
      (
        edge.node.obsoleteAtTopic == null && obsoleteAtTopic!=null || 
        edge.node.obsoleteAtTopic != null && 
          obsoleteAtTopic !=null &&
          edge.node.obsoleteAtTopic!>obsoleteAtTopic!
      ) || 
      (
        edge.node.appearesAtTopic<appearesAtTopic
      );
  }

  bool removeEdge(Edge edge)
  {
    if (edges!=null)
    {
      for (Edge e in _edges!)
      {
        if (e.sameWith(edge))
        {
          _edges!.remove(e);
          return true;
        }
      }
    }
    return false;
  }

  bool hasTheEdge(Edge edge)
  {
    if (edges!=null)
    {
      for (Edge e in _edges!)
      {
        if (e.sameWith(edge))
        {
          return true;
        }
      }
    }
    return false;
  }

  bool isLinkedTo(Node node)
  {
    if (edges!=null)
    {
      for (Edge e in _edges!)
      {
        if (e.node==node) {return true;}
      }
    }
    return false;
  }

  set appearesAtTopic(int appearesAtTopic)
  {
    
    if (_obsoleteAtTopic!=null && _obsoleteAtTopic!<=appearesAtTopic)
    {
      throw FormatException('Попытка задать время введения термина или высказываняи после времени потери актуальности. (1)');
    }
    else
    {
      _appearesAtTopic=appearesAtTopic;
    }
  }

  set obsoleteAtTopic(int? obsoleteAtTopic)
  {
    if (obsoleteAtTopic!=null && _appearesAtTopic>=obsoleteAtTopic)
    {
      throw FormatException('Попытка задать время введения термина или высказываняи после времени потери актуальности. (2)');
    }
    else
    {
      _obsoleteAtTopic=obsoleteAtTopic;
    }
  }

  set topics(List<int?> topics)
  {
    if (topics[0]==null)
    {
      throw FormatException('Попытка ввести тему введения понятия или факта бесконечной.');
    }
    else
    {
      appearesAtTopic=topics[0]!;
      obsoleteAtTopic=topics[1]; 
    }
  }

  set edges(List<Edge>? edges)
  {
    if (edges==null){_edges=null;}
    else
    {
      for (Edge e in edges)
      {
        if (hasTheEdge(e))
        {
          throw FormatException('Попытка создать повторяющееся ребро.');
        }
      }
      _edges ??=<Edge>[];
      _edges!.addAll(edges);
    }
  }

  set edge(Edge value)
  {
    if (!hasTheEdge(value))
    {
      _edges ??= <Edge>[];
      _edges!.add(value);
      if 
      (
        !value.node.hasTheEdge
        (
          Edge
          (
            this,
            value.direction==Direction.inwards 
            ? Direction.outwards 
            : Direction.inwards
          )
        )
      )
      {
        value.node.edge=Edge
        (
          this,
          value.direction==Direction.inwards 
          ? Direction.outwards 
          : Direction.inwards
        );
      }
    }
    else
    {
      if (hasTheEdge(value))
      {
        throw FormatException('Попытка создать повторяющееся ребро: $value');
      }
    }
  }

  @override
  String toString() 
  {
    String retval="Node\n";
    retval+="  appeares at topic: $_appearesAtTopic\n";
    retval+="  becomes obsolete at topic: ${_obsoleteAtTopic==null ? 
      "never" : _obsoleteAtTopic}\n";
    retval+="  edges: \n$edgesAsString";
    return retval;
  }

  //чтобы сначала принтить входящие, потом исходящие
  String get edgesAsString 
  {
    if (_edges==null) {return "null";}
    String retval="";
    List<Edge> inwards=<Edge>[];
    List<Edge> outwards=<Edge>[];
    for (Edge edge in _edges!)
    {
      if (edge.direction==Direction.inwards) {inwards.add(edge);}
      else {outwards.add(edge);}
    }
    for (Edge edge in inwards) {retval+="    $edge\n";}
    for (Edge edge in outwards) {retval+="    $edge\n";}
    return retval;
  }

  int get appearesAtTopic => _appearesAtTopic;
  int? get obsoleteAtTopic => _obsoleteAtTopic;
  List<Edge>? get edges => _edges==null ? null : <Edge>[]+_edges!;
  
  ///Get all the connections, going inwards
  List<Edge>? get inEdges
  {
    if (_edges == null)
    {
      return null;
    }
    else
    {
      List<Edge> retval = <Edge>[];
      for (Edge edge in _edges!)
      {
        if (edge.direction == Direction.inwards)
        {
          retval.add(edge);
        }
      }
      if (retval.isEmpty){return null;}
      else{return retval;}
    }
  }

  ///Get all the connections, going outwards
  List<Edge>? get outEdges
  {
    if (_edges == null)
    {
      return null;
    }
    else
    {
      List<Edge> retval = <Edge>[];
      for (Edge edge in _edges!)
      {
        if (edge.direction == Direction.outwards)
        {
          retval.add(edge);
        }
      }
      if (retval.isEmpty){return null;}
      else{return retval;}
    }
  }
}