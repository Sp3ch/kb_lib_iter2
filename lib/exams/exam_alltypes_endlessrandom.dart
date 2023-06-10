import 'package:kb_lib_iter2/kb_lib_iter2.dart';

class Exam_AllTypes_EndlessRandom extends Exam
{
  final Map<Type,int> _typesAmounts={};
  final int? _fromTopic;
  final int? _toTopic;

  late bool _isStraightForward;

  Exam_AllTypes_EndlessRandom
  (
    Graph graph,
    bool? isStraightForward,
    {
      int? fromTopic,
      int? toTopic
    }
  ) : _toTopic = toTopic, _fromTopic = fromTopic
  {
    if (_fromTopic!=null && _toTopic!=null && _fromTopic!>_toTopic!)
    {
      throw FormatException('Попытка создать проверочную работу с пустым диапазоном тем изучения.');
    }
    if (_fromTopic!=null && _fromTopic!<0)
    {
      throw FormatException('В поданном диапазоне тем изучения номер темы начала меньше 0 (при создании проверочной работы).');
    }
    if (_toTopic!=null && _toTopic!<1)
    {
      throw FormatException('В поданом диапазоне тем изучения номер темы выхода из актуальности меньше 1 (знание не может потерять смысл в ту же тему, в которую введено, а введено может быть только начиная с темы 0) (при создании проверочной работы).');
    }
    if (!graph.intervalApplicable(_fromTopic!, toTopic))
    {
      throw FormatException('Неправильный (пустой) интервал тем.');
    }
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
      Task tmptask = questionDefinitionAllRandom
      (
        graph, 
        super.errorsSK,
        fromTopic: _fromTopic,
        toTopic: _toTopic
      );
      nextTaskSink.add(tmptask);
      return tmptask;
    }
    if (type==Question_WhatIsDefinedHereOneRandom_TypeIn)
    {
      _typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]
        =_typesAmounts[Question_WhatIsDefinedHereOneRandom_TypeIn]! -1;
        Task tmptask = questionDefinitionOneRandomRandom
        (
          graph, 
          super.errorsSK,
          fromTopic: _fromTopic,
          toTopic: _toTopic
        );
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