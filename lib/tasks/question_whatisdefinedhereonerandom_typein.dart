import 'dart:async';
import '../src/new_variable_relationships.dart';
import 'task.dart';
import 'package:kb_lib_iter2/src/definition_relationships.dart';
import '../src/representations/mask.dart';
import '../src/new_graph.dart';
import '../src/edge.dart';

///A class with all the data processing neded for the question type:
///Write down the things defined by the phrase
class Question_WhatIsDefinedHereOneRandom_TypeIn
// <TBODY, TRANSW, TPANSW, TGANSW> 
extends Task<String, String, List<String>, String> 
{
  Question_WhatIsDefinedHereOneRandom_TypeIn
  (
    DefinitionNode definitionNode,
    StreamController<int> errorsfoundSink,
    {int? attempts}
  ) 
  {
    super.errorsFoundSinc=errorsfoundSink;
    type="Question_WhatIsDefinedHereOneRandom_TypeIn";
    instruction="Впишите термин (один), который определяется фразой (если во фразе пропущены слова, то они относятся именно к этому термину)";
    if (definitionNode.outEdges != null) 
    {
      if (attempts!=null) {attemptsMax=attempts;}
      else{attemptsMax=1;}
      List<String> tmpPossibleAnswers = <String>[];
      List<Edge> edges = definitionNode.outEdges!;
      edges.shuffle();
      VariableNode term = (edges[0].node as VariableNode);
      rightAnswer=term.variable.mainAlias;
      tmpPossibleAnswers.add(rightAnswer);
      if (term.variable.hasOtherAliases)
      {
        for (String alias in term.variable.otherAliases!)
        {
          tmpPossibleAnswers.add(alias);
        }
      }
      Mask tmpmask = 
        definitionNode.predicate
          .findThingInPredicateByIdentifier(term.variable.identifier)
          !.mask;
      if (!tmpmask.isEmpty)
      {
        tmpPossibleAnswers.add
        (
          tmpmask.select
            (definitionNode.predicate.phrase, breakSubstring: " ... ")!
        );
      }
      possibleAnswers=tmpPossibleAnswers;
      body=blureMultiple
      (
        definitionNode.predicate.phrase, 
        <Mask>[tmpmask]
      );
    } 
    else 
    {
      throw FormatException('Попытка создания $type, но было найдено определение, которое ничего не задаёт.');
    }
  }
  
  @override
  List<String> get possibleAnswers 
    => <String>[]+super.possibleAnswers;
  
  @override
  double checkAnswer(String answer)
  {
    super.checkAnswer(answer.trim().toLowerCase());
    double totalPoints=0;
    double usersPoints=0;
    totalPoints=1;
    if (rightAnswer==answer.trim().toLowerCase())
    {
      usersPoints+=1;
    }
    else if (possibleAnswers.contains(answer.trim().toLowerCase()))
    {
      usersPoints+=1;
    }
    else{errorsFoundSinc.add(1);}
    completionForTheGivenAnswer=usersPoints/totalPoints;
    return usersPoints/totalPoints;
  }
}

Question_WhatIsDefinedHereOneRandom_TypeIn questionDefinitionOneRandomRandom
(
  Graph graph,
  StreamController<int> errorsSK,
  {
    int? topic,
    int? attempts
  }
)
{
  List<DefinitionNode> shuffledPredicates = 
    <DefinitionNode>[] + graph.allNodesTyped<DefinitionNode>();
  shuffledPredicates.shuffle();
  DefinitionNode definitionNode = shuffledPredicates[0];
  Question_WhatIsDefinedHereOneRandom_TypeIn question = 
    Question_WhatIsDefinedHereOneRandom_TypeIn(definitionNode, errorsSK, attempts:attempts);
  return question;
}