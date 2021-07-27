import 'package:flutter/material.dart';

class PrefixForm extends StatefulWidget {
  final String _prefix;

  PrefixForm(String prefix) : this._prefix = prefix;

  @override
  _PrefixForm createState() => _PrefixForm(this._prefix);
}

class _PrefixForm extends State<PrefixForm> {
  final _formKey = GlobalKey<FormState>();

  String _prefix;

  static const protocolHttps = 'https://';
  static const protocolHttp = 'http://';

  _PrefixForm(String prefix) : this._prefix = prefix;

  void _handlePrefix(String? prefix) {
    setState(() {
      this._prefix = prefix ?? '';
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Prefix'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, this._prefix);
            },
          )),
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RadioListTile(
                        title: Text('"$protocolHttps"'),
                        value: protocolHttps,
                        groupValue: this._prefix,
                        onChanged: _handlePrefix,
                        selected: this._prefix == protocolHttps,
                      ),
                      RadioListTile(
                        title: Text('"$protocolHttp"'),
                        value: protocolHttp,
                        groupValue: this._prefix,
                        onChanged: _handlePrefix,
                        selected: this._prefix == protocolHttp,
                      ),
                      RadioListTile(
                        title: Text('None'),
                        value: '',
                        groupValue: this._prefix,
                        onChanged: _handlePrefix,
                        selected: this._prefix == '',
                      ),
                    ],
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
