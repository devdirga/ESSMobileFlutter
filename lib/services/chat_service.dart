import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/chat_model.dart';

class ChatService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;

  Future<ApiResponse> author(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Author');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/author',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<AuthorModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(AuthorModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> authorCreate(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Creating Author');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/author/create',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> message(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Messages');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/get',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<MessageModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(MessageModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> messageSend(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Sending Messages');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/send',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> messageRead(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Reading Messages');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/read',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> messageUnread(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Unreading Messages');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/unread',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      _res.data = response['Data'];
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> notifySend(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Sending Notifications');

    try {
      final response = await _restApi.post(
        '${globals.fcmUrl}',
        body: JsonEncoder().convert(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${globals.fcmServerKey}',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> uploadFile(PlatformFile file) async {
    var _apiResponse = ApiResponse.loading('Uploading Files');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${globals.apiUrl}/chat/send/file'),
      );
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile(
        'fileChat',
        file.readStream!,
        file.size,
        filename: file.name,
      ));

      final response = await request.send();
      String stream = await response.stream.bytesToString();

      _apiResponse = ApiResponse.completed(json.decode(stream));
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> uploadImage(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Uploading Images');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/chat/send/image',
        body: body,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
