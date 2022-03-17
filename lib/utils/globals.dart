library globals;

import 'dart:math';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ess_mobile/models/auth_model.dart';
import 'package:ess_mobile/models/chat_model.dart';

// const apiUrl = 'http://123.231.248.72:9091'; // DEV
const apiUrl = 'https://ess.tps.co.id'; // PRD
const fcmUrl = 'https://fcm.googleapis.com/fcm/send';
const fcmServerKey =
    'AAAAOMyfdAw:APA91bGRXnvuxGK8JTnp_hzGriecPHvZgAppxYjwEgogbnHFNZa_ll0YAlXtHS_vsaiV6-8M9mkgph8El1xo1I49ZQDBYUuavwTmycjSIr9k5sobGqSU3wQlfp5GXLFpZuEIc8uUCba9';
const bool hidden = true;
const inactivityTimeout = Duration(hours: 1);

dynamic platform;

AuthModel appAuth = AuthModel.fromJson({});
AuthorModel chatAuthor = AuthorModel.fromJson({});

Map<String, dynamic> params = {};
Map<String, dynamic> filterValue = {};

String currentRoute = '';

int totalTask = 0;
int totalActivity = 0;

final DateTime today = DateTime.now();
final DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
final DateTime lastDayOfMonth =
    DateTime(today.year, today.month + 1, 0, 23, 59);

final DateTime initDateTime = today;
final DateTime firstDateTime = DateTime(1950);
final DateTime lastDateTime = DateTime(today.year + 10);

final formatCurrency = NumberFormat.currency(locale: 'id_ID', name: 'Rp ');

PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
  buildSignature: 'Unknown',
);


List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];

  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }

  return days;
}

int compareVersion(String v1, String v2) {
  List<String> _version1 = v1.split('.');
  List<String> _version2 = v2.split('.');
  int k = min(_version1.length, _version2.length);
  for (var i = 0; i < k; i++) {
    int _vers1 = int.parse(_version1[i], radix: 10);
    int _vers2 = int.parse(_version2[i], radix: 10);
    if (_vers1 > _vers2) return 1;
    if (_vers1 < _vers2) return -1;
  }
  return _version1.length == _version2.length ? 0 : (_version1.length < _version2.length ? -1 : 1);
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }

  return double.tryParse(s) != null;
}

Future<void> launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false, forceWebView: false);
  } else {
    throw 'Could not launch $url';
  }
}

dynamic getFilterRequest({
  Map<String, dynamic>? params,
  bool dateRange = true,
}) {
  filterValue = (params != null) ? params : {};

  String _start = (params != null && params.containsKey('Start'))
      ? params['Start']
      : today.subtract(Duration(days: 30, hours: 7)).toIso8601String();
  String _finish = (params != null && params.containsKey('Finish'))
      ? params['Finish']
      : today.subtract(Duration(hours: 7)).toIso8601String();

  String _auth = (appAuth.user != null && appAuth.user?.id != null)
      ? appAuth.user!.id!
      : '';
  
  String _odooId = (appAuth.user != null && appAuth.user?.odooId != null)
      ? appAuth.user!.odooId!
      : '';

  String _email = (appAuth.user != null && appAuth.user?.email != null)
      ? appAuth.user!.email!
      : '';

  String _user =
      (params != null && params.containsKey('User')) ? params['User'] : _auth;

  Map<String, dynamic> payload = {
    'Username': _user,
    'EmployeeID': _user,
    'Email': _email,
    'OdooID': _odooId,
    'Range': {
      'Start': _start,
      'Finish': _finish,
    }
  };

  if (!dateRange) {
    payload = {
      'UserName': _user,
      'EmployeeID': _user,
      'Start': _start,
      'Finish': _finish,
    };
  }

  if(params != null){
    if(params.containsKey('Offset')) payload['Offset'] = params['Offset'];
    if(params.containsKey('Limit')) payload['Limit'] = params['Limit'];
    if(params.containsKey('Filter')) payload['Filter'] = params['Filter'];
  }

  return payload;
}
