import 'package:kb_lib_iter2/kb_lib_iter2.dart';

class Exam_AllTypes_EndlessRandom extends Exam
{
  final Map<Type,int> _typesAmounts={};

  late bool _isStraightForward;

  Exam_AllTypes_EndlessRandom
  (
    Graph graph,
    bool? isStraightForward
  )
  {
    if (isStraightForward==null){_isStraightForward=true;}
    else {_isStraightForward = isStraightForward;}
    type="Exam_AllTypes_EndlessRandom";
    super.graph=graph;
    _typesAmounts[Question_WhatIsDefinedHereAll_TypeIn]=0;
    _typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]=0;
    tasksMax=null;
    triesMax=null;
    pointsMax=null;
  }

  @override
  Task? repeat(int? index)
  {
    if (_isStraightForward) {return null;}
    return super.repeat(index);
  }

  @override
  Task? get nextTask
  {
    super.nextTask;
    List<Type> shuffledTypes = <Type>[];
    for (Type type in _typesAmounts.keys) {shuffledTypes.add(type);}
    shuffledTypes.shuffle();
    Type type = shuffledTypes[0];
    if (type==Question_WhatIsDefinedHereAll_TypeIn)
    {
      _typesAmounts[Question_WhatIsDefinedHereAll_TypeIn]
        =_typesAmounts[Question_WhatIsDefinedHereAll_TypeIn]! -1;
      Task tmptask = questionDefinitionAllRandom(graph, super.errorsSK);
      nextTaskSink.add(tmptask);
      return tmptask;
    }
    if (type==Question_WhatIsDefinedHereOneRandom_TypeIn)
    {
      _typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]
        =_typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]! -1;
        Task tmptask = questionDefinitionOneRandomRandom(graph, super.errorsSK);
        nextTaskSink.add(tmptask);
      return tmptask;
    }
    else {return null;}
  }

  @override
  bool get canRepeat => _isStraightForward;

  @override
  bool get haveAttemptsEnded => false;

  @override
  bool haveTasksEnded = false;
  
  @override
  bool get endOfExam => !canRepeat && haveTasksEnded && haveAttemptsEnded;
}