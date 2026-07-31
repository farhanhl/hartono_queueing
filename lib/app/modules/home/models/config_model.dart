class ConfigModel {
  String? timestamp;
  int? status;
  String? message;
  CondigResult? result;

  ConfigModel({this.timestamp, this.status, this.message, this.result});

  ConfigModel.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    status = json['status'];
    message = json['message'];
    result =
        json['result'] != null ? CondigResult.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }

  bool isEmpty() {
    return (timestamp == null || timestamp!.isEmpty) &&
        status == null &&
        (message == null || message!.isEmpty) &&
        (result == null || result!.isEmpty());
  }

  bool isNotEmpty() => !isEmpty();
}

class CondigResult {
  PusherConfig? pusher;
  String? url;

  CondigResult({this.pusher, this.url});

  CondigResult.fromJson(Map<String, dynamic> json) {
    pusher =
        json['pusher'] != null ? PusherConfig.fromJson(json['pusher']) : null;
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (pusher != null) {
      data['pusher'] = pusher!.toJson();
    }
    data['url'] = url;
    return data;
  }

  bool isEmpty() {
    return (url == null || url!.isEmpty) &&
        (pusher == null || pusher!.isEmpty());
  }

  bool isNotEmpty() => !isEmpty();
}

class PusherConfig {
  String? appId;
  String? appKey;
  String? appSecret;
  String? cluster;

  PusherConfig({this.appId, this.appKey, this.appSecret, this.cluster});

  PusherConfig.fromJson(Map<String, dynamic> json) {
    appId = json['app_id'];
    appKey = json['app_key'];
    appSecret = json['app_secret'];
    cluster = json['cluster'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['app_id'] = appId;
    data['app_key'] = appKey;
    data['app_secret'] = appSecret;
    data['cluster'] = cluster;
    return data;
  }

  bool isEmpty() {
    return (appId == null || appId!.isEmpty) &&
        (appKey == null || appKey!.isEmpty) &&
        (appSecret == null || appSecret!.isEmpty) &&
        (cluster == null || cluster!.isEmpty);
  }

  bool isNotEmpty() => !isEmpty();
}
