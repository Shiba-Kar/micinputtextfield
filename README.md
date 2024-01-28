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

```dart

import 'package:micinputtextfield/mic_input_textfield.dart';

MicInputTextField(
            onSend: (ou) async {
              log("OnSend");
             
              log(noofincrement.toString());
            },
          )

```

