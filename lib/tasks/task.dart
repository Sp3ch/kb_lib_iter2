import 'dart:async';
import 'package:kb_lib_iter2/src/new_predicate_relationships.dart';

import '../src/new_graph.dart';

///A SUPER class with all the data processing neded for the question
abstract class Task<TBODY, TRANSW, TPANSW, TGANSW> 
{
  ///A parameter that affects the need of giving the user the task repeatedly
  double _confidence=0;

  /// An amount of attempts that the user may take repeatetly solving the same
  /// task untill the task is solved at 100%. If null, the task 
  /// will repeat untill it's solved completely.
  int? _attemptsMax=1;
  bool _createdAttemptsMax=false;

  /// The amount of attempts that user took checking the question
  int _attemptsTaken = 0;
  
  ///A type of the task (both format and content types).
  late String _type;
  bool _createdType=false;
  
  // late Graph tip;

  ///A field for storing the instructions on how to complete the task.
  late String _instruction;
  bool _createdInstruction=false;

  ///A field for storing the question content.
  late TBODY _body;
  bool _createdBody=false;

  ///A field for storing the right answers in between the [Task] generation
  ///and the call of [checkAnswer] method.
  ///The right answer is a single of possible to be fully correct variants
  ///to be displayed in case of the wrong or partialy right answer recognition
  late TRANSW _rightAnswer;
  bool _createdRightAnswer=false;

  /// A field for storing the variants for possibly right or partialy right
  ///answers in between the [Task] generation and the call of [checkAnswer]
  ///method
  late TPANSW _possibleAnswers;
  bool _createdPossibleAnswers=false;

  /// Each object in the list is added when the [checkAnswer] method is called
  List<TGANSW> _givenAnswers=<TGANSW>[];

  /// Each object in the list is added when the [checkAnswer] method is called
  List<double> _completionForTheGivenAnswers=<double>[];

  ///
  late StreamController<int> errorsFoundSinc;

  /// Should be a double within [0;1].
  /// Should take into an account the possibly right answers
  /// Defined in the abstract superclass, always returns 0, serves for adding
  /// the answers given to the internal private property.
  double checkAnswer(TGANSW givenAnswer)
  {
    _givenAnswers.add(givenAnswer);
    _attemptsTaken+=1;
    return 0;
  }

  set attemptsMax(int? value)
  {
    if (!_createdAttemptsMax) 
    {
      _createdAttemptsMax=true;
      _attemptsMax=value;
    }
  }
  
  set type(String value)
  {
    if (!_createdType) 
    {
      _createdType=true;
      _type=value;
    }
  }
  
  set instruction(String value)
  {
    if (!_createdInstruction) 
    {
      _createdInstruction=true;
      _instruction=value;
    }
  }
  
  set body(TBODY value)
  {
    if (!_createdBody) 
    {
      _createdBody=true;
      _body=value;
    }
  }
  
  set rightAnswer(TRANSW value)
  {
    if (!_createdRightAnswer) 
    {
      _createdRightAnswer=true;
      _rightAnswer=value;
    }
  }
  
  set possibleAnswers(TPANSW value)
  {
    if (!_createdPossibleAnswers) 
    {
      _createdPossibleAnswers=true;
      _possibleAnswers=value;
    }
  }

  set completionForTheGivenAnswer(double completion)
  {
    if (_confidence<completion){_confidence=completion;}
    _completionForTheGivenAnswers.add(completion);
  }

  TBODY get body => _body;
  TRANSW get rightAnswer => _rightAnswer;
  TPANSW get possibleAnswers => _possibleAnswers;
  String get instruction => _instruction;
  String get type => _type;
  double get confdence => _confidence;
  int? get attemptsMax => _attemptsMax;
  bool get maxedOut 
    => 
      _confidence>=1 
      || _attemptsTaken>=(_attemptsMax ?? _attemptsTaken+1);
  List<double> get completionForTheGivenAnswers 
    => <double>[]+_completionForTheGivenAnswers;
  List<TGANSW> get givenAnswers => <TGANSW>[]+_givenAnswers;
  TGANSW get lastGivenAnswer => _givenAnswers.last;
}

/// Extract all the nodes of a specific types from [Graph]'s predicates.
/// The type T specifies the type given.
/// Both [fromTopic] and [toTopic] consider the topics inclusively.
/// The [Node] is returned if at least one topic of it's meaningfull existance 
/// is within the set interal (i.e. if intervals collide, not only if the 
/// [Node]'s interval is included in the needed interval).
List<T> extractForTopicTyped<T extends PredicateNode>
(
  Graph graph,
  int? fromTopic,
  int? toTopic
)
{
  List<T> retval = <T>[];
  List<T> tmplist = <T>[] + graph.allNodesTyped<T>(); 
  if (fromTopic!=null && toTopic!=null && fromTopic>toTopic)
  {
    throw FormatException('Попытка запросить вопрос с пустым диапазоном тем изучения.');
  }
  if (fromTopic!=null && fromTopic<0)
  {
    throw FormatException('В поданном диапазоне тем изучения номер темы начала меньше 0.');
  }
  if (toTopic!=null && toTopic<1)
  {
    throw FormatException('В поданом диапазоне тем изучения номер темы выхода из актуальности меньше 1 (знание не может потерять смысл в ту же тему, в которую введено, а введено может быть только начиная с темы 0).');
  }
  if (!graph.intervalApplicable((fromTopic ?? 0), toTopic))
  {
    throw FormatException('Неправильный (пустой) интервал тем.');
  }
  if (fromTopic!=null)
  {
    for (T predicateNode in tmplist)
    {
      if 
        (
          (
            predicateNode.obsoleteAtTopic==null || 
            predicateNode.obsoleteAtTopic!>fromTopic
          )
          &&
          (
            toTopic==null ||
            predicateNode.appearesAtTopic <= toTopic
          )
        )
        {retval.add(predicateNode);}
    }
  }
  else if (toTopic!=null)
  {
    for (T predicateNode in tmplist)
    {
      if 
      (
        (
          predicateNode.obsoleteAtTopic==null || 
          predicateNode.obsoleteAtTopic! > (fromTopic ?? 0)
        )
        &&
        predicateNode.appearesAtTopic <= toTopic
      )
      {retval.add(predicateNode);}
    }
  }
  else
  {
    retval = tmplist;
  }
  return retval;
} 