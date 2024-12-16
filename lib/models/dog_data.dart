class Location {
  final String city;
  final String state;
  final String? postcode;

  Location({
    required this.city,
    required this.state,
    this.postcode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      if (postcode != null) 'postcode': postcode,
    };
  }
}

class DogData {
  final String name;
  final Location location;
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
      location: Location.fromJson(json['location']),
      age: json['age'],
      sex: json['sex'],
      breed: json['breed'],
      url: json['url'],
      photo: json['primary_photo'],
      croppedPhoto: json['primary_photo_cropped'],
      similarity: json['similarity'] != null ? (json['similarity'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location.toJson(),
      'age': age,
      'sex': sex,
      'breed': breed,
      'url': url,
      'primary_photo': photo,
      'primary_photo_cropped': croppedPhoto,
      if (similarity != null) 'similarity': similarity,
    };
  }

  // String get imageSource => photo ?? 'assets/images/carousel/$imageName.jpg';
}
