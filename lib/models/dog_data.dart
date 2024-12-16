class DogData {
  final String name;
  final Map location;
  final String age;
  final String sex;
  final String breed;
  final String url;
  final String photo;
  final String croppedPhoto;
  final double? similarity;

  DogData({
    required this.name,
    required this.location,
    required this.age,
    required this.sex,
    required this.breed,
    required this.url,
    required this.photo,
    required this.croppedPhoto,
    this.similarity,
  });

  factory DogData.fromJson(Map<String, dynamic> json) {
    return DogData(
      name: json['name'],
      location: json['location'],
      age: json['age'],
      sex: json['sex'],
      breed: json['breed'],
      url: json['url'],
      photo: json['primary_photo'],
      croppedPhoto: json['primary_photo_cropped'],
      similarity: json['similarity'] != null ? (json['similarity'] as num).toDouble() : null,
    );
  }

  // String get imageSource => photo ?? 'assets/images/carousel/$imageName.jpg';
}
