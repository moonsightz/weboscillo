import 'dart:async';

import 'package:flutter/material.dart';

import 'itemData.dart';

class ItemEditForm extends StatefulWidget {
  ItemData _data;

  ItemEditForm(ItemData itemData) : this._data = itemData;

  @override
  _ItemEditForm createState() => _ItemEditForm(data: this._data);
}

class _ItemEditForm extends State<ItemEditForm> {
  final _formKey = GlobalKey<FormState>();
  ItemData _data;
  final titleController = TextEditingController();
  String defaultProtocol = 'https://';

  _ItemEditForm({data: ItemData}) : this._data = data;

  @override
  void initState() {
    titleController.text = this._data.title;
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  String _complementUrl(String s, String defaultProtocol) {
    if (s.startsWith('https://') || s.startsWith('http://')) {
      return s;
    } else {
      return defaultProtocol + s;
    }
  }

  Widget build(BuildContext context) {
    var isEnabledGetTitle = false;
    if (this._data.isChecking == false) {
      var url = this._data.url;
      if (url != null && url != '' && Uri.parse(url).isAbsolute) {
        isEnabledGetTitle = true;
      }
    }
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(children: <Widget>[
                TextFormField(
                  controller: titleController,
                  enabled: this._data.isChecking == false,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onSaved: (String? value) {
                    this._data.title = value ?? '';
                  },
                  onChanged: (String value) {
                    this._data.title = value;
                  },
                ),
                SizedBox(
                  height: 20,
                  child: ElevatedButton(
                      onPressed: isEnabledGetTitle == false
                          ? null
                          : () async {
                              setState(() {
                                this._data.isChecking = true;
                                this._data.title = '...';
                                this._data.url = _complementUrl(
                                    this._data.url, defaultProtocol);
                              });
                              String title =
                                  await getTitleFromHtml(this._data.url);
                              setState(() {
                                titleController.text = title;
                                this._data.title = title;
                                this._data.isChecking = false;
                              });
                            },
                      child: Text('Get title')),
                ),
                TextFormField(
                  enabled: true,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'URL'),
                  initialValue: _complementUrl(this._data.url, defaultProtocol),
                  onSaved: (String? value) {
                    var defaultProtocol = 'https://';
                    this._data.url =
                        _complementUrl(value ?? '', defaultProtocol);
                  },
                  onChanged: (String value) {
                    setState(() {
                      this._data.url = value;
                    });
                  },
                ),
                TextFormField(
                  enabled: true,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'URL to check'),
                  initialValue: this._data.urlToCheck,
                  onSaved: (String? value) {
                    var defaultProtocol =
                        'https://'; // PrefData.defaultProtocol();
                    if (value == null || value == '') {
                      this._data.urlToCheck =
                          _complementUrl(this._data.url, defaultProtocol);
                    } else {
                      this._data.urlToCheck =
                          _complementUrl(value, defaultProtocol);
                    }
                  },
                  onChanged: (String value) {
                    this._data.urlToCheck = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    this._formKey.currentState?.save();
                    Navigator.pop(context, this._data);
                  },
                  child: Text('Done'),
                ),
              ]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Delete this',
          child: Icon(Icons.delete_forever),
          onPressed: () {
            this._data.isToBeDeleted = true;
            Navigator.pop(context, this._data);
          }),
    );
  }
}
