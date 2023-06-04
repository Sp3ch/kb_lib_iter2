import "./segment.dart";

///The class to represent a position of a substring in the string.
class Mask 
{
  /// The [Segment]'s inside the mask.
  late List<Segment> _segments;

  ///A constructor of [Mask] class
  Mask
  ({
    ///The [Segment]'s inside the mask.
    ///The [Segment]'s may collide, in which case they will be replaced with 
    ///another merging [Segment].
    ///May have the [Segment]'s placed in the random order.
    List<Segment>? segments
  }) 
  {
    if (segments==null || segments.isEmpty)
    {
      _segments=<Segment>[Segment(start:0,end:0)];  
    }
    else
    {
      _segments = <Segment>[] + segments;
    }
    _segments=Segment.normalize(_segments);
    if (_segments[0].isNullSegment && _segments.length>1)
    {
      _segments.removeAt(0);
    }
  }

  /// A function to normalize self. Returns a link to self while also 
  /// normalizing itself.
  Mask _normalize()
  {
    _segments = Segment.normalize(_segments);
    return this;
  }

  /// Replaces the masked symbols inside [phrase] string with [blureFrame]
  /// substring.
  String blure
  (
    String phrase,
    {
      String? blureFrame
    }
  )
  {
    if (_segments.isEmpty){return phrase;}
    int maxInd=0;
    for (Segment s in _segments)
    {
      if (s.end>maxInd)
      {
        maxInd=s.end;
      }
    }
    if (maxInd>phrase.length)
    {
      throw FormatException('Попытка вычёркивания из фразы, более короткой, чем маска вычёркивания.');
    }
    int startIndex=0;
    if (_segments[0].isNullSegment) {startIndex=1;} else {startIndex=0;}
    String retval=phrase.substring(startIndex,_segments[startIndex].start);
    retval+=(blureFrame==null) ?  "__ " : blureFrame;
    for (int i=startIndex+1;i<_segments.length;i++)
    {
      retval+=phrase.substring(_segments[i-1].end,_segments[i].start);
      retval+=(blureFrame==null) ?  "__ " : blureFrame;
    }
    retval+=phrase.substring(_segments[_segments.length-1].end);
    return retval;
  }

  String? select(String phrase, {String? breakSubstring})
  {
    String defaultBreak = "... ";
    if (isEmpty){return null;}
    if (_segments.isEmpty){return null;}
    int maxInd=0;
    for (Segment s in _segments) {if (s.end>maxInd) {maxInd=s.end;}}
    if (maxInd>phrase.length)
    {
      throw FormatException('Попытка выбора по маске из фразы, короче, чем маска выбора.');
    }
    int i = _segments[0].isNullSegment ? 1 : 0;
    String retval = phrase.substring(_segments[i].start, segments[i].end);
    for (i=1;i<_segments.length;++i)
    {
      retval+=breakSubstring ?? defaultBreak;
      retval+=phrase.substring(_segments[i].start,_segments[i].end);
    }
    return retval;
  }

  /// The function that sorts the masks by the [Segment.start] of their 
  /// first non [0;0] [Segment] (all the other aspects are ignored)
  static List<Mask> sorted
  (
    List<Mask> masks,
    {
      ///Whether the List should be sorted to have a descending order.
      ///The default is False (by default the list is sorted by the ascending 
      ///order).
      bool? descending
    }
  )
  {
    List<Mask> retval = <Mask>[]+masks;
    if (descending != null && descending == true) 
    {
      retval.sort
      (
        (a, b) => 
        -(
          (
            a._segments[0].isNullSegment && a._segments.length>1 ?
              a._segments[1] :
              a._segments[0]
          ).start
          .compareTo
          (
            (
              b._segments[0].isNullSegment && b._segments.length>1 ?
              b._segments[1] :
              b._segments[0]
            )
            .start
          )
        )
      );
    } 
    else 
    {
      retval.sort
      (
        (a, b) => 
        (
          (
            a._segments[0].isNullSegment && a._segments.length>1 ?
              a._segments[1] :
              a._segments[0]
          ).start
          .compareTo
          (
            (
              b._segments[0].isNullSegment && b._segments.length>1 ?
              b._segments[1] :
              b._segments[0]
            )
            .start
          )
        )
      );
    }
    return retval;
  }

  /// The function to check whether the [Mask]s collide at east once in the 
  /// given list.
  static bool collide(List<Mask> masks)
  {
    for (int i=0;i<masks.length-1;i++)
    {
      if (masks[i].collidesWithAnyIn(masks.sublist(i+1)))
      {
        return true;
      }
    }
    return false;
  }

