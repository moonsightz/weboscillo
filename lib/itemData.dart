import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:jcombu/jcombu.dart' as jcombu;

import 'prefData.dart';

class ItemData {
  int id;
  bool isFiled = false;
  bool isToBeDeleted = false;
  bool isChecking = false;
  String url = '';
  String urlToCheck = '';
  String title = '';
  bool updated = false;
  bool updatedByLastModified = false;
  bool updatedByMd5 = false;
  DateTime? lastModified;
  DateTime? lastChecked;
  int contentLength = 0;
  String md5 = '';

  ItemData(int id) : this.id = id;

  ItemData.fromMap(Map<String, dynamic> m) : this.id = m['id'] {
    this.isFiled = true;
    this.url = m['url'] ?? '';
    this.urlToCheck = m['urlToCheck'] ?? '';
    this.title = m['title'] ?? '';
    this.lastModified = _parseDateTimeString(m['lastModified']);
    this.lastChecked = _parseDateTimeString(m['lastChecked']);
    this.contentLength = m['contentLength'] ?? 0;
    this.md5 = m['md5'] ?? '';
    this.updated = m['updated'] ?? false;
    this.updatedByLastModified = m['updatedByLastModified'] ?? false;
    this.updatedByMd5 = m['updatedByLastMd5'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'url': this.url,
      'urlToCheck': this.urlToCheck,
      'title': this.title,
      'lastModified': this.lastModified?.toString() ?? '',
      'lastChecked': this.lastChecked?.toString() ?? '',
      'contentLength': this.contentLength,
      'md5': this.md5,
      'updated': this.updated,
      'updatedByLastModified': this.updatedByLastModified,
      'updatedByMd5': this.updatedByMd5,
    };
  }
}

DateTime? _parseDateTimeString(String dtString) {
  DateTime? dt;
  if (dtString != '') {
    dt = DateTime.parse(dtString);
  }

  return dt;
}

Future<List<ItemData>> loadItemData() async {
  List<ItemData> r = [];
  final l = PrefData.itemDataList();
  for (final i in l) {
    final d = ItemData.fromMap(i);
    r.add(d);
  }

  return r;
}

Future<void> updateItemDataList(List<ItemData> itemDataList) async {
  List<Map<String, dynamic>> l = [];
  for (final i in itemDataList) {
    final m = i.toMap();
    l.add(m);
  }
  PrefData.setItemDataList(l);
}

String _getTitle(http.Response response) {
  var document = parse(response.body);
  String? charset;
  final head = document.head;
  if (head != null) {
    for (var v in head.querySelectorAll('meta')) {
      var attrContent = v.attributes['content'];
      if (v.attributes['http-equiv'] == 'content-type' && attrContent != null) {
        var media = MediaType.parse(attrContent);
        var mediaCharset = media.parameters['charset'];
        if (mediaCharset != null) {
          charset = mediaCharset;
        }
      }
      for (var k in v.attributes.keys) {
        if (k == 'charset') {
          charset = v.attributes[k] ?? 'utf-8';
          break;
        }
      }
    }
  }
  if (charset != null) {
    String reBody;
    // no-hyphen cases are just in case
    switch (charset.toLowerCase()) {
      case 'euc-jp':
      case 'eucjp':
        reBody = jcombu.convertEucJp(response.bodyBytes);
        break;
      case 'shift-jis':
      case 'shiftjis':
      case 's-jis':
      case 'sjis':
        reBody = jcombu.convertShiftJis(response.bodyBytes);
        break;
      case 'jis':
      case 'iso-2022-jp':
      case 'iso-2022-jp-2':
      case 'iso-2022-jp-3':
      case 'iso-2022-jp-2004':
      case 'iso2022jp':
      case 'iso2022jp2':
      case 'iso2022jp3':
      case 'iso2022jp2004':
        reBody = jcombu.convertJis(response.bodyBytes);
        break;
      default:
        final e = Encoding.getByName(charset);
        if (e != null) {
          reBody = e.decode(response.bodyBytes);
        } else {
          reBody = '';
        }
        break;
    }

    document = parse(reBody);
  }

  var title = document.querySelector('title')?.text;
  title = title?.replaceAll('\n', '').replaceAll('\r', '');
  return title ?? '';
}

Future<void> checkItemData(ItemData data) async {
  var client = http.Client();
  var res = await client.get(Uri.parse(data.urlToCheck));
  var lm = res.headers[HttpHeaders.lastModifiedHeader];
  if (lm != null) {
    var dt = parseHttpDate(lm);
    data.updatedByLastModified = dt != data.lastModified;
    data.lastModified = dt;
  }

  var md5Text = crypto.md5.convert(res.bodyBytes).toString();
  data.updatedByMd5 = md5Text != data.md5;
  data.md5 = md5Text;
  data.updated = data.updatedByLastModified || data.updatedByMd5;
}

Future<String> getTitleFromHtml(String url) async {
  var client = http.Client();
  var res = await client.get(Uri.parse(url));
  return _getTitle(res);
}
