/// A text input field with a microphone button and an optional image button.
/// Allows users to input text, record audio, and attach images.
///
/// The [MicInputTextField] widget provides a text input field with a microphone button
/// and an optional image button. Users can type text, record audio, and attach images
/// to send as a message. The widget also provides functionality to pause, resume, and stop
/// audio recording, as well as remove the attached image.
///
/// Example usage:
/// ```dart
/// MicInputTextField(
///   onSend: (output) {
///     // Handle the output (audio, image, and message)
///   },
/// )
/// ```
library micinputtextfield;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:micinputtextfield/output.dart';
import 'package:record/record.dart';
import 'platform/audio_recorder_io.dart';
export 'output.dart';

class MicInputTextField extends StatefulWidget {
  /// A callback function that is called when the user sends a message.
  final Function(Output output) onSend;

  /// Creates a [MicInputTextField] widget.
  ///
  /// The [onSend] parameter is required and must be a function that takes an [Output]
  /// object as a parameter. This function will be called when the user sends a message.
  const MicInputTextField({
    Key? key,
    required this.onSend,
  }) : super(key: key);

  @override
  State<MicInputTextField> createState() => _MicTextFieldState();
}

class _MicTextFieldState extends State<MicInputTextField>
    with AudioRecorderMixin {
  final TextEditingController _textEditCont = TextEditingController();

  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRec;
  StreamSubscription<RecordState>? _rSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  bool _fieldDirty = false;
  File? _image;
  File? _audio;

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _stop() async {
    final path = await _audioRec.stop();

    if (path != null) {
      _audio = File(path);

      downloadWebData(path);
    }
  }

  void _upRecState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  @override
  void initState() {
    _audioRec = AudioRecorder();

    _rSub = _audioRec.onStateChanged().listen(
          (rS) => _upRecState(rS),
        );

    _amplitudeSub = _audioRec
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));

    _textEditCont.addListener(() {
      _textEditCont.text.isEmpty ? _fieldDirty = false : _fieldDirty = true;

      setState(() {});
    });

    super.initState();
  }

  Future<void> _pause() => _audioRec.pause();

  Future<void> _resume() => _audioRec.resume();

  @override
  void dispose() {
    _textEditCont.dispose();
    _timer?.cancel();
    _rSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRec.dispose();
    super.dispose();
  }

  _sendOut() {
    widget.onSend(Output(
      audio: _audio,
      image: _image,
      message: _textEditCont.text,
    ));
  }

  Future<void> send() async {
    if (!_fieldDirty && _image == null) {
    } else {
      _sendOut();
      return reset();
    }
    if (_recordState == RecordState.record) {
      await _pause();
      await _stop();
      _sendOut();
      return reset();
    }
  }

  void removeImage() {
    _image = null;
    setState(() {});
  }

  void reset() {
    _fieldDirty = false;
    _audio = null;
    _textEditCont.clear();
    removeImage();
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRec.isEncoderSupported(encoder);

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRec.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  Future onAudio() async {
    try {
      if (await _audioRec.hasPermission()) {
        if (_recordState == RecordState.record) {
          await _pause();
          await _stop();
          return;
        }
        const encoder = AudioEncoder.aacLc;

        if (!await _isEncoderSupported(encoder)) {
          return;
        }
        final devs = await _audioRec.listInputDevices();
        debugPrint(devs.toString());
        const config = RecordConfig(encoder: encoder, numChannels: 1);
        await recordFile(_audioRec, config);
        _recordDuration = 0;
        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void onImageClick() async {
    if (_image != null) {
      removeImage();
      return;
    }
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    //  logger.d(image.path);
    _image = File(image.path);
    _fieldDirty = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 50,
      // width: double.infinity,
      margin: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 25.0),
                  Expanded(
                    child: TextField(
                      controller: _textEditCont,
                      readOnly: _recordState == RecordState.record,
                      //    cursorHeight: 20.0,

                      decoration: InputDecoration(
                        hintText: _recordState == RecordState.record
                            ? " Recording... ${_recordDuration}s"
                            : " Type a message ",

                        border: InputBorder.none,

                        filled: false,
                        //contentPadding: EdgeInsets.only(bottom: 20.0),
                        prefixIcon: _recordState == RecordState.record
                            ? const Icon(Icons.mic, color: Colors.red)
                            : null,
                      ),
                    ),
                  ),
                  _recordState == RecordState.record
                      ? SizedBox(
                          width: 50.0,
                          height: 30.0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: onImageClick,
                          icon: _image != null
                              ? CircleAvatar(
                                  radius: 15.0,
                                  backgroundImage: FileImage(_image!),
                                )
                              : const Icon(Icons.camera_alt),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          ElevatedButton(
            onPressed: send,
            onLongPress: () => onAudio(),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10.0),
            ),
            child: Icon(!_fieldDirty
                ? (_recordState == RecordState.record)
                    ? Icons.stop
                    : Icons.mic
                : Icons.send),
          ),
        ],
      ),
    );
  }
}
