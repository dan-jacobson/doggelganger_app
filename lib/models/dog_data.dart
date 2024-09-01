class DogData {
  final String name;
  final String fullName;
  final String location;
  final String imageName;
  final String age;
  final String sex;
  final String breed;
  final String distance;
  final String adoptionLink;

  DogData({
    required this.name,
    required this.fullName,
    required this.location,
    required this.imageName,
    required this.age,
    required this.sex,
    required this.breed,
    required this.distance,
    required this.adoptionLink,
  });

  factory DogData.fromJson(Map<String, dynamic> json) {
    return DogData(
      name: json['name'],
      fullName: json['full_name'],
      location: json['location'],
      imageName: json['local_image'].replaceAll('.jpg', ''),
      age: json['age'],
      sex: json['sex'],
      breed: json['breed'],
      distance: json['distance'],
      adoptionLink: json['adoption_link'],
    );
  }
}
