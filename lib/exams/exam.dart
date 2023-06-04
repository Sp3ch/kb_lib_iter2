import 'dart:async';
import '../kb_lib_iter2.dart';

class Exam
{
  /// The type of exam
  String _type = '';
  bool _createdType=false;
  
  ///
  late Graph _graph;
  bool _createdGraph=false;
  
  ///The maximum amount of tasks that the exam can ever give
  int? _tasksMax=1;
  bool _createdTasksMax=false;

  /// The amount of tasks generated
  int _tasksTaken=0;

  /// The max amount of points that the user could have got at this amount 
  /// of tasks answered
  double _pointsMaxCurrent=0;

  /// The current amount of points that the user has
  double _pointsCurrent=0;

  /// The amount of points that the exam can ever have
  double? _pointsMax=null;
  bool _createdPointsMax = false;

  ///  Current task displayed to answer
  late Task _currentTask;

  /// The amount of tries given, incl. the current one
  int _triesTaken=0;

  /// The amount of tries the exam can ever give
  int? _triesMax;
  bool _createdTriesMax=false;

  /// All the tasks generated
  List<Task> _tasksInStorage=<Task>[];
  
  /// The order number of the current task, not the attempt (try), i.e it's 
  /// index in the _tasksStorage +1
  int _currentTaskNuber=1;

  /// An amount of errors made in all the attemps (tries) in all the tasks
  int _amountOfErrors=0;
  final StreamController<int> _errorsSK = StreamController<int>();
  bool _listenedErrorsSK=false;

  /// A stream to put the egnerated tasks to, without the need to change 
  /// the implemented class'es ligic to store the generated tasks.
  StreamController<Task> _currentTaskCreatedSK = StreamController<Task>();
  bool _createdTaskSK = false;

  /// Adds a specified amount of errors or 1 error if the amount is null or <1
  /// (the correct value to pass into the function is errors>0)
  void _addErrors({int? errors})
  {
    if (errors==null || errors<1) {_amountOfErrors+=1;}
    else {_amountOfErrors+=errors;}
  }

  ///
  Task? repeat(int? index)
  {
    int i=0;
    if (index==null)
    {
      for (Task task in _tasksInStorage)
      {
        i++;
        if (!task.maxedOut)
        {
          _pointsCurrent -= task.confdence;
          _triesTaken+=1;
          _currentTaskNuber=i;
          _currentTask=task;
          return task;
        }
      }
    }
    else
    {
      if (index<_tasksInStorage.length)
      {
        i++;
        if (!_tasksInStorage[index].maxedOut)
        {
          _pointsCurrent -= _tasksInStorage[index].confdence;
          _triesTaken+=1;
          _currentTaskNuber=i;
          _currentTask=_tasksInStorage[index];
          return _tasksInStorage[index];
        }
        else 
        {
          throw FormatException('Задание решено полностью верно, или на его решение закончились попытки.');
        }
      }
      else
      {
        throw FormatException('Попытка повтора задания с порядковым номером, который ещё не был использован.');
      }
    }
    return null;
  }

  ///
  set type(String type)
  {
    if (!_createdType)
    {
      _createdType=true;
      _type=type;
    }
  }
  ///
  set graph (Graph graph)
  {
    if (!_createdGraph)
    {
      _createdGraph=true;
      _graph=graph;
    }
  }

  ///
  set tasksMax(int? value)
  {
    if (_createdTriesMax)
    {
      if 
      (
        value==null && _triesMax!=null || 
        value!=null && _triesMax==null || 
        value!=null && _triesMax!=null &&  _triesMax!<value
      )
      {
        throw FormatException('Количество сформированных заданий не может быть больше количества попыток.');
      }
    }
    if (!_createdTasksMax)
    {
      _createdTasksMax=true;
      _tasksMax=value;
    }
  }

  ///
  set pointsMax(double? value)
  {
    if (!_createdPointsMax)
    {
      _createdPointsMax=true;
      _pointsMax=value;
    }
  }
  
  ///
  set answer(dynamic answer)
  {
    double verdict = _currentTask.checkAnswer(answer);
    _pointsCurrent+=verdict;
  }

  ///
  set triesMax(int? tries) 
  {
    if (_createdTasksMax)
    {
      if 
      (
        _tasksMax==null && tries!=null || 
        _tasksMax!=null && tries==null || 
        _tasksMax!=null && tries!=null &&  tries<_tasksMax!
      )
      {
        throw FormatException('Количество сформированных заданий не может быть больше количества попыток.');
      }
    }
    if (!_createdTriesMax) 
    {
      _createdTriesMax=true;
      _triesMax=tries;
    }
  }

  ///
  StreamController<int> get errorsSK 
  {
    if (!_listenedErrorsSK)
    {
      _listenedErrorsSK=true;
      _errorsSK.stream.listen((event) {_addErrors(errors:event);});
    }
    return _errorsSK;
  }

  ///
  Task? get nextTask
  {
    _tasksTaken+=1;
    _triesTaken+=1;
    _currentTaskNuber=_tasksTaken;
    return null;
  }

  StreamController<Task> get nextTaskSink
  {
    if (!_createdTaskSK)
    {
      _createdTaskSK=true;
      _currentTaskCreatedSK.stream.listen
      (
        (event) 
        {
          _currentTask=event;
          if (_tasksInStorage.contains(_currentTask));
          _tasksInStorage.add(_currentTask);
          _pointsMaxCurrent+=1;
        }
      );
    }
    return _currentTaskCreatedSK;
  }

  Graph get graph => _graph;
  int? get tasksMax => _tasksMax;
  int get tasksTaken => _tasksTaken;
  int get triesTaken => _triesTaken;
  int? get triesMax => _triesMax;
  int get currentTaskNumber => _currentTaskNuber;
  double get pointsMaxCurrent => _pointsMaxCurrent;
  double get pointsCurrent => _pointsCurrent;
  double? get pointsMax => _pointsMax;
  double get percentageFinal 
  => pointsMax!=null ? 
    _pointsCurrent/_pointsMax! : 
    _tasksMax==null ? 
    _pointsCurrent/_pointsMaxCurrent :
    _pointsCurrent / 
    (
      _pointsMaxCurrent/_tasksTaken*(_tasksMax!-_tasksTaken)
      +_pointsMaxCurrent
    );
  int get perfectTasks
  {
    int retval = 0;
    for (Task task in _tasksInStorage)
    {
      if(task.confdence>=1){retval++;}
    }
    return retval;
  }
  int get errors => _amountOfErrors;
  Task get currentTask => _currentTask;
  ///
  bool get canRepeat 
  {
    if (_tasksMax==_triesMax){return false;}
    for (Task task in _tasksInStorage) {if (!task.maxedOut){return true;}}
    return false;
  }
  ///
  bool get haveTasksEnded => _tasksTaken>=(_tasksMax ?? _tasksTaken+1);
  ///
  bool get haveAttemptsEnded => _triesTaken >= (_triesMax ?? _triesTaken+1);
  ///
  bool get endOfExam  => !canRepeat && haveTasksEnded && haveAttemptsEnded;
}