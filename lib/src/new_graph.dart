import './new_variable_relationships.dart';
import './new_variable_content.dart';
import './new_predicate_relationships.dart';
import './edge.dart';
import './representations/mask.dart';
import './representations/segment.dart';
import './term.dart';
import './fact_relationships.dart';
import './definition_relationships.dart';
import './node.dart';
import 'dart:convert';

class Graph
{
  String? name;
  List<VariableNode> _variableNodes=[];
  List<PredicateNode> _predicateNodes=[];
  Graph({this.name});

  void addVariable(VariableNode variableNode)
    => _variableNodes.add(variableNode);

  void addPredicate
  (
    PredicateNode predicateNode)
    => _predicateNodes.add(predicateNode);

  List<VariableNode>? findAllVariableNodesByAlias(String alias)
  {
    List<VariableNode> retval = <VariableNode>[];
    for (VariableNode variableNode in _variableNodes)
    {
      if 
      (
        variableNode.variable.mainAlias==alias || 
        variableNode.variable.hasOtherAliases &&
          variableNode.variable.otherAliases!.contains(alias)
      )
      {
        retval.add(variableNode);
      }
    }
    if (retval.isEmpty){return null;}
    else {return retval;}
  }

  VariableNode? findVariableNodeByIdentifier(String identifier)
  {
    for (VariableNode variableNode in _variableNodes)
    {
      if (variableNode.variable.identifier==identifier)
      {
        return variableNode;
      }
    }
    return null;
  }

  PredicateNode? findPredicateNodeByIdentifier(String identifier)
  {
    for (PredicateNode predicateNode in _predicateNodes)
    {
      if (predicateNode.predicate.identifier==identifier)
      {
        return predicateNode;
      }
    }
    return null;
  }

  List<T> allNodesTyped<T extends Node>()
  {
    List<T> retval = <T>[];
    if (<T>[] is List<VariableNode>)
    {
      for (VariableNode vn in _variableNodes)
        {if (vn is T) {retval.add(vn as T);}}
    }
    else if (<T>[] is List<PredicateNode>)
    {
      for (PredicateNode pn in _predicateNodes)
        {if (pn is T) {retval.add(pn as T);}}
    }
    return retval;
  }



