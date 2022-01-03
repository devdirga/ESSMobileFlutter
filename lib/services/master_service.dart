import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/master_model.dart';

class MasterService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> gender() async {
    var _apiResponse = ApiResponse.loading('Fetching Gender');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetGender',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> religion() async {
    var _apiResponse = ApiResponse.loading('Fetching Religion');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetReligion',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> maritalStatus() async {
    var _apiResponse = ApiResponse.loading('Fetching Marital Status');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetMaritalStatus',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> documentType() async {
    var _apiResponse = ApiResponse.loading('Fetching Document Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetDocumentType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> documentRequestType() async {
    var _apiResponse = ApiResponse.loading('Fetching Document Request Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetDocumentRequestType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> city() async {
    var _apiResponse = ApiResponse.loading('Fetching City');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetCity',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<CityModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(CityModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> certificateType() async {
    var _apiResponse = ApiResponse.loading('Fetching Certificate Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetCertificateType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<CertificateTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(CertificateTypeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> familyRelationship() async {
    var _apiResponse = ApiResponse.loading('Fetching Family Relationship');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetFamilyRelationship',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<FamilyRelationshipModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(FamilyRelationshipModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> identificationType() async {
    var _apiResponse = ApiResponse.loading('Fetching Identification Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetIdentificationType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<IdentificationTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(IdentificationTypeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> electronicAddressType() async {
    var _apiResponse = ApiResponse.loading('Fetching Electronic Address Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetElectronicAddressType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<ElectronicAddressTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(ElectronicAddressTypeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelType() async {
    var _apiResponse = ApiResponse.loading('Fetching Travel Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/list/travelType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelStatus() async {
    var _apiResponse = ApiResponse.loading('Fetching Travel Status');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/list/travelStatus',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _res.data = List<String>.from(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelPurpose() async {
    var _apiResponse = ApiResponse.loading('Fetching Travel Purpose');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/list/purposes',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TravelPurposeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TravelPurposeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelTransportation() async {
    var _apiResponse = ApiResponse.loading('Fetching Travel Transportation');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/list/transportations',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TravelTransportationModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TravelTransportationModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> trainingType() async {
    var _apiResponse = ApiResponse.loading('Fetching Training Type');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/training/list/type',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TrainingTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TrainingTypeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> absenceCode() async {
    var _apiResponse = ApiResponse.loading('Fetching Absence Code');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/timemanagement/mgetabsencecode',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<AbsenceCodeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(AbsenceCodeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> ticketStatus() async {
    var _apiResponse = ApiResponse.loading('Fetching Ticket Status');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetTicketStatus',
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

  Future<ApiResponse> ticketMedia() async {
    var _apiResponse = ApiResponse.loading('Fetching Ticket Media');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetTicketMedia',
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

  Future<ApiResponse> ticketType() async {
    var _apiResponse = ApiResponse.loading('Fetching Ticket Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetTicketType',
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

  Future<String?> findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }
}
