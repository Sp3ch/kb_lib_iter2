import './mask.dart';
import '../new_variable_content.dart';

/// The class to store the relationship between the [Variable] and it's place
/// inside the string that signifies the [Predicate].
class ThingInPredicate
{
  /// The [Variable] that is associated with the [Predicate].
  Variable? thing;
  /// The [Mask] that defines the exact locations of the symbols that are a part
  /// of a sign, contained in the [Predicate]'s phrase string.
  Mask _mask=Mask();
  /// The string that is stored to be quickly accessed while forming questions.
  late String _representation;

  ThingInPredicate(String phrase,{this.thing,Mask? mask})
  {
    _representation=thing!.mainAlias;
    if (mask!=null && mask.size!=0 && !mask.isEmpty)
    {
      if (mask.max>phrase.length)
      {
        throw FormatException('Попытка поставить маску больше, чем длина фразы.');
      }
      _updateRepresentation(phrase);
      _mask=mask;
    }
    else if (thing!=null) {_mask=Mask();} // [0;0]
    else{_representation="[something of a length of ${mask!=null ? mask.size : 0} chars ${mask==null ? "(empty)" : ""}]";}
  }

  ///Reset the mask for the thing. The string of the phrase is needed to check 
  ///whether the new mask is not too large, sinse the [ThingInPredicate] does not
  ///store the whole phrase.
  void setMask(Mask mask, String phrase)
  {
    if (mask.max>phrase.length)
    {
      throw FormatException('Попытка изменить одну из масок для фразы на маску, большую, чем длина фразы.');
    }
    _mask=mask;
  }

  /// Update the representation property based on the current mask and the new
  /// or the current phrase string
  void _updateRepresentation(String phrase) 
    => _representation=_mask.select(phrase) ?? _representation;

  @override
  String toString()
  {
    String retval = "ThingInPhrase \"$representation\":";
    retval+="\n        thing: $thing";
    retval+="\n        mask: $mask";
    return retval;
  }

  /// The form that the [Variable] takes inside the [Predicate]
  String get representation => _representation;

  /// Get the [Mask] that marks the [Variable] in the current phrase
  Mask get mask => _mask;

  bool get isEmpty => mask.isEmpty && thing==null;
  
  ///Get the copy of the [ThingInPredicate] (to assign "by value")
  ThingInPredicate getCopy(String phrase) 
    => ThingInPredicate(phrase, thing: thing, mask: _mask.copy);
}