  static Graph fromSaveFile_knowledgeOnly(String contents)
  {
    final json = jsonDecode(contents);
    final constants=json[0];
    try
    {
      String nameAlias=constants["name"];
      String TYPE = constants["type"];
      String IDENTIFIER = constants["identifier"];
      String TERM = constants["term"];
      String FACT = constants["fact"];
      String DEFINITION = constants["definition"];
      String ALIAS = constants["alias"];
      String OTHER_ALIASES = constants["other aliases"];
      String PHRASE = constants["phrase"];
      String AFFECTS = constants["affects"];
      String DEPENDS_ON = constants["depends on"];
      String MASK = constants["mask"];
      String START = constants["start"];
      String END = constants["end"];
    }
    catch (e)
    {
      throw FormatException("При попытке чтения константных ключей файла знаний произошла ошибка. \nПроверьте головной объект задания ключей.");
    }
    final String nameAlias=constants["name"];
    final String TYPE = constants["type"];
    final String IDENTIFIER = constants["identifier"];
    final String TERM = constants["term"];
    final String FACT = constants["fact"];
    final String DEFINITION = constants["definition"];
    final String ALIAS = constants["alias"];
    final String OTHER_ALIASES = constants["other aliases"];
    final String PHRASE = constants["phrase"];
    final String AFFECTS = constants["affects"];
    final String DEPENDS_ON = constants["depends on"];
    final String MASK = constants["mask"];
    final String START = constants["start"];
    final String END = constants["end"];
    Graph retval = Graph(name: json[0][nameAlias]);

    bool isUnknownTag(String tag) => 
    (
      tag!= nameAlias && 
      tag!= TYPE && 
      tag!= IDENTIFIER && 
      tag!= TERM && 
      tag!= FACT && 
      tag!= DEFINITION && 
      tag!= ALIAS && 
      tag!= OTHER_ALIASES && 
      tag!= PHRASE && 
      tag!= AFFECTS && 
      tag!= DEPENDS_ON && 
      tag!= MASK && 
      tag!= START && 
      tag!= END && 
      true
    );

    String? variableMainAlias;
    String variableIdentifier;
    List<dynamic>? voa; // variable's other aliases
    List<String>? variableOtherAliases;
    int? variableStart;
    int? variableEnd;

    String? predicatePhrase;
    String predicateIdentifier="";
    dynamic predicateAffects;
    dynamic predicateDependsOn;
    List<String>? predicateAffectsAliases;
    List<String>? predicateAffectsIdentifiers;
    List<VariableNode>? predicateAffectsVariableNodes = <VariableNode>[];
    List<Variable>? predicateAffectsVariables = <Variable>[];
    List<Mask>? predicateAffectsMasks;
    List<String>? predicateDependsOnAliases;
    List<String>? predicateDependsOnIdentifiers;
    List<Variable>? predicateDependsOnVariables=<Variable>[];
    List<VariableNode>? predicateDependsOnVariableNodes=<VariableNode>[];
    List<Mask>? predicateDependsOnMasks;
    int? predicateStart;
    int? predicateEnd;
    List<List<int>> tmpmask=<List<int>>[];
    List<Segment> tmpSegments=<Segment>[];

    for (int i=1;i<json.length;i++)
    {
      for (String key in json[i].keys)
      {
        if (isUnknownTag(key))
        {
          throw FormatException("Незаданный ключ в объекте json: \"$key\":\"${json[i][key]}\"");
        }
      }

      if (json[i][TYPE]==TERM)
      {
        variableMainAlias=json[i][ALIAS];
        if (variableMainAlias==null)
        {
          throw FormatException("Найдена переменная без основного обозначения.");
        }
        if (json[i][IDENTIFIER]==null){variableIdentifier = variableMainAlias;}
        else {variableIdentifier=json[i][IDENTIFIER];}
        voa=json[i][OTHER_ALIASES];
        if (voa!=null)
        {
          variableOtherAliases=<String>[];
          for (dynamic s in voa)
          {
            if (s.runtimeType!=String)
            {
              throw FormatException('Одно из поданных возможных обозначений понятия $variableMainAlias не строка.');
            }
            else
            {
              variableOtherAliases.add(s);
            }
          }
        }
        else
        {
          variableOtherAliases=null;
        }
        variableStart=json[i][START];
        variableEnd=json[i][END];
        if (variableStart==null)
        {
          throw FormatException('Не задана тема введения термина $variableMainAlias');
        }
        else if (retval.findVariableNodeByIdentifier(variableIdentifier)!=null)
        {
          throw FormatException('Попытка задания термина $TERM с совпадением идентфикатора $IDENTIFIER с уже имеющимся в базе.');
        }
        else
        {
          retval.addVariable
          (
            TermNode
            (
              Term
              (
                variableMainAlias,
                variableIdentifier,
                aliases:variableOtherAliases,
              ),
              appearesAtTopic: variableStart,
              obsoleteAtTopic: variableEnd
            )
          );
        }
      }

      else if (json[i][TYPE]==FACT)
      {
        predicatePhrase=json[i][PHRASE];
        if (predicatePhrase==null)
        {
          throw FormatException('Попытка создания Фразы ни о чём, то есть не содержащей текста во фразе.');
        }
        if (json[i][IDENTIFIER]==null) {predicateIdentifier=predicatePhrase;}
        else {predicateIdentifier=json[i][IDENTIFIER];}
        predicateStart=json[i][START];
        predicateEnd=json[i][END];
        if (predicateStart==null)
        {
          throw FormatException('Не задана тема введения фразы: $predicatePhrase');
        }
        predicateDependsOn=json[i][DEPENDS_ON];
        predicateDependsOnMasks=null;
        predicateDependsOnAliases=null;
        if (predicateDependsOn!=null)
        {
          predicateDependsOnAliases=<String>[];
          predicateDependsOnMasks=<Mask>[];
          predicateDependsOnIdentifiers = <String>[]; 
          for (var dependsOnObject in predicateDependsOn)
          {
            if (dependsOnObject!=null && dependsOnObject[TERM]!=null)
            {
              if (dependsOnObject[TERM]==null)
              {
                throw FormatException('Один из "$DEPENDS_ON" объектов не имеет "$TERM" поля.');
              }
              predicateDependsOnAliases.add(dependsOnObject[TERM]);
              if (dependsOnObject[IDENTIFIER]==null)
              {
                predicateDependsOnIdentifiers.add(predicateDependsOnAliases.last);
              }
              else
              {
                predicateDependsOnIdentifiers.add(dependsOnObject[IDENTIFIER]);
              }
              if (dependsOnObject[MASK]!=null)
              {
                tmpmask=<List<int>>[];
                for (var segment in dependsOnObject[MASK])
                {
                  if (segment!=null && segment.length>1)
                  {
                    tmpmask.add(<int>[segment[0],segment[1]]);
                  }
                  else
                  {
                    throw FormatException('Неверный формат маски: ${dependsOnObject[MASK]}.');
                  }
                }
                tmpSegments=<Segment>[];
                for (List<int> seg in tmpmask)
                {
                  tmpSegments.add(Segment(start:seg[0], end:seg[1]));
                }
                predicateDependsOnMasks.add(Mask(segments: tmpSegments));
              }
              else
              {
                predicateDependsOnMasks.add(Mask());
                // 
              }
            }
          }
        }
        else
        {
          predicateDependsOnAliases=null;
          predicateDependsOnMasks=null;
        }
        if (retval.findPredicateNodeByIdentifier(predicateIdentifier)!=null)
        {
          throw FormatException('Попытка ввести "$FACT" с одинаковым "$IDENTIFIER" с уже имеющимся в базе.');
        }
        else
        {
          if 
          (
            predicateDependsOnIdentifiers!=null &&
            predicateDependsOnMasks!=null && 
            predicateDependsOnAliases!=null 
          )
          {
            predicateDependsOnVariables=<Variable>[];
            predicateDependsOnVariableNodes=<VariableNode>[];
            for (int j=0;j<predicateDependsOnIdentifiers.length;j++)
            { 
              VariableNode? tmpvarnode = retval.findVariableNodeByIdentifier(predicateDependsOnIdentifiers[j]);
              if (tmpvarnode==null)
              {
                throw FormatException('Попытка задать $DEFINITION, использующий термин, до того, как был задан термин.');
              }
              else
              {
                predicateDependsOnVariableNodes.add(tmpvarnode);
                predicateDependsOnVariables.add(tmpvarnode.variable);
              }
            }
          }
          else
          {
            predicateDependsOnVariableNodes=null;
            predicateDependsOnVariables=null;
          }
          FactNode addDefNode = FactNode
          (
            predicatePhrase,
            predicateIdentifier,
            fromVariables: predicateDependsOnVariables,
            fromRepresentationMasks: predicateDependsOnMasks,
            appearesAtTopic: predicateStart,
            obsoleteAtTopic: predicateEnd
          );
          if (predicateDependsOnVariableNodes!=null)
          {
            for (VariableNode dependsOnNode in predicateDependsOnVariableNodes)
            {
              addDefNode.edge=Edge(dependsOnNode,Direction.inwards);
            } 
          }
          retval.addPredicate(addDefNode);
        }
      }

      else if (json[i][TYPE]==DEFINITION)
      {
        predicatePhrase=json[i][PHRASE];
        if (predicatePhrase==null)
        {
          throw FormatException('Попытка создать "$DEFINITION" ни о чём, не содержащее текста во фразе.');
        }
        if (json[i][IDENTIFIER]==null) {predicateIdentifier=predicatePhrase;}
        else {predicateIdentifier=json[i][IDENTIFIER];}
        predicateStart=json[i][START];
        predicateEnd=json[i][END];
        if (predicateStart==null)
        {
          throw FormatException('Не было задано темы введения определения с фразой: "$predicatePhrase"');
        }
        predicateAffects=json[i][AFFECTS];
        if (predicateAffects!=null)
        {
          predicateAffectsAliases=<String>[];
          predicateAffectsMasks=<Mask>[];
          predicateAffectsIdentifiers = <String>[]; 
          for (var affectsObject in predicateAffects)
          {
            if (affectsObject!=null && affectsObject[TERM]!=null)
            {
              if (affectsObject[TERM]==null)
              {
                throw FormatException('Один из "$AFFECTS" объектов не содержит ссылки по "$TERM".');
              }
              predicateAffectsAliases.add(affectsObject[TERM]);
              if (affectsObject[IDENTIFIER]==null)
              {
                predicateAffectsIdentifiers.add(predicateAffectsAliases.last);
              }
              else
              {
                predicateAffectsIdentifiers.add(affectsObject[IDENTIFIER]);
              }
              if (affectsObject[MASK]!=null)
              {
                tmpmask=<List<int>>[];
                for (var segment in affectsObject[MASK])
                {
                  if (segment!=null && segment.length>1)
                  {
                    tmpmask.add(<int>[segment[0],segment[1]]);
                  }
                  else
                  {
                    throw FormatException('Неверный формат маски: "${affectsObject[MASK]}".');
                  }
                }
                tmpSegments=<Segment>[];
                for (List<int> seg in tmpmask)
                {
                  tmpSegments.add(Segment(start:seg[0], end:seg[1]));
                }
                predicateAffectsMasks.add(Mask(segments: tmpSegments));
              }
              else
              {
                predicateAffectsMasks.add(Mask());
              }
            }
          }
        }
        else
        {
          predicateAffectsAliases=null;
          predicateAffectsMasks=null;
        }
        if 
        (
          predicateAffectsAliases==null || 
          predicateAffectsIdentifiers==null ||
          predicateAffectsMasks==null
        )
        {
          throw FormatException('Ничего не было определено определением с фразой: "$predicatePhrase"');
        }
        predicateDependsOn=json[i][DEPENDS_ON];
        predicateDependsOnMasks=null;
        predicateDependsOnAliases=null;
        if (predicateDependsOn!=null)
        {
          predicateDependsOnAliases=<String>[];
          predicateDependsOnMasks=<Mask>[];
          predicateDependsOnIdentifiers = <String>[]; 
          for (var dependsOnObject in predicateDependsOn)
          {
            if (dependsOnObject!=null && dependsOnObject[TERM]!=null)
            {
              if (dependsOnObject[TERM]==null)
              {
                throw FormatException('Один из "$DEPENDS_ON" объектов не содержал ссылки по "$TERM".');
              }
              predicateDependsOnAliases.add(dependsOnObject[TERM]);
              if (dependsOnObject[IDENTIFIER]==null)
              {
                predicateDependsOnIdentifiers.add(predicateDependsOnAliases.last);
              }
              else
              {
                predicateDependsOnIdentifiers.add(dependsOnObject[IDENTIFIER]);
              }
              if (dependsOnObject[MASK]!=null)
              {
                tmpmask=<List<int>>[];
                for (var segment in dependsOnObject[MASK])
                {
                  if (segment!=null && segment.length>1)
                  {
                    tmpmask.add(<int>[segment[0],segment[1]]);
                  }
                  else
                  {
                    throw FormatException('Неверный формат маски: "${dependsOnObject[MASK]}".');
                  }
                }
                tmpSegments=<Segment>[];
                for (List<int> seg in tmpmask)
                {
                  tmpSegments.add(Segment(start:seg[0], end:seg[1]));
                }
                predicateDependsOnMasks.add(Mask(segments: tmpSegments));
              }
              else
              {
                predicateDependsOnMasks.add(Mask());
              }
            }
          }
        }
        else
        {
          predicateDependsOnAliases=null;
          predicateDependsOnMasks=null;
        }
        
        if (retval.findPredicateNodeByIdentifier(predicateIdentifier)!=null)
        {
          throw FormatException('Попытка ввести "$DEFINITION" с совпадающим "$IDENTIFIER" с имеющимся в базе.');
        }
        else
        {
          predicateAffectsVariableNodes = <VariableNode>[];
          predicateAffectsVariables = <Variable>[];
          for (int j=0;j<predicateAffectsIdentifiers.length;j++)
          {
            VariableNode? tmpvarnode = retval.findVariableNodeByIdentifier(predicateAffectsIdentifiers[j]);
            if (tmpvarnode==null)
            {
              throw FormatException('Определение было задано до того, как был задан используемый в нём термин ("$predicatePhrase").');
            }
            else
            {
              predicateAffectsVariableNodes.add(tmpvarnode);
              predicateAffectsVariables.add(tmpvarnode.variable);
            }
          }
          if 
          (
            predicateDependsOnIdentifiers!=null &&
            predicateDependsOnMasks!=null && 
            predicateDependsOnAliases!=null 
          )
          {
            predicateDependsOnVariables=<Variable>[];
            predicateDependsOnVariableNodes=<VariableNode>[];
            for (int j=0;j<predicateDependsOnIdentifiers.length;j++)
            { 
              VariableNode? tmpvarnode = retval.findVariableNodeByIdentifier(predicateDependsOnIdentifiers[j]);
              if (tmpvarnode==null)
              {
                throw FormatException('Определение было задано до того, как был задан используемый в нём термин ("$predicatePhrase").');
              }
              else
              {
                predicateDependsOnVariableNodes.add(tmpvarnode);
                predicateDependsOnVariables.add(tmpvarnode.variable);
              }
            }
          }
          else
          {
            predicateDependsOnVariableNodes=null;
            predicateDependsOnVariables=null;
          }
          DefinitionNode addDefNode = DefinitionNode
          (
            predicatePhrase,
            predicateIdentifier,
            predicateAffectsVariables,
            predicateAffectsMasks,
            fromVariables: predicateDependsOnVariables,
            fromRepresentationMasks: predicateDependsOnMasks,
            appearesAtTopic: predicateStart,
            obsoleteAtTopic: predicateEnd
          );
          for (VariableNode affectsNode in predicateAffectsVariableNodes)
          {
            addDefNode.edge=Edge(affectsNode,Direction.outwards);
          }
          if (predicateDependsOnVariableNodes!=null)
          {
            for (VariableNode dependsOnNode in predicateDependsOnVariableNodes)
            {
              addDefNode.edge=Edge(dependsOnNode,Direction.inwards);
            } 
          }
          retval.addPredicate(addDefNode);
        }
      }
      else
      {
        throw FormatException('При считывании знаний был найден объект, форматированный неверно.');
      }
    }
    return retval;
  }

