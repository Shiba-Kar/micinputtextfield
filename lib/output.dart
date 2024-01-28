import 'dart:io';

class Output {
  File? audio;
  File? image;
  String? message;

  Output({
    this.audio,
    this.image,
    this.message,
  });

  Output copyWith({
    File? audio,
    File? image,
    String? message,
  }) {
    return Output(
      audio: audio ?? this.audio,
      image: image ?? this.image,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audio': audio?.path,
      'image': image?.path,
      'message': message,
    };
  }
}
