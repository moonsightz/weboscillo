import 'dart:convert' as conv;

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'itemData.dart';

class PrefData {
  static SharedPreferences? _sharedPref;

  static const String _defaultProtocolKey = 'defaultProtocol';
  static const String _themeIsDarkKey = 'themeIsDark';
  static const String _themeColorKey = 'themeColor';
  static const String _itemDataKey = 'itemData';
  static const Map<String, Color> _colorMap = {
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Green': Colors.green,
    'Amber': Colors.amber,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Cyan': Colors.cyan,
  };

  static const String _defaultDefaultProtocol = 'https://';
  static const String _defaultColorString = 'Blue';
  static const bool _defaultDarkMode = false;

  static Future<void> init() async {
    _sharedPref = await SharedPreferences.getInstance();

    var defaultProtocol = _sharedPref?.getString(_defaultProtocolKey);
    if (defaultProtocol == null) {
      _sharedPref?.setString(_defaultProtocolKey, _defaultDefaultProtocol);
    }

    var themeColor = _sharedPref?.getString(_themeColorKey);
    if (themeColor == null) {
      _sharedPref?.setString(_themeColorKey, _defaultColorString);
    }

    var themeIsDark = _sharedPref?.getBool(_themeIsDarkKey);
    if (themeIsDark == null) {
      _sharedPref?.setBool(_themeIsDarkKey, _defaultDarkMode);
    }
  }

  static String defaultProtocol() {
    return _sharedPref?.getString(_defaultProtocolKey) ??
        _defaultDefaultProtocol;
  }

  static void setDefaultProtocol(String defaultProtocol) {
    _sharedPref?.setString(_defaultProtocolKey, defaultProtocol);
  }

  static bool themeIsDark() {
    return _sharedPref?.getBool(_themeIsDarkKey) ?? _defaultDarkMode;
  }

  static void setThemeIsDark(bool isDark) {
    _sharedPref?.setBool(_themeIsDarkKey, isDark);
  }

  static Color themeColor() {
    var colorString = _sharedPref?.getString(_themeColorKey);
    var color = _colorMap[colorString];
    if (color == null) {
      color = _colorMap[_defaultColorString];
    }
    return color!;
  }

  static List<String> themeColorNames() {
    return _colorMap.keys.toList();
  }

  static String themeColorName() {
    return _sharedPref?.getString(_themeColorKey) ?? _defaultColorString;
  }

  static void setThemeColorName(String colorName) {
    for (var k in _colorMap.keys) {
      if (k == colorName) {
        _sharedPref?.setString(_themeColorKey, k);
        return;
      }
    }
    throw 'Color $colorName is not defined';
  }

  static List<dynamic> itemDataList() {
    final String s = _sharedPref?.getString(_itemDataKey) ?? '[]';
    return conv.json.decode(s);
  }

  static void setItemDataList(List<dynamic> itemDataList) {
    final String s = conv.json.encode(itemDataList);
    _sharedPref?.setString(_itemDataKey, s);
  }
}