  @override
  String toString()
  {
    String retval="Graph \"$name\"\n";
    retval+="Nodes summary:\n";
    retval+="predicates (${_predicateNodes.length} in total):\n";
    retval+=predicatesTypesSummary;
    retval+="variables (${_variableNodes.length} in total):\n";
    retval+=variablesTypesSummary;
    retval+="___________\n";
    retval+="variables:\n\n";
    for (VariableNode variableNode in _variableNodes)
    {
      retval+="${variableNode.toString()}\n";
    }
    retval+="___________\n";
    retval+="predicates:\n\n";
    for (PredicateNode predicateNode in _predicateNodes)
    {
      retval+="${predicateNode.toString()}\n";
    }
    retval+="______________\n";
    retval+="Nodes summary:\n";
    retval+="predicates (${_predicateNodes.length} in total):\n";
    retval+=predicatesTypesSummary;
    retval+="variables (${_variableNodes.length} in total):\n";
    retval+=variablesTypesSummary;
    return retval;
  }

  String get variablesTypesSummary
  {
    Map<Type,int> variableTypes=<Type,int>{};
    for (VariableNode variableNode in _variableNodes)
    {
      if (!variableTypes.containsKey(variableNode.runtimeType))
      {
        variableTypes[variableNode.runtimeType]=1;
      }
      else
      {
        variableTypes[variableNode.runtimeType]
          = variableTypes[variableNode.runtimeType]!+1;
      }
    }
    if (variableTypes.isEmpty){return "no types found\n";}
    String retval ="";
    for (Type type in variableTypes.keys)
    {
      retval+="  $type - ${variableTypes[type]} entries\n";
    }
    return retval;
  }

