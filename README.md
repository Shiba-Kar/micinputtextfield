# Mic Input Textfield

This package provides with image , text and audio input similar to whattsapp textfield.

## Installation

To use this package, add `micinputtextfield` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

![Demo](./ui.png)
![Demo Vedio](./ui.gif)

```yaml
dependencies:
  micinputtextfield: ^version_number
```

# Android

```xml

<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_INTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />

```

# iOS

```xml

<key>NSPhotoLibraryUsageDescription</key>
<string>Save video in gallery</string>
<key>NSMicrophoneUsageDescription</key>
<string>Save audio in video</string>

```

```dart

import 'package:micinputtextfield/mic_input_textfield.dart';

 MicInputTextField(onSend: (output) async{
      log(noofincrement.toString());
      await Future.delayed(Duration(seconds: 10));
      return true;
          },),

```
