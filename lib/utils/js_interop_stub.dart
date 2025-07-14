class JSAny implements Map<String, dynamic> {
  // The actual data being wrapped
  final dynamic _data;
  
  // Constructor to create a JSAny from any data type
  JSAny(this._data);
  
  // Factory constructor to handle null values
  factory JSAny.fromJson(dynamic json) {
    return JSAny(json);
  }
  
  // Allow implicit conversion from various data types
  static JSAny? from(dynamic value) {
    if (value == null) return null;
    return JSAny(value);
  }
  
  // Allow access to the underlying data
  dynamic get data => _data;
  
  // Convert to string
  @override
  String toString() {
    return _data?.toString() ?? 'null';
  }
  
  // Support for map-like access if the underlying data is a map
  @override
  dynamic operator [](Object? key) {
    if (_data is Map) {
      var value = _data[key];
      // If the value is a Map, wrap it in a JSAny
      if (value is Map) {
        return JSAny(value);
      }
      return value;
    }
    return null;
  }
  
  // Support for map-like assignment
  @override
  void operator []=(String key, dynamic value) {
    if (_data is Map) {
      _data[key] = value;
    }
  }
  
  // Check if a key exists in the map
  @override
  bool containsKey(Object? key) {
    if (_data is Map) {
      return _data.containsKey(key);
    }
    return false;
  }
  
  // Check if a value exists in the map
  @override
  bool containsValue(Object? value) {
    if (_data is Map) {
      return _data.containsValue(value);
    }
    return false;
  }
  
  // Get all keys from the map
  @override
  Iterable<String> get keys {
    if (_data is Map) {
      return (_data as Map).keys.map((k) => k.toString());
    }
    return [];
  }
  
  // Get all values from the map
  @override
  Iterable<dynamic> get values {
    if (_data is Map) {
      return (_data as Map).values;
    }
    return [];
  }
  
  // Get the length of the map or list
  @override
  int get length {
    if (_data is Map) {
      return (_data as Map).length;
    } else if (_data is List) {
      return (_data as List).length;
    }
    return 0;
  }
  
  // Check if the map or list is empty
  @override
  bool get isEmpty {
    if (_data is Map) {
      return (_data as Map).isEmpty;
    } else if (_data is List) {
      return (_data as List).isEmpty;
    }
    return true;
  }
  
  // Check if the map or list is not empty
  @override
  bool get isNotEmpty {
    return !isEmpty;
  }
  
  // Support for equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is JSAny) {
      return _data == other._data;
    }
    return _data == other;
  }
  
  @override
  int get hashCode => _data.hashCode;
  
  // Additional Map interface methods
  @override
  void addAll(Map<String, dynamic> other) {
    if (_data is Map) {
      (_data as Map).addAll(other);
    }
  }
  
  @override
  void clear() {
    if (_data is Map) {
      (_data as Map).clear();
    }
  }
  
  @override
  void forEach(void Function(String key, dynamic value) action) {
    if (_data is Map) {
      (_data as Map).forEach((key, value) => action(key.toString(), value));
    }
  }
  
  @override
  Map<K, V> cast<K, V>() {
    if (_data is Map) {
      return (_data as Map).cast<K, V>();
    }
    return {};
  }
  
  @override
  dynamic remove(Object? key) {
    if (_data is Map) {
      return (_data as Map).remove(key);
    }
    return null;
  }
  
  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String key, dynamic value) convert) {
    if (_data is Map) {
      Map<K2, V2> result = {};
      (_data as Map).forEach((key, value) {
        final entry = convert(key.toString(), value);
        result[entry.key] = entry.value;
      });
      return result;
    }
    return <K2, V2>{};
  }
  
  @override
  Iterable<MapEntry<String, dynamic>> get entries {
    if (_data is Map) {
      return (_data as Map).entries.map(
        (entry) => MapEntry(entry.key.toString(), entry.value)
      );
    }
    return [];
  }
  
  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) {
    if (_data is Map) {
      (_data as Map).addEntries(newEntries);
    }
  }
  
  @override
  dynamic putIfAbsent(String key, dynamic Function() ifAbsent) {
    if (_data is Map) {
      return (_data as Map).putIfAbsent(key, ifAbsent);
    }
    return null;
  }
  
  @override
  void removeWhere(bool Function(String key, dynamic value) test) {
    if (_data is Map) {
      (_data as Map).removeWhere((key, value) => test(key.toString(), value));
    }
  }
  
  @override
  dynamic update(String key, dynamic Function(dynamic value) update, {dynamic Function()? ifAbsent}) {
    if (_data is Map) {
      return (_data as Map).update(key, update, ifAbsent: ifAbsent);
    }
    return null;
  }
  
  @override
  void updateAll(dynamic Function(String key, dynamic value) update) {
    if (_data is Map) {
      (_data as Map).updateAll((key, value) => update(key.toString(), value));
    }
  }
}

// Extension to allow treating dynamic values as JSAny
extension DynamicToJSAny on dynamic {
  JSAny? get asJSAny => JSAny.from(this);
}