  String get predicatesTypesSummary
  {
    Map<Type,int> predicateTypes=<Type,int>{};
    for (PredicateNode predicateNode in _predicateNodes)
    {
      if (!predicateTypes.containsKey(predicateNode.runtimeType))
      {
        predicateTypes[predicateNode.runtimeType]=1;
      }
      else
      {
        predicateTypes[predicateNode.runtimeType]
          = predicateTypes[predicateNode.runtimeType]!+1;
      }
    }
    if (predicateTypes.isEmpty){return "no types found\n";}
    String retval ="";
    for (Type type in predicateTypes.keys)
    {
      retval+="  $type - ${predicateTypes[type]} entries\n";
    }
    return retval;
  }
 
  get dotDigraph 
  {
    String graphString = "digraph ${name ?? "noname"}{\n";
    int predchislo=0;
    for (VariableNode variable in _variableNodes)
    {
      graphString+="var_${variable.variable.toString().replaceAll(" ","_")} [shape=plaintext, label=\"${variable.variable.mainAlias}\"];\n";
    }
    for (PredicateNode pred in _predicateNodes)
    {
      predchislo+=1;
      graphString+="pred$predchislo [shape=box, label=\"${pred.predicate.toString().substring(12,22)}\"];\n";
      if (pred.edges!=null)
      {
        for (Edge edge in pred.edges!)
        {
          if (edge.direction == Direction.inwards)
          {
            graphString+="var_${(edge.node as VariableNode).variable.toString().replaceAll(" ","_")} -> pred$predchislo;\n";
          }
          else if (edge.direction == Direction.outwards)
          {
            graphString+="pred$predchislo -> var_${(edge.node as VariableNode).variable.toString().replaceAll(" ","_")};\n";
          }
        }
      }
    }
    graphString+="}";
    return graphString;
  }

  List<VariableNode> get variableNodes => <VariableNode>[]+_variableNodes;
  List<PredicateNode> get predicateNodes => <PredicateNode>[]+_predicateNodes;
}