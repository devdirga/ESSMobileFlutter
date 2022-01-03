import 'package:ess_mobile/models/datetime_model.dart';
class SurveyModel {
  String? id;
  String? odooID;
  String? title;
  String? description;
  DateTimeModel? schedule;
  int? recurrent;
  bool? mandatory;
  int? participantType;
  List<String>? participants;
  String? department;
  List<String>? departments;
  bool? published;
  String? surveyUrl;
  String? reviewUrl;  
  String? lastUpdate;
  String? updateBy;
  String? createdDate;
  String? createdBy;
  bool? alreadyFilled;
  bool? isRequired;

  SurveyModel({
    this.id,
    this.odooID,
    this.title,
    this.description,
    this.schedule,
    this.recurrent,
    this.mandatory,
    this.participantType,
    this.participants,
    this.department,
    this.departments,
    this.published,
    this.surveyUrl,
    this.reviewUrl,
    this.lastUpdate,
    this.updateBy,
    this.createdDate,
    this.createdBy,
    this.alreadyFilled,
    this.isRequired
  });

  SurveyModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    odooID = json['OdooId'];
    title = json['Title'];
    description = json['Description'];
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
    recurrent = json['Recurrent'];
    mandatory = json['Mandatory'];
    participantType = json['ParticipantType'];
    participants = json['Participants'] != null 
      ? [...json['Participants']]
      : null;
    department = json['Department'];
    departments = json['Departments'] != null 
      ? [...json['Departments']]
      : null;
    published = json['Published'];
    surveyUrl = json['SurveyUrl'];
    reviewUrl = json['ReviewUrl'];
    createdDate = json['CreatedDate'];
    createdBy = json['CreatedBy'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
    alreadyFilled = json['AlreadyFilled'];
    isRequired = json['IsRequired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['OdooId'] = this.odooID;
    data['Title'] = this.title;
    data['Description'] = this.description;
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    data['Recurrent'] = this.recurrent;
    data['Mandatory'] = this.mandatory;
    data['ParticipantType'] = this.mandatory;
    if (this.participants != null) {
      data['Participants'] = this.participants;
    }
    data['Department'] = this.department;
    if (this.departments != null) {
      data['Departments'] = this.departments;
    }
    data['Published'] = this.published;
    data['SurveyUrl'] = this.surveyUrl;
    data['ReviewUrl'] = this.reviewUrl;
    data['CreatedDate'] = this.createdDate;
    data['CreatedBy'] = this.createdBy;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    data['AlreadyFilled'] = this.alreadyFilled;
    data['IsRequired'] = this.isRequired;
    return data;
  }
}

class SurveyHistoryModel{
  int? id;
  List<dynamic>? surveyId;
  String? createDate;
  String? userId;
  String? userName;
  String? department;
  String? mailId;
  String? state;
  String? scoringType;
  double? quizzScore;
  String? passedCategory;
  String? passingGradeCategory;

  SurveyHistoryModel({
    this.id,
    this.surveyId,
    this.createDate,
    this.userId,
    this.userName,
    this.department,
    this.mailId,
    this.state,
    this.scoringType,
    this.quizzScore,
    this.passedCategory,
    this.passingGradeCategory
  });

  SurveyHistoryModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    surveyId = json['survey_id'] != null 
      ? [...json['survey_id']]
      : null;
    createDate = json['create_date'];
    userId = json['user_id'];
    userName = json['user_name'];
    department = json['department'];
    mailId = json['mail_id'];
    state = json['state'];
    scoringType = json['scoring_type'];
    quizzScore = json['quizz_score'];
    passedCategory = json['passed_category'];
    passingGradeCategory = json['passing_grade_category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['survey_id'] = this.surveyId;
    data['create_date'] = this.createDate;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['department'] = this.department;
    data['mail_id'] = this.mailId;
    data['state'] = this.state;
    data['scoring_type'] = this.scoringType;
    data['quizz_score'] = this.quizzScore;
    data['passed_category'] = this.passedCategory;
    data['passing_grade_category'] = this.passingGradeCategory;
    return data;
  }
}
