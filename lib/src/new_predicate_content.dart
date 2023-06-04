import 'representations/new_thinginpredicate.dart';
import './new_variable_content.dart';
import './representations/mask.dart';

/// 
abstract class Predicate
{
  late String _phrase;
  late String _identifier;
  List<ThingInPredicate>? _things;
  bool _created_phrase=false;
  bool _created_identifier = false;

  bool clearAllEmptyThingInPredicates()
  {
    bool retval=false;
    if (_things!=null)
    {
      for (ThingInPredicate thing in _things!)
      {
        if (thing.isEmpty)
        {
          _things!.remove(thing);
          retval=true;
        }
      }
    }
    return retval;
  }

  ThingInPredicate? findThingInPredicateByIdentifier(String identifier)
  {
    if (_things==null){return null;}
    for (ThingInPredicate thing in _things!)
    {
      if (thing.thing!=null && thing.thing!.identifier == identifier)
      {
        return thing;
      }
    }
    return null;
  }

  ThingInPredicate? findThingInPhraseByVariable(Variable variable)
  {
    if (_things==null)
    {
      return null;
    }
    for (ThingInPredicate thing in _things!)
    {
      if (thing.thing!= null && thing.thing==variable) {return thing;}
    }
    return null;
  }

  Mask? getMaskOfVariable(Variable variable) 
    => findThingInPhraseByVariable(variable)?.mask;

  String? getRepresentationOfVariable(Variable variable)
    => findThingInPhraseByVariable(variable)?.representation;

  bool setMaskForVariable(Variable variable, Mask mask)
  {
    ThingInPredicate? tmpTip = findThingInPhraseByVariable(variable);
    if (tmpTip==null) {return false;}
    else
    {
      tmpTip.setMask(mask,_phrase);
      return true;
    }
  }

  bool addThingInPredicate(ThingInPredicate thing)
  {
    List<Mask> masks = <Mask>[];
    if (_things!=null && _things!.isNotEmpty)
    {
      for (ThingInPredicate t in _things!)
      {
        masks.add(t.mask);
      }
    }
    if 
    (
      !thing.mask.collidesWithAnyIn(masks) && 
      (
        thing.thing!=null && findThingInPhraseByVariable(thing.thing!)==null ||
        thing.thing==null && 
        (
          !thing.mask.isEmpty && 
          findAllThingsInPhraseByMainAlias(thing.mask.select(_phrase)!).isEmpty
        )
          
      )
    )
    {
      _things ??= <ThingInPredicate>[];
      if (!thing.isEmpty)
      {
        _things!.add(thing);
        return true;
      }
    }
    return false;
  }

  List<ThingInPredicate> findAllThingsInPhraseByMainAlias(String mainAlias)
  {
    if (_things == null){return <ThingInPredicate>[];}
    List<ThingInPredicate> retval = <ThingInPredicate>[];
    for (ThingInPredicate thing in _things!)
    {
      if (thing.thing!=null && thing.thing!.mainAlias==mainAlias)
      {
        retval.add(thing);
      }
    }
    return retval;
  }

  List<ThingInPredicate> findAllThingsInPhraseByAlias(String alias)
  {
    if (_things == null){return <ThingInPredicate>[];}
    List<ThingInPredicate> retval = <ThingInPredicate>[];
    for (ThingInPredicate thing in _things!)
    {
      if 
      (
        thing.thing!=null && 
        (
          thing.thing!.mainAlias==alias ||
          thing.thing!.otherAliases!=null && 
            thing.thing!.otherAliases!.contains(alias)
        )
      )
      {
        retval.add(thing);
      }
    }
    return retval;
  }

  List<ThingInPredicate> findAllThingsInPhraseByString(String string)
  {
    if (_things == null){return <ThingInPredicate>[];}
    List<ThingInPredicate> retval = <ThingInPredicate>[];
    for (ThingInPredicate thing in _things!)
    {
      if (thing.thing!=null && thing.thing!.mainAlias==string)
      {
        retval.add(thing);
      }
      else if (thing.thing!.otherAliases!=null)
      {
        for (String alias in thing.thing!.otherAliases!)
        {
          if (alias.contains(string))
          {
            retval.add(thing);
            break;
          }
        }
      }
    }
    return retval;
  }

  String bluredPhrase
  ({
    List<Variable>? variables,
    List<String>? mainAliases,
    List<String>? aliases,
    List<String>? strings,
  })
  {
    if 
    (
      variables==null &&
      mainAliases==null && 
      aliases == null &&
      strings == null
    )
    {return _phrase;}
    late ThingInPredicate? addval;
    Set<ThingInPredicate> things = <ThingInPredicate>{};
    if (variables!=null)
    {
      for (Variable variable in variables)
      {
        addval = findThingInPhraseByVariable(variable);
        if (addval!=null)
        {
          things.add(addval);
        }
      }
    }
    if (mainAliases!=null)
    {
      for (String mainAlias in mainAliases)
      {
        things.addAll(findAllThingsInPhraseByMainAlias(mainAlias));
      }
    }
    if (aliases!=null)
    {
      for (String alias in aliases)
      {
        things.addAll(findAllThingsInPhraseByAlias(alias)); 
      }
    }
    if (strings!=null)
    {
      for (String string in strings)
      {
        things.addAll(findAllThingsInPhraseByString(string));
      }
    }
    List<Mask> tmpmasks = <Mask>[];
    for (ThingInPredicate thing in things)
    {
      tmpmasks.add(thing.mask);
    }
    return blureMultiple(_phrase, tmpmasks);
  }

  set identifier(String identifier)
  {
    if (!_created_identifier)
    {
      _created_identifier=true;
      _identifier=identifier;
    }
  }

  set phrase(String phrase)
  {
    if (!_created_phrase)
    {
      _phrase=phrase;
      _created_phrase=true;
    }
  }

  @override
  String toString() 
  {
    String retval="Predicate (\"";
    if (identifier.length<20){retval+=_identifier;}
    else {retval+="${_identifier.substring(0,20)}...";}
    retval+='")\n';
    if (_things==null){retval+="    things: null";}
    else
    {
      retval+="    things:";
      for (ThingInPredicate thing in _things!)
      {
        retval+="\n      $thing";
      }
    }
    return retval;
  }

  String get phrase => _phrase;
  String get identifier => _identifier;
  
  List<ThingInPredicate>? get things 
  {
    if (_things==null){return null;}
    List<ThingInPredicate>? retval = <ThingInPredicate>[];
    for(ThingInPredicate thing in _things!)
    {
      retval.add(thing.getCopy(_phrase));
    }
    return retval;
  }
}