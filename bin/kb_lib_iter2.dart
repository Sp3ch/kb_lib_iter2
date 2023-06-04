import 'dart:convert';
import "dart:io";


import 'package:kb_lib_iter2/kb_lib_iter2.dart';
// C:\Users\jesui\OneDrive\Desktop\kb_lib_iter2\kb_lib_iter2

String inp()
{
  var a=stdin.readLineSync(encoding: utf8);
  return a ?? "";
}
/*
python
letters = ["а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я" ]
def encode(s):
  return " ".join([str(letters.index(i)+1) for i in s])
while(True):
  print(encode(inp()))
 */

String inpRu()
{
  String? a=stdin.readLineSync(encoding: utf8);
  String retval="";
  if (a==null || a!=null && a=="") return "";
  if (a!=null)
  {
    List<String> letters = ["а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я", " " ];
    List<String> numsStrs=a.split(' ');
    for (String num in numsStrs)
    {
      retval+=letters[int.parse(num)-1];
    }
  }
  return retval;
}
void main(List<String> arguments) async
{
  String kb_path = "C:\\Users\\jesui\\OneDrive\\Desktop\\Trying_and_testing\\Test_generator\\планиметрия kb_lib_v2.knowledge";
  File one = File(kb_path);
  one.readAsString().then
  (
    (String value)
    {
      Graph graphOne = Graph.fromSaveFile_knowledgeOnly(value) ?? Graph();

      Exam_AllTypes_SpecifiedAmounts exam 
        = Exam_AllTypes_SpecifiedAmounts
        (
          graphOne, true,
          question_WhatIsDefinedHereAll_TypeIn: 0,
          question_WhatIsDefinedHereOneRandom_TypeIn: 1,
        );
      late Task task;
      while (!exam.endOfExam)
      {
        task=exam.nextTask!;
        print('\n\n____\nЗадание ${exam.currentTaskNumber}');
        print(task.instruction);
        print(task.body);
        if (task.type=="Question_WhatIsDefinedHereAll_TypeIn")
        {
          List<String> answer = <String>[];
          for 
          (
            int i=1;
            i<=(task as Question_WhatIsDefinedHereAll_TypeIn)
              .amountOfTerms;
            i++
          )
          {
            print("  [Введите ответ: термин \"[$i]\"]");
            String s = inpRu();
            answer.add(s);
          }
          exam.answer=answer;
          print("\nОценка: ${task.confdence*1}");
        }
        else if (task.type=="Question_WhatIsDefinedHereOneRandom_TypeIn")
        {
          print("  [Введите ответ: один термин]");
          exam.answer=inpRu();
          print("\nОценка: ${task.confdence*1}");
        }
        print("Верными ответами были:");
        for (dynamic ransw in task.possibleAnswers) {print("  \"$ransw\",");}
      }
      print("\n\n___\nКОНЕЦ ПРОВЕРОЧНОЙ РАБОТЫ\n");
      print("  Ваш балл: ${exam.pointsCurrent}");
      print("  Ваш процент: ${exam.pointsCurrent/exam.pointsMaxCurrent*100}%");
      print("  Ваша оценка: ${
        exam.pointsCurrent/exam.pointsMaxCurrent<0.5 ?
        "2" :
        exam.pointsCurrent/exam.pointsMaxCurrent<0.75 ?
        "3" :
        exam.pointsCurrent/exam.pointsMaxCurrent<0.9 ?
        "4":
        "5"
      }");
      print(graphOne.dotDigraph);
      //конец экзамена
      
      // Exam_AllTypes_EndlessRandom exam 
      //   = Exam_AllTypes_EndlessRandom(graphOne, true,);
      // late Task task;
      // String endThis="";
      // while (endThis!="1")
      // {
      //   task=exam.nextTask!;
      //   print('\n\n____\nЗадание ${exam.currentTaskNumber}');
      //   print(task.instruction);
      //   print(task.body);
      //   if (task.type=="Question_WhatIsDefinedHereAll_TypeIn")
      //   {
      //     List<String> answer = <String>[];
      //     for 
      //     (
      //       int i=1;
      //       i<=(task as Question_WhatIsDefinedHereAll_TypeIn)
      //         .amountOfTerms;
      //       i++
      //     )
      //     {
      //       print("  [Введите ответ: термин \"[$i]\"]");
      //       String s = inpRu();
      //       answer.add(s);
      //     }
      //     exam.answer=answer;
      //     print("\nОценка: ${task.confdence*1}");
      //   }
      //   else if (task.type=="Question_WhatIsDefinedHereOneRandom_TypeIn")
      //   {
      //     print("  [Введите ответ: один термин]");
      //     exam.answer=inpRu();
      //     print("\nОценка: ${task.confdence*1}");
      //   }
      //   print("Верными ответами были:");
      //   for (dynamic ransw in task.possibleAnswers) {print("  \"$ransw\",");}

      //   print("\n\nЗакончить проверочную работу? [Д-1/Н-0]");
      //   endThis=inp();
      // }
      // print("\n\n___\nКОНЕЦ ПРОВЕРОЧНОЙ РАБОТЫ\n");
      // print("  Ваш балл: ${exam.pointsCurrent}");
      // print("  Ваш процент: ${exam.pointsCurrent/exam.pointsMaxCurrent*100}%");
      // print("  Ваша оценка: ${
      //   exam.pointsCurrent/exam.pointsMaxCurrent<0.5 ?
      //   "2" :
      //   exam.pointsCurrent/exam.pointsMaxCurrent<0.75 ?
      //   "3" :
      //   exam.pointsCurrent/exam.pointsMaxCurrent<0.9 ?
      //   "4":
      //   "5"
      // }");

      // print(graphOne.dotDigraph);
    }
  );
}
// ["а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я" ]
// [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]