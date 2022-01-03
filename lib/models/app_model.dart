class AppModel {
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  dynamic platform;

  AppModel({
    this.appName,
    this.packageName,
    this.version,
    this.buildNumber,
    this.platform,
  });

  AppModel.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    packageName = json['packageName'];
    version = json['version'];
    buildNumber = json['buildNumber'];
    platform = json['platform'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appName'] = this.appName;
    data['packageName'] = this.packageName;
    data['version'] = this.version;
    data['buildNumber'] = this.buildNumber;
    data['platform'] = this.platform;
    return data;
  }
}
