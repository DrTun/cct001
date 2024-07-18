

class NoteModel{
  String? syskey;
  String? title;
  String? description;
  int? priority;

  NoteModel({
    this.syskey="",
    this.title="",
    this.description="",
    this.priority=0
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    syskey: json['syskey'],
    title: json['title'],
    description: json['description'],
    priority: json['priority']
  );

  Map<String,dynamic> toJson() => {
    "syskey" : syskey,
    "title"  : title,
    "description" : description,
    "priority" : priority
  };
}