  /// The function to check whether the [Mask] collides with any of the given
  /// [Mask]'s. The collisions between the given [Mask]s aren't checked.
  bool collidesWithAnyIn(List<Mask> masks)
  {
    for (Mask mask in masks)
    {
      if (collidesWith(mask))
      {
        return true;
      }
    }
    return false;
  }

  /// The function that checks whether the given [Mask] collides with the other 
  /// [Mask]. Collisions follow the rules of collisions for the set of segments.
  /// (
  /// The rules of collision checking are:
  ///- [Segment]'s may share a single value, but must not share an interval of
  ///non zero length.
  ///- [Segment]s must not be of the length 0, except the [0;0] case (which is
  ///considered to be not colliding with any segments, incl. the other [0;0]).
  /// )
  bool collidesWith(Mask otherMask)
  {
    return Segment.collideInList(_segments+otherMask._segments);
  }

  @override
  String toString() => "Mask: $_segments";

  /// The [Segment]'s inside the mask.
  List<Segment> get segments => <Segment>[] + _segments;

  /// The amount of distinct intervals (including [0;0])
  int get intervals => _segments.length;

  /// The sum of [Segment]s' lengths, i.e. the amount of characters marked with
  /// the [Mask].
  int get size
  {
    int retval=0;
    for (Segment segment in _segments)
    {
      retval+=segment.length;
    }
    return retval;
  }

  /// Returns the maximum position of any [Segment]'s end.
  /// Supposed to be used to check whether the [Mask] is larger than the string 
  /// that it is applied to. In this case, the allowed maxium is when the 
  /// [Mask]'s [max] is equal to the string's length.
  int get max
  {
    int retval=0;
    for (Segment segment in _segments)
    {
      if (segment.end>retval)
      {
        retval=segment.end;
      }
    }
    return retval;
  }

  /// Whether the mask is [0;0]
  bool get isEmpty 
    => _segments.isEmpty || _segments.length==1 && _segments[0].isNullSegment;

  ///Get the copy of the [Mask] (to assign "by value")
  Mask get copy
  {
    List<Segment> tmpSegments = <Segment>[];
    for (Segment segment in _segments)
    {
      tmpSegments.add(Segment(start: segment.start, end: segment.end));
    }
    return Mask(segments:tmpSegments);
  }
}

/// The static function to blure the string by multiple masks that do not 
/// collide.
/// If masks collide, throws an exception.
String blureMultiple
(
  String phrase,
  List<Mask> masks, 
  {
    String? blureFrame,
    List<String?>? blureFrames
  }
)
{
  if (masks.isEmpty) {return phrase;}
  String defaultFrame="___";
  if (Mask.collide(masks))
  {
    throw FormatException('Попытка вычёркивания из фразы по набору масок, в котором присутствует колизия, невозможна.');
  }
  if (blureFrames!=null && blureFrames.length!=masks.length)
  {
    throw FormatException('Количество шаблонов для заполнения вычёркиваний не совпало с количеством мест вычёркивания.');
  }
  List<String> nullMasksFrames = <String>[];
  Map<Segment,String> frames = {};
  for (int i=0;i<masks.length;i++)
  {
    if (masks[i].isEmpty)
    {
      nullMasksFrames.add(blureFrames?[i] ?? blureFrame ?? defaultFrame);
    }
    else
    {
      for (Segment segment in masks[i]._segments)
      {
        if (!segment.isNullSegment)
        {
          frames[segment]=blureFrames?[i] ?? blureFrame ?? defaultFrame;
        }
      }
    }
  }
  String retval ="";
  if (nullMasksFrames.isNotEmpty)
  {
    retval+="${nullMasksFrames.join(", ")} — ";
  }
  if (frames.isNotEmpty)
  {
    List<Segment> sortedSegments = frames.keys.toList();
    sortedSegments.sort((a, b) => a.start.compareTo(b.start));
    retval+= phrase.substring(0,sortedSegments[0].start);
    for (int i=0;i<sortedSegments.length-1;i++)
    {
      retval+=frames[sortedSegments[i]]!;
      retval+=phrase.substring(sortedSegments[i].end,sortedSegments[i+1].start);
    }
    retval+=frames[sortedSegments.last]!;
    retval+=phrase.substring(sortedSegments.last.end);
  }
  else
  {retval+=phrase;}
  return retval;
}