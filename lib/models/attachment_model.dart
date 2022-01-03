class AttachmentModel {
  int? axid;
  String? oldData;
  String? newData;
  String? notes;
  String? filepath;
  String? filehash;
  String? filename;
  String? fileext;
  String? pathUrl;
  String? checksum;
  bool? accessible;

  AttachmentModel({
    this.axid,
    this.oldData,
    this.newData,
    this.notes,
    this.filepath,
    this.filehash,
    this.filename,
    this.fileext,
    this.pathUrl,
    this.checksum,
    this.accessible,
  });

  AttachmentModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    oldData = json['OldData'];
    newData = json['NewData'];
    notes = json['Notes'];
    filepath = json['Filepath'];
    filehash = json['Filehash'];
    filename = json['Filename'];
    fileext = json['Fileext'];
    pathUrl = json['PathUrl'];
    checksum = json['Checksum'];
    accessible = json['Accessible'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['OldData'] = this.oldData;
    data['NewData'] = this.newData;
    data['Notes'] = this.notes;
    data['Filepath'] = this.filepath;
    data['Filehash'] = this.filehash;
    data['Filename'] = this.filename;
    data['Fileext'] = this.fileext;
    data['PathUrl'] = this.pathUrl;
    data['Checksum'] = this.checksum;
    data['Accessible'] = this.accessible;
    return data;
  }
}
