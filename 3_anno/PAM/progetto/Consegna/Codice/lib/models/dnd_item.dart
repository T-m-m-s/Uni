class DndItem {
  String name;
  String desc;

  DndItem({required this.name, this.desc = ''});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
    };
  }

  factory DndItem.fromJson(dynamic json) {
    if (json is String) return DndItem(name: json);
    if (json is Map<String, dynamic>) {
      return DndItem(
        name: json['name'] ?? '',
        desc: json['desc'] ?? '',
      );
    }
    return DndItem(name: 'Unknown Item');
  }
}
