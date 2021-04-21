import 'package:flutter/material.dart';

import 'prefData.dart';
import 'prefixEdit.dart';
import 'themeEdit.dart';

Brightness _getBrightness(bool isDark) {
  return isDark ? Brightness.dark : Brightness.light;
}

class PrefEditForm extends StatefulWidget {
  PrefEditForm();

  @override
  _PrefEditForm createState() => _PrefEditForm();
}

class PrefItem {
  String title;

  PrefItem({title: String}) : this.title = title;
}

class _PrefEditForm extends State<PrefEditForm> {
  final _formKey = GlobalKey<FormState>();

  String _prefix = PrefData.defaultProtocol();
  bool _isDark = PrefData.themeIsDark();
  String _colorName = PrefData.themeColorName();

  var _items = [
    PrefItem(title: 'Prefix'),
    PrefItem(title: 'Theme'),
  ];

  Widget _itemBuild(context, i) {
    switch (i) {
      case 0:
        var title = this._items[i].title;
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrefixForm(this._prefix),
                ));
            setState(() {
              this._prefix = result;
            });
            PrefData.setDefaultProtocol(this._prefix);
          },
          child: ListTile(
            title: Text(title, maxLines: 1, style: TextStyle(fontSize: 16)),
            subtitle: Row(
              children: <Widget>[
                Text(this._prefix == '' ? 'None' : '"${this._prefix}"',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
        break;

      case 1:
        var title = this._items[i].title;
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ThemeForm(this._isDark, this._colorName),
                ));
            setState(() {
              this._colorName = result['colorName'];
              this._isDark = result['isDark'];
            });
            PrefData.setThemeColorName(this._colorName);
            PrefData.setThemeIsDark(this._isDark);
            // Theme was already changed in themeEdit.
          },
          child: ListTile(
            title: Text(title, maxLines: 1, style: TextStyle(fontSize: 16)),
            subtitle: Row(
              children: <Widget>[
                Text(
                    PrefData.themeColorName() +
                        (PrefData.themeIsDark() ? ' (Dark)' : ''),
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
        break;

      default:
        var title = '';
        var value = '';
        return GestureDetector(
          onTap: null,
          child: ListTile(
            title: Text(title, maxLines: 1, style: TextStyle(fontSize: 16)),
            subtitle: Row(
              children: <Widget>[
                Text(value == '' ? 'None' : '"$value"',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
        break;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Preference'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, this._prefix);
            },
          )),
      body: Center(
        child: ListView.separated(
          itemBuilder: this._itemBuild,
          separatorBuilder: (context, i) {
            return Divider(color: Theme.of(context).dividerColor);
          },
          itemCount: this._items.length,
        ),
      ),
    );
  }
}
