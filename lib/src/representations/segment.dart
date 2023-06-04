///The class to represent a position of a single segment in the string.
///Only cares about storing and evaluating the single segment, not knowing
///about the [Mask] it's in.
///Considered to be immutable and to be replaced with a correct list of 
///[Segment]'s in case of Mask correction.
class Segment 
{
  ///The start position of the carriage for the symbols to be included from.
  late int _start;

  ///The end position of carriage for the symbols ot be included up to
  late int _end;

  ///The constructor takes in whether the list of the first two positions
  ///or the separate start and end values.
  ///Separate int values are the top priority.
  ///If the end is less or equal to start, except [0;0] interval,
  ///the segment is to be made [0;0]. If then the separate int values override
  ///the issue normaly, the segment is made according to those values.
  Segment
  (
    {
      ///The start position of the carriage for the symbols to be included from.
      ///Must be int >=0, otherwise will be set as 0 or from segment.
      int? start,

      ///The end position of the carriage for the symbols ot be included up to
      ///Must be int >=0 and more or greater than start (whether from [start] 
      ///or [segment]), except the [0;0] interval, or else the [0;0] segment 
      ///will be made
      int? end,

      ///A list of start and end values (in the "start -> end" order).
      ///Separate [start] and [end] inputs have a priority over the list of 
      ///values.
      ///All the values after the first two are ignored.
      ///If non [0;0] interval has a start not less than end,
      ///the values will be set to [0;0] or to the separate values given.
      List<int?>? segment
    }
  ) 
  {
    _start = 0;
    _end = 0;
    if (segment != null) 
    {
      if (segment[0] != null && segment[0]! > -1) 
      {
        _start = segment[0]!;
      }
      if 
      (
        segment[1] != null &&
        (segment[1]! > _start || (segment[1] == _start && _start == 0))
      ) 
      {_end = segment[1]!;} 
      else 
      {
        _start = 0;
        _end = 0;
      }
    }
    if (start != null) {_start = start;}
    if 
    (
      end != null && 
      (end > _start || (end == 0 && start == 0))
    ) 
    { _end = end;} 
    else 
    {
      _start = 0;
      _end = 0;
    }
    if (segment == null && start == null && end == null) 
    {
      start = 0;
      end = 0;
    }
  }

  ///Checks if the [Segment] given collides with the call subject.
  ///The rules of collision checking are:
  ///- [Segment]'s may share a single value, but must not share an interval of
  ///non zero length.
  ///- [Segment]s must not be of the length 0, except the [0;0] case (which is
  ///considered to be not colliding with any segments, incl. the other [0;0]).
  bool collidesWith(Segment segment) 
  {
    if (isNullSegment || segment.isNullSegment){return false;}
    if (_start < segment.start) 
    {
      if (_end > segment.start) {return true;}
    }
    if (_end < segment.end) 
    {
      if (_end > segment.start) {return true;}
    }
    return false;
  }

  ///Checks if the [Segment]'s given collide.
  ///The rules of collision checking are:
  ///- [Segment]'s may share a single value, but must not share an interval of
  ///non zero length.
  ///- [Segment]s must not be of the length 0, except the [0;0] case (which is
  ///considered to be always true).
  static bool collideInPair(Segment a, Segment b) => a.collidesWith(b);

  ///Checks if the [Segment]'s given collide.
  ///The rules of collision checking are:
  ///- [Segment]'s may share a single value, but must not share an interval of
  ///non zero length.
  ///- [Segment]s must not be of the length 0, except the [0;0] case (which is
  ///considered to be not colliding with any segments, incl. the other [0;0]).
  static bool collideInList(List<Segment> segments)
  {
    List<Segment> tmpSegments = sorted(segments);
    for (int i=0;i<tmpSegments.length-1;i++)
    {
      if (tmpSegments[i]._end>tmpSegments[i+1].start)
      {
        if 
        (
          !(tmpSegments[i].start==0 && tmpSegments[i].end==0) && 
          !(tmpSegments[i+1].start==0 && tmpSegments[i+1].end==0)
        )
        {
          return true;
        }
      }
    }
    return false;
  }

  ///The function to sort the [Segment]'s given in the growing order.
  ///The start values are compared. The end values are ignored.
  ///Explicitly puts the [0;0] segment at the start or end of the list 
  ///(depending on the [descending] attribute given).
  static List<Segment> sorted
  (
    ///The list of [Segment]'s to be sorted.
    List<Segment> list,
    {
      ///Whether the List should be sorted to have a descending order.
      ///The default is False (by default the list is sorted by the ascending 
      ///order).
      bool? descending
    }
  ) 
  {
    List<Segment> retval = <Segment>[]+list;
    if (descending != null && descending == true) 
    {
      retval.sort((a, b) => -(a._start.compareTo(b._start)));
    } 
    else 
    {
      retval.sort((a, b) => a._start.compareTo(b._start));
    }
    for (int i=0;i<retval.length;i++)
    {
      if (retval[i].isNullSegment)
      {
        retval.removeAt(i);
        if (descending!=null && descending==true)
        {
          retval.add(Segment(start:0,end:0));
        }
        else
        {
          retval.insert(0, Segment(start:0,end:0));
        }
        break;
      }
    }
    return retval;
  }

  /// The function that normalizes the segments so that they do not collide
  /// Normalization follows the rules of [Mask] normalization
  static List<Segment> normalize(List<Segment> list)
  {
    List<Segment> tmplist = sorted(list);
    List<Segment> retval = <Segment>[];
    int currentInd=1;
    int currentStartInd=0;
    int cap=tmplist[0].end;
    while(currentInd<tmplist.length)
    {
      if (cap<tmplist[currentInd].start)
      {
        retval.add(Segment(start:tmplist[currentStartInd].start, end:cap));
        currentStartInd=currentInd;
        cap=tmplist[currentInd].end;
      }
      else if (cap == tmplist[currentInd].start)
      {
        cap = tmplist[currentInd].end;
      }
      else if (cap<tmplist[currentInd].end)
      {
        cap=tmplist[currentInd].end;
      }
      currentInd++;
    }
    retval.add(Segment(start:tmplist[currentStartInd].start, end:cap));
    return retval;
  }

  @override
  String toString() => "Segment: ( $_start - $_end )";

  /// Get the copy of a segment (to assign "by value").
  Segment get copy => Segment(start: _start, end: _end);

  /// Returns true if the [Segment] = [0;0]
  bool get isNullSegment => (start==0 && end==0);

  /// The start position of ___ for the symbols to be included from
  int get start => _start;

  /// The end position of ___ for the symbols ot be included up to
  int get end => _end;

  /// The amount of characters between start and end positions
  int get length => _end-_start;
}
