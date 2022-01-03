import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ess_mobile/utils/api_exceptions.dart';

class RestApi {
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    // print('Api Get, url $url');
    var responseJson;

    try {
      final response = await http.get(
        Uri.parse('$url'),
        headers: headers,
      );
      responseJson = _responseBody(response);
    } on SocketException {
      // print('No Internet Connection');
      throw FetchDataException('No Internet Connection');
    }

    // print('Data retrieved.');
    return responseJson;
  }

  Future<dynamic> post(String url,
      {dynamic body, Map<String, String>? headers}) async {
    // print('Api Post, url $url');
    var responseJson;
    print(headers);
    try {
      final response = await http.post(
        Uri.parse('$url'),
        headers: headers,
        body: body,
      );
      responseJson = _responseBody(response);
    } on SocketException {
      // print('No Internet Connection');
      throw FetchDataException('No Internet Connection');
    }

    // print('Data sent.');
    return responseJson;
  }

  Future<dynamic> put(String url,
      {Map<String, String>? headers, dynamic body}) async {
    // print('Api Put, url $url');
    var responseJson;

    try {
      final response = await http.put(
        Uri.parse('$url'),
        headers: headers,
        body: body,
      );
      responseJson = _responseBody(response);
    } on SocketException {
      // print('No Internet Connection');
      throw FetchDataException('No Internet Connection');
    }

    // print('Data updated.');
    return responseJson;
  }

  Future<dynamic> delete(String url,
      {Map<String, String>? headers, dynamic body}) async {
    // print('Api Delete, url $url');
    var responseJson;

    try {
      final response = await http.delete(
        Uri.parse('$url'),
        headers: headers,
        body: body,
      );
      responseJson = _responseBody(response);
    } on SocketException {
      // print('No Internet Connection');
      throw FetchDataException('No Internet Connection');
    }

    // print('Data deleted.');
    return responseJson;
  }

  dynamic _responseBody(http.Response response) {
    String _body = response.body.toString();

    switch (response.statusCode) {
      case 200:
      case 201:
        if (_body.length > 0 && _body.substring(0, 1) == '[') {
          return json.decode(_body) as List<dynamic>;
        }

        if (_body.length > 0 && int.tryParse(_body.substring(0, 1)) != null) {
          return {'result': _body};
        }

        return json.decode(_body) as Map<String, dynamic>;
      case 400:
        try {
          return json.decode(_body) as Map<String, dynamic>;
        } on FormatException catch (e) {
          print(e);
          throw BadRequestException(_body);
        }
      case 401:
      case 403:
        try {
          return json.decode(_body) as Map<String, dynamic>;
        } on FormatException catch (e) {
          print(e);
          throw UnauthorisedException(_body);
        }
      case 500:
      default:
        try {
          return json.decode(_body) as Map<String, dynamic>;
        } on FormatException catch (e) {
          print(e);
          throw FetchDataException(
            'An error occurred while communicating with the server. StatusCode : ${response.statusCode}',
          );
        }
    }
  }
}
