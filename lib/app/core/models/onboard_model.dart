class SliderModel {
  final String title;
  final String description;
  final String image;

  SliderModel({
    required this.title,
    required this.description,
    required this.image,
  });

  factory SliderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SliderModel(
        title: '',
        description: '',
        image: '',
      );
    }
    return SliderModel(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
    };
  }
}