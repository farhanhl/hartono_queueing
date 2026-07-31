class MessageInfoDTO {
  Message? message;

  MessageInfoDTO({this.message});

  MessageInfoDTO.fromJson(Map<Object?, dynamic> json) {
    message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
  }

  Map<Object?, dynamic> toJson() {
    final data = <Object?, dynamic>{};
    if (message != null) {
      data['message'] = message?.toJson();
    }
    return data;
  }
}

class Message {
  String? id;
  String? customerId;
  String? agentId;
  String? supervisorId;
  String? code;
  String? queueNo;
  String? nextQueuedBy;
  String? queueStatus;
  String? queueUpdatedAt;
  String? branchId;
  String? boothId;
  String? complaintCategoryId;
  String? sessionAppName;
  String? sessionAppLink;
  Branch? branch;

  Message({
    this.id,
    this.customerId,
    this.agentId,
    this.supervisorId,
    this.code,
    this.queueNo,
    this.nextQueuedBy,
    this.queueStatus,
    this.queueUpdatedAt,
    this.branchId,
    this.boothId,
    this.complaintCategoryId,
    this.sessionAppName,
    this.sessionAppLink,
    this.branch,
  });

  Message.fromJson(Map<Object?, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    agentId = json['agent_id'];
    supervisorId = json['supervisor_id'];
    code = json['code'];
    queueNo = json['queue_no'];
    nextQueuedBy = json['next_queued_by'];
    queueStatus = json['queue_status'];
    queueUpdatedAt = json['queue_updated_at'];
    branchId = json['branch_id'];
    boothId = json['booth_id'];
    complaintCategoryId = json['complaint_category_id'];
    sessionAppName = json['session_app_name'];
    sessionAppLink = json['session_app_link'];
    branch = json['branch'] != null ? Branch?.fromJson(json['branch']) : null;
  }

  Map<Object?, dynamic> toJson() {
    final data = <Object?, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['agent_id'] = agentId;
    data['supervisor_id'] = supervisorId;
    data['code'] = code;
    data['queue_no'] = queueNo;
    data['next_queued_by'] = nextQueuedBy;
    data['queue_status'] = queueStatus;
    data['queue_updated_at'] = queueUpdatedAt;
    data['branch_id'] = branchId;
    data['booth_id'] = boothId;
    data['complaint_category_id'] = complaintCategoryId;
    data['session_app_name'] = sessionAppName;
    data['session_app_link'] = sessionAppLink;
    data['branch'] = branch;
    return data;
  }
}

class Branch {
  String? id;
  String? code;
  String? name;
  String? address;
  String? userId;

  Branch({
    this.id,
    this.code,
    this.name,
    this.address,
    this.userId,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    address = json['address'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['address'] = address;
    data['user_id'] = userId;
    return data;
  }
}
