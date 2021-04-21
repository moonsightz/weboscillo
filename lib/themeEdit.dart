import 'package:flutter/material.dart';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

import 'prefData.dart';

class ThemeForm extends StatefulWidget {
  final bool _isDark;
  final String _colorName;

  ThemeForm(bool isDark, String colorName)
      : this._isDark = isDark,
        this._colorName = colorName;

  @override
  _ThemeForm createState() => _ThemeForm(this._isDark, this._colorName);
}

class _ThemeForm extends State<ThemeForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isDark;
  String _colorName;

  _ThemeForm(bool isDark, String colorName)
      : this._isDark = isDark,
        this._colorName = colorName;

  void setTheme() {
    EasyDynamicTheme.of(context).changeTheme(dark: this._isDark);
  }

  void _handleColor(colorName) {
    setState(() {
      this._colorName = colorName;
    });
    PrefData.setThemeColorName(colorName);
    setTheme();
  }

  void _handleSwitch(bool isDark) {
    setState(() {
      this._isDark = isDark;
    });
    PrefData.setThemeIsDark(isDark);
    setTheme();
  }

  RadioListTile _radio(String colorName) {
    return RadioListTile(
      title: Text(colorName),
      value: colorName,
      groupValue: this._colorName,
      onChanged: _handleColor,
      selected: this._colorName == colorName,
    );
  }

  Widget build(BuildContext context) {
    List<Widget> radioList = [];
    for (var k in PrefData.themeColorNames()) {
      radioList.add(_radio(k));
    }
    return Scaffold(
      appBar: AppBar(
          title: Text('Theme'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context,
                  {'isDark': this._isDark, 'colorName': this._colorName});
            },
          )),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: this._isDark,
                  title: Text('Dark mode',
                      maxLines: 1, style: TextStyle(fontSize: 16)),
                  onChanged: _handleSwitch,
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: radioList,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
