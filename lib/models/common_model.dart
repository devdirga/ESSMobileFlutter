class TaskModel {
  bool? actionApprove;
  bool? actionCancel;
  String? title;
  String? comment;
  String? reason;
  String? actionDateTime;
  bool? actionDelegate;
  String? actionDelegateToEmployeeID;
  String? actionDelegateToEmployeeName;
  bool? actionReject;
  bool? assignApprove;
  bool? assignCancel;
  bool? assignDelegate;
  bool? assignReject;
  int? assignType;
  String? assignTypeDescription;
  int? sequence;
  Null colorGroup;
  int? stepTrackingType;
  String? stepTrackingTypeDescription;
  String? assignToEmployeeID;
  String? assignToEmployeeName;
  int? requestType;
  String? requestTypeDescription;
  int? taskType;
  int? trackingStatus;
  String? trackingStatusDescription;
  String? instanceId;
  String? submitEmployeeID;
  String? submitEmployeeName;
  String? submitDateTime;
  int? axid;
  String? workflowId;
  int? workflowType;
  String? workflowTypeDescription;
  bool? inverted;

  TaskModel({
    this.actionApprove,
    this.actionCancel,
    this.title,
    this.comment,
    this.reason,
    this.actionDateTime,
    this.actionDelegate,
    this.actionDelegateToEmployeeID,
    this.actionDelegateToEmployeeName,
    this.actionReject,
    this.assignApprove,
    this.assignCancel,
    this.assignDelegate,
    this.assignReject,
    this.assignType,
    this.assignTypeDescription,
    this.sequence,
    this.colorGroup,
    this.stepTrackingType,
    this.stepTrackingTypeDescription,
    this.assignToEmployeeID,
    this.assignToEmployeeName,
    this.requestType,
    this.requestTypeDescription,
    this.taskType,
    this.trackingStatus,
    this.trackingStatusDescription,
    this.instanceId,
    this.submitEmployeeID,
    this.submitEmployeeName,
    this.submitDateTime,
    this.axid,
    this.workflowId,
    this.workflowType,
    this.workflowTypeDescription,
    this.inverted,
  });

  TaskModel.fromJson(Map<String, dynamic> json) {
    actionApprove = json['ActionApprove'];
    actionCancel = json['ActionCancel'];
    title = json['Title'];
    comment = json['Comment'];
    reason = json['Reason'];
    actionDateTime = json['ActionDateTime'];
    actionDelegate = json['ActionDelegate'];
    actionDelegateToEmployeeID = json['ActionDelegateToEmployeeID'];
    actionDelegateToEmployeeName = json['ActionDelegateToEmployeeName'];
    actionReject = json['ActionReject'];
    assignApprove = json['AssignApprove'];
    assignCancel = json['AssignCancel'];
    assignDelegate = json['AssignDelegate'];
    assignReject = json['AssignReject'];
    assignType = json['AssignType'];
    assignTypeDescription = json['AssignTypeDescription'];
    sequence = json['Sequence'];
    colorGroup = json['ColorGroup'];
    stepTrackingType = json['StepTrackingType'];
    stepTrackingTypeDescription = json['StepTrackingTypeDescription'];
    assignToEmployeeID = json['AssignToEmployeeID'];
    assignToEmployeeName = json['AssignToEmployeeName'];
    requestType = json['RequestType'];
    requestTypeDescription = json['RequestTypeDescription'];
    taskType = json['TaskType'];
    trackingStatus = json['TrackingStatus'];
    trackingStatusDescription = json['TrackingStatusDescription'];
    instanceId = json['InstanceId'];
    submitEmployeeID = json['SubmitEmployeeID'];
    submitEmployeeName = json['SubmitEmployeeName'];
    submitDateTime = json['SubmitDateTime'];
    axid = json['AXID'];
    workflowId = json['WorkflowId'];
    workflowType = json['WorkflowType'];
    workflowTypeDescription = json['WorkflowTypeDescription'];
    inverted = json['Inverted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ActionApprove'] = this.actionApprove;
    data['ActionCancel'] = this.actionCancel;
    data['Title'] = this.title;
    data['Comment'] = this.comment;
    data['Reason'] = this.reason;
    data['ActionDateTime'] = this.actionDateTime;
    data['ActionDelegate'] = this.actionDelegate;
    data['ActionDelegateToEmployeeID'] = this.actionDelegateToEmployeeID;
    data['ActionDelegateToEmployeeName'] = this.actionDelegateToEmployeeName;
    data['ActionReject'] = this.actionReject;
    data['AssignApprove'] = this.assignApprove;
    data['AssignCancel'] = this.assignCancel;
    data['AssignDelegate'] = this.assignDelegate;
    data['AssignReject'] = this.assignReject;
    data['AssignType'] = this.assignType;
    data['AssignTypeDescription'] = this.assignTypeDescription;
    data['Sequence'] = this.sequence;
    data['ColorGroup'] = this.colorGroup;
    data['StepTrackingType'] = this.stepTrackingType;
    data['StepTrackingTypeDescription'] = this.stepTrackingTypeDescription;
    data['AssignToEmployeeID'] = this.assignToEmployeeID;
    data['AssignToEmployeeName'] = this.assignToEmployeeName;
    data['RequestType'] = this.requestType;
    data['RequestTypeDescription'] = this.requestTypeDescription;
    data['TaskType'] = this.taskType;
    data['TrackingStatus'] = this.trackingStatus;
    data['TrackingStatusDescription'] = this.trackingStatusDescription;
    data['InstanceId'] = this.instanceId;
    data['SubmitEmployeeID'] = this.submitEmployeeID;
    data['SubmitEmployeeName'] = this.submitEmployeeName;
    data['SubmitDateTime'] = this.submitDateTime;
    data['AXID'] = this.axid;
    data['WorkflowId'] = this.workflowId;
    data['WorkflowType'] = this.workflowType;
    data['WorkflowTypeDescription'] = this.workflowTypeDescription;
    data['Inverted'] = this.inverted;
    return data;
  }
}

