import 'dart:async';

import 'package:kb_lib_iter2/src/representations/new_thinginpredicate.dart';

import '../src/new_variable_relationships.dart';
import '../src/new_variable_content.dart';
import 'task.dart';
import 'package:kb_lib_iter2/src/definition_relationships.dart';
import '../src/representations/mask.dart';
import '../src/new_graph.dart';
import '../src/edge.dart';

///A class with all the data processing neded for the question type:
///Write down the things defined by the phrase
class Question_WhatIsDefinedHereAll_TypeIn
// <TBODY, TRANSW, TPANSW, TGANSW> 
extends Task<String, List<String>, List<List<String>>, List<String>> 
{
  int _amountOfTerms=0;
  Question_WhatIsDefinedHereAll_TypeIn
  (
    DefinitionNode definitionNode,
    StreamController<int> errorsFoundSinc,
    {
      int? attempts,
      // Graph? visible,
    }
  ) 
  {
    super.errorsFoundSinc=errorsFoundSinc;
    type="Question_WhatIsDefinedHereAll_TypeIn";
    instruction="Впишите все термины, которые определяются фразой";
    if (definitionNode.outEdges != null) 
    {
      if (attempts!=null) {attemptsMax=attempts;}
      else {attemptsMax=1;}
      List<String> tmpRightAnswer = <String>[];
      List<List<String>> tmpPossibleAnswers = <List<String>>[];
      List<Mask> blureMasks = <Mask>[];
      List<String> blureFrames = <String>[];
      int i=0;

      List<ThingInPredicate> sortedTIPs = <ThingInPredicate>[];
      List<Variable> toVariables = <Variable>[];
      
      for (Edge edge in definitionNode.outEdges!)
      {
        toVariables.add((edge.node as VariableNode).variable);
      }
      for (ThingInPredicate tip in definitionNode.predicate.things!)
      {
        if (toVariables.contains(tip.thing)) {sortedTIPs.add(tip);}
      }
      sortedTIPs.sort
      (
        (a, b) 
        => a.mask.segments[0].start
        .compareTo(b.mask.segments[0].start)
      );
      for (ThingInPredicate tip in sortedTIPs)
      {
        _amountOfTerms+=1;
        tmpRightAnswer.add(tip.thing!.mainAlias);
        tmpPossibleAnswers.add(<String>[]);
        tmpPossibleAnswers.last.add(tip.thing!.mainAlias);
        if (tip.thing!.hasOtherAliases)
        {
          for (String pansw in tip.thing!.otherAliases!) 
          {
            tmpPossibleAnswers.last.add(pansw);
          }
        }
        if (!tip.mask.isEmpty)
        {
          tmpPossibleAnswers.last.add
          (
            tip.mask.select(definitionNode.predicate.phrase, breakSubstring: " ")!
          );
        }
        i++;
        blureFrames.add("($i)");
        blureMasks.add(tip.mask);
      }
      rightAnswer=tmpRightAnswer;
      possibleAnswers=tmpPossibleAnswers;
      body=blureMultiple
      (
        definitionNode.predicate.phrase,
        blureMasks,
        blureFrames: blureFrames 
      );

    } 
    else 
    {
      throw FormatException('Попытка создания $type, но нашлось определение, которое ничего не задаёт.');
    }
  }
  
  @override
  List<List<String>> get possibleAnswers 
    => <List<String>>[]+super.possibleAnswers;
  
  @override
  List<String> get rightAnswer 
    => <String>[]+super.rightAnswer;

  @override
  double checkAnswer(List<String> givenAnswer)
  {
    if (givenAnswer.length!=rightAnswer.length)
    {
      throw FormatException('Данный ответ имел неверное количество частей ответа.');
    }
    List<String> lowerAnswer = <String>[];
    for (String answer in givenAnswer)
    {
      lowerAnswer.add(answer.trim().toLowerCase());
    }
    for (String s in givenAnswer) {s=s.trim().toLowerCase();}
    super.checkAnswer(lowerAnswer);
    double totalPoints=0;
    double usersPoints=0;
    for (int i =0;i<rightAnswer.length;i++)
    {
      totalPoints+=1;
      if (rightAnswer[i]==lowerAnswer[i])
      {
        usersPoints+=1;
      }
      else if (possibleAnswers[i].contains(lowerAnswer[i]))
      {
        usersPoints+=1;
      }
      else
      {
        errorsFoundSinc.add(1);
      }
    }
    completionForTheGivenAnswer=usersPoints/totalPoints;
    return usersPoints/totalPoints;
  }
  int get amountOfTerms => _amountOfTerms;
}

Question_WhatIsDefinedHereAll_TypeIn questionDefinitionAllRandom
(
  Graph graph,
  StreamController<int> errorsFoundSink,
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
  Question_WhatIsDefinedHereAll_TypeIn question = 
    Question_WhatIsDefinedHereAll_TypeIn
    (
      definitionNode, 
      errorsFoundSink, 
      attempts:attempts
    );
  return question;
}