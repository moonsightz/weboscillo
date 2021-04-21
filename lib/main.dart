import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'itemData.dart';
import 'itemEdit.dart';
import 'prefData.dart';
import 'prefEdit.dart';

// To avoid displaying a wait indicator when boot.
// (Just a few libraries and data will be initialized)
List<ItemData> _itemDataList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefData.init();
  _itemDataList = await loadItemData();

  runApp(EasyDynamicThemeWidget(child: WebOscillo()));
}

class WebOscillo extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final color = PrefData.themeColor();
    return MaterialApp(
      home: WebCheckerPage(title: 'WebOscillo'),
      theme: ThemeData(
          primaryColor: color,
          accentColor: color,
          primaryColorDark: color,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          primaryColor: color,
          accentColor: color,
          primaryColorDark: color,
          brightness: Brightness.dark),
      themeMode: EasyDynamicTheme.of(context).themeMode,
    );
  }
}

class WebCheckerPage extends StatefulWidget {
  WebCheckerPage({Key, key, required this.title}) : super(key: key);
  final String title;

  @override
  WebCheckerPageState createState() => WebCheckerPageState();
}

class WebCheckerPageState extends State<WebCheckerPage> {
  int idMax = 0;
  List<ItemData> itemDataList = [];

  WebCheckerPageState() : itemDataList = _itemDataList {
    for (final d in itemDataList) {
      final id = d.id;
      if (id > this.idMax) {
        this.idMax = id;
      }
    }
    _itemDataList = []; // Not used after this.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, i) {
          var data = itemDataList[i];
          var mainText =
              data.title == null ? data.url : data.title + ' : ' + data.url;
          var subLmText = data.lastModified?.toLocal().toString() ?? '';
          var subLmTextLength = subLmText.length;
          if (subLmTextLength > 0) {
            subLmText = subLmText.substring(0, subLmTextLength - 4); // '.000'
          } else {
            subLmText = '---';
          }
          subLmText += ', ';
          const MD5_DISPLAY_LENGTH = 6;
          var md5Str = data.md5;
          var md5SubStr =
              md5Str.substring(0, min(MD5_DISPLAY_LENGTH, md5Str.length));
          var subMd5Text = 'MD5: $md5SubStr';

          FontWeight _getWeight(bool v) {
            return v ? FontWeight.bold : FontWeight.normal;
          }

          return GestureDetector(
            child: Card(
                child: Row(children: <Widget>[
              data.updated
                  ? Container(
                      child: Icon(Icons.arrow_upward,
                          color: Theme.of(context).accentColor),
                      width: 20,
                    )
                  : data.isChecking
                      ? Container(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                          width: 10,
                          height: 10,
                        )
                      : Container(
                          width: 20,
                        ),
              Expanded(
                  child: Container(
                child: ListTile(
                  title: Text(mainText,
                      maxLines: 1, style: TextStyle(fontSize: 14)),
                  subtitle: Row(children: <Widget>[
                    Text(subLmText,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                _getWeight(data.updatedByLastModified))),
                    Text(subMd5Text,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: _getWeight(data.updatedByMd5))),
                  ]),
                ),
                width: 10,
              ))
            ])),
            onTap: () {
              setState(() {
                _resetUpdated(data);
              });
              _launchUrl(data.url);
            },
            onLongPress: () {
              _edit(i);
            },
          );
        },
        itemCount: itemDataList.length,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Item'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _navigationBarTapped(context, index);
        },
      ),
    );
  }

  void _navigationBarTapped(BuildContext context, int index) async {
    switch (index) {
      case 0:
        _check();
        break;

      case 1:
        itemDataList.insert(0, ItemData(++idMax));
        _edit(0);
        break;

      case 2:
        _pref();
        break;
    }
  }

  void _update() {
    updateItemDataList(itemDataList);
  }

  Future<void> _checkItem(ItemData d) async {
    await checkItemData(d);
    setState(() {
      d.isChecking = false;
    });
  }

  void _check() async {
    setState(() {
      for (var d in itemDataList) {
        d.isChecking = true;
        _resetUpdated(d);
      }
    });
    List<Future<void>> fList = [];
    for (var d in itemDataList) {
      fList.add(_checkItem(d));
    }

    for (var f in fList) {
      await f;
    }
    setState(() {
      _update();
    });
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _resetUpdated(ItemData data) {
    data.updated = false;
    data.updatedByLastModified = false;
    data.updatedByMd5 = false;
  }

  void _edit(int index) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ItemEditForm(this.itemDataList[index])),
    );
    if (result != null && result.isToBeDeleted == false) {
      setState(() {
        itemDataList[index] = result;
      });
      //_insert(itemDataList[index]);
      _update();
    } else {
      setState(() {
        itemDataList.removeAt(index);
      });
      if (result.isFiled == true) {
        //_delete(result);
        _update();
      }
    }
  }

  void _pref() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrefEditForm()),
    );
  }
}