class UpdateRequestModel {
  String? title;
  String? lastUpdated;
  String? instanceID;
  String? submitByEmployeID;
  String? submitByEmployeeName;
  String? submitDateTime;
  int? trackingStatus;
  String? trackingStatusDescription;
  int? workflowType;
  bool? inverted;
  String? workflowTypeDescription;
  String? workflowId;
  Null data;
  List<WorkFlowModel>? workFlows;

  UpdateRequestModel({
    this.title,
    this.lastUpdated,
    this.instanceID,
    this.submitByEmployeID,
    this.submitByEmployeeName,
    this.submitDateTime,
    this.trackingStatus,
    this.trackingStatusDescription,
    this.workflowType,
    this.inverted,
    this.workflowTypeDescription,
    this.workflowId,
    this.data,
    this.workFlows,
  });

  UpdateRequestModel.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    lastUpdated = json['LastUpdated'];
    instanceID = json['InstanceID'];
    submitByEmployeID = json['SubmitByEmployeID'];
    submitByEmployeeName = json['SubmitByEmployeeName'];
    submitDateTime = json['SubmitDateTime'];
    trackingStatus = json['TrackingStatus'];
    trackingStatusDescription = json['TrackingStatusDescription'];
    workflowType = json['WorkflowType'];
    inverted = json['Inverted'];
    workflowTypeDescription = json['WorkflowTypeDescription'];
    workflowId = json['WorkflowId'];
    data = json['Data'];
    if (json['WorkFlows'] != null) {
      workFlows = <WorkFlowModel>[];
      json['WorkFlows'].forEach((v) {
        workFlows?.add(new WorkFlowModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['LastUpdated'] = this.lastUpdated;
    data['InstanceID'] = this.instanceID;
    data['SubmitByEmployeID'] = this.submitByEmployeID;
    data['SubmitByEmployeeName'] = this.submitByEmployeeName;
    data['SubmitDateTime'] = this.submitDateTime;
    data['TrackingStatus'] = this.trackingStatus;
    data['TrackingStatusDescription'] = this.trackingStatusDescription;
    data['WorkflowType'] = this.workflowType;
    data['Inverted'] = this.inverted;
    data['WorkflowTypeDescription'] = this.workflowTypeDescription;
    data['WorkflowId'] = this.workflowId;
    data['Data'] = this.data;
    if (this.workFlows != null) {
      data['WorkFlows'] = this.workFlows?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WorkFlowModel {
  bool? actionApprove;
  bool? actionCancel;
  bool? actionDelegate;
  bool? actionReject;
  String? comment;
  String? actionDateTime;
  String? delegateToEmployeeID;
  String? delegateToEmployeeName;
  String? assignToEmployeeID;
  String? assignToEmployeeName;
  int? assignType;
  String? completeDateTime;
  String? instanceID;
  int? requestType;
  String? requestTypeDescription;
  String? stepCompletionDateTime;
  int? stepCompletionPolicy;
  String? stepCompletionPolicyDescription;
  String? stepName;
  int? stepSequence;
  int? stepTrackingType;
  String? stepTrackingTypeDescription;
  String? submitByEmployeID;
  String? submitByEmployeeName;
  String? submitDateTime;
  int? trackingStatus;
  String? trackingStatusDescription;
  int? workflowType;
  String? workflowTypeDescription;
  String? workflowId;

  WorkFlowModel({
    this.actionApprove,
    this.actionCancel,
    this.actionDelegate,
    this.actionReject,
    this.comment,
    this.actionDateTime,
    this.delegateToEmployeeID,
    this.delegateToEmployeeName,
    this.assignToEmployeeID,
    this.assignToEmployeeName,
    this.assignType,
    this.completeDateTime,
    this.instanceID,
    this.requestType,
    this.requestTypeDescription,
    this.stepCompletionDateTime,
    this.stepCompletionPolicy,
    this.stepCompletionPolicyDescription,
    this.stepName,
    this.stepSequence,
    this.stepTrackingType,
    this.stepTrackingTypeDescription,
    this.submitByEmployeID,
    this.submitByEmployeeName,
    this.submitDateTime,
    this.trackingStatus,
    this.trackingStatusDescription,
    this.workflowType,
    this.workflowTypeDescription,
    this.workflowId,
  });

  WorkFlowModel.fromJson(Map<String, dynamic> json) {
    actionApprove = json['ActionApprove'];
    actionCancel = json['ActionCancel'];
    actionDelegate = json['ActionDelegate'];
    actionReject = json['ActionReject'];
    comment = json['Comment'];
    actionDateTime = json['ActionDateTime'];
    delegateToEmployeeID = json['DelegateToEmployeeID'];
    delegateToEmployeeName = json['DelegateToEmployeeName'];
    assignToEmployeeID = json['AssignToEmployeeID'];
    assignToEmployeeName = json['AssignToEmployeeName'];
    assignType = json['AssignType'];
    completeDateTime = json['CompleteDateTime'];
    instanceID = json['InstanceID'];
    requestType = json['RequestType'];
    requestTypeDescription = json['RequestTypeDescription'];
    stepCompletionDateTime = json['StepCompletionDateTime'];
    stepCompletionPolicy = json['StepCompletionPolicy'];
    stepCompletionPolicyDescription = json['StepCompletionPolicyDescription'];
    stepName = json['StepName'];
    stepSequence = json['StepSequence'];
    stepTrackingType = json['StepTrackingType'];
    stepTrackingTypeDescription = json['StepTrackingTypeDescription'];
    submitByEmployeID = json['SubmitByEmployeID'];
    submitByEmployeeName = json['SubmitByEmployeeName'];
    submitDateTime = json['SubmitDateTime'];
    trackingStatus = json['TrackingStatus'];
    trackingStatusDescription = json['TrackingStatusDescription'];
    workflowType = json['WorkflowType'];
    workflowTypeDescription = json['WorkflowTypeDescription'];
    workflowId = json['WorkflowId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ActionApprove'] = this.actionApprove;
    data['ActionCancel'] = this.actionCancel;
    data['ActionDelegate'] = this.actionDelegate;
    data['ActionReject'] = this.actionReject;
    data['Comment'] = this.comment;
    data['ActionDateTime'] = this.actionDateTime;
    data['DelegateToEmployeeID'] = this.delegateToEmployeeID;
    data['DelegateToEmployeeName'] = this.delegateToEmployeeName;
    data['AssignToEmployeeID'] = this.assignToEmployeeID;
    data['AssignToEmployeeName'] = this.assignToEmployeeName;
    data['AssignType'] = this.assignType;
    data['CompleteDateTime'] = this.completeDateTime;
    data['InstanceID'] = this.instanceID;
    data['RequestType'] = this.requestType;
    data['RequestTypeDescription'] = this.requestTypeDescription;
    data['StepCompletionDateTime'] = this.stepCompletionDateTime;
    data['StepCompletionPolicy'] = this.stepCompletionPolicy;
    data['StepCompletionPolicyDescription'] =
        this.stepCompletionPolicyDescription;
    data['StepName'] = this.stepName;
    data['StepSequence'] = this.stepSequence;
    data['StepTrackingType'] = this.stepTrackingType;
    data['StepTrackingTypeDescription'] = this.stepTrackingTypeDescription;
    data['SubmitByEmployeID'] = this.submitByEmployeID;
    data['SubmitByEmployeeName'] = this.submitByEmployeeName;
    data['SubmitDateTime'] = this.submitDateTime;
    data['TrackingStatus'] = this.trackingStatus;
    data['TrackingStatusDescription'] = this.trackingStatusDescription;
    data['WorkflowType'] = this.workflowType;
    data['WorkflowTypeDescription'] = this.workflowTypeDescription;
    data['WorkflowId'] = this.workflowId;
    return data;
  }
}
