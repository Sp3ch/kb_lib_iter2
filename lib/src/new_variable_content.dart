abstract class Variable
{
  late  String _mainAlias;
  late String _identifier;
  List<String>? _aliases;
  bool _created_mainAlias = false;
  bool _created_identifier = false;
  
  bool aliasesContain(String alias) => _aliases?.contains(alias)?? false;

  void addAlias(String alias)
  {
    _aliases??=<String>[];
    _aliases!.add(alias);
  }

  set mainAlias(String mainAlias)
  {
    if (!_created_mainAlias)
    {
      _mainAlias = mainAlias;
      _created_mainAlias=true;
    }
  }

  set identifier(String identifier)
  {
    if (!_created_identifier)
    {
      _created_identifier=true;
      _identifier=identifier;
    }
  }

  set aliases(List<String>? aliases)
  {
    if (aliases!=null)
    {
      _aliases ??= <String>[];
      _aliases!.addAll(aliases);
    }
  }

  set alias(String alias)
  {
    _aliases ??= <String>[];
    _aliases!.add(alias);
  }

  @override
  String toString()
  {
    String retval="Variable (\"$_identifier\")";
    return retval;
  }

  String get mainAlias => _mainAlias;
  String get identifier => _identifier;
  bool get hasOtherAliases => _aliases!=null;
  List<String>? get otherAliases => _aliases;
}
