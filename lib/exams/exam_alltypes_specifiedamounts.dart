import 'package:kb_lib_iter2/kb_lib_iter2.dart';

class Exam_AllTypes_SpecifiedAmounts extends Exam
{
  Map<Type,int> _typesAmounts={};


  Exam_AllTypes_SpecifiedAmounts
  (
    Graph graph,
    bool isStraightForward,
    {
    int? attempts,
    int? question_WhatIsDefinedHereAll_TypeIn,
    int? question_WhatIsDefinedHereOneRandom_TypeIn,
    }
  )
  {
    type="Exam_AllTypes_SpecifiedAmounts";
    super.graph=graph;
    if 
    (
      (
        question_WhatIsDefinedHereAll_TypeIn==null ||
        question_WhatIsDefinedHereAll_TypeIn!=null 
        && question_WhatIsDefinedHereAll_TypeIn<=0
      )
      &&
      (
        question_WhatIsDefinedHereOneRandom_TypeIn==null ||
        question_WhatIsDefinedHereOneRandom_TypeIn!=null 
        && question_WhatIsDefinedHereOneRandom_TypeIn<=0
      )
    )
    {
      throw FormatException('Исчерпано количество вопросов в проверочной работе типа работы на все типы заданий с заданным количеством заданий.');
    }
    if (question_WhatIsDefinedHereAll_TypeIn!=null && 
      question_WhatIsDefinedHereAll_TypeIn>0)
    {
      _typesAmounts[Question_WhatIsDefinedHereAll_TypeIn]
        =question_WhatIsDefinedHereAll_TypeIn;
    }
    else
    {
      _typesAmounts[Question_WhatIsDefinedHereAll_TypeIn] = 0;
    }
    if (question_WhatIsDefinedHereOneRandom_TypeIn!=null && 
      question_WhatIsDefinedHereOneRandom_TypeIn>0)
    {
      _typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]
        =question_WhatIsDefinedHereOneRandom_TypeIn;
    }
    else
    {
      _typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn] = 0;
    }
    int tmptasks=0;
    for (Type key in _typesAmounts.keys)
    {
      tmptasks+=_typesAmounts[key] ?? 0;
    }
    tasksMax=tmptasks;
    if (isStraightForward) {triesMax=tasksMax;}
    else {if (attempts!=null){triesMax=attempts;}}
    pointsMax=null;
  }

  @override
  Task? get nextTask
  {
    if (!endOfExam)
    {
      super.nextTask;
      List<Type> shuffledTypes = <Type>[];
      for (Type type in _typesAmounts.keys) {shuffledTypes.add(type);}
      shuffledTypes.shuffle();
      for (Type type in shuffledTypes)
      {
        if (_typesAmounts[type]!>0)
        {
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
        }
      }
    }
    return null;
  }
}