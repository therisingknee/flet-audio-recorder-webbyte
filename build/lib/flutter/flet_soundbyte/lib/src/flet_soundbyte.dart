// import 'dart:async';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'dart:js_util' as js_util;
// import 'package:flutter/material.dart';
// import 'package:flet/flet.dart';
// import 'dart:convert';
//
// class SoundbyteControl extends StatefulWidget {
//   final Control? parent;
//   final Control control;
//
//   const SoundbyteControl({
//     super.key,
//     required this.parent,
//     required this.control,
//   });
//
//   @override
//   State<SoundbyteControl> createState() => _SoundbyteControlState();
// }
//
// class _SoundbyteControlState extends State<SoundbyteControl> {
//   dynamic _mediaRecorder;
//   List<Uint8List> _chunks = [];
//   List<int> _audioBytes = [];
//   bool _isRecording = false;
//   late html.MediaStream _stream;
//
//   Future<void> _startRecording() async {
//     _stream = await html.window.navigator.getUserMedia(audio: true);
//     final recorder = js_util.callConstructor(
//       js_util.getProperty(html.window, 'MediaRecorder'),
//       [_stream],
//     );
//
//     _chunks.clear();
//
//     html.EventStreamProvider<html.Event>('dataavailable')
//         .forTarget(recorder)
//         .listen((event) async {
//       final blob = js_util.getProperty(event, 'data');
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(blob);
//       await reader.onLoad.first;
//
//       final result = reader.result;
//       late Uint8List chunk;
//
//       if (result is ByteBuffer) {
//         chunk = Uint8List.view(result);
//       } else if (result is Uint8List) {
//         chunk = result;
//       } else {
//         print('Unexpected reader.result type: ${result.runtimeType}');
//         return;
//       }
//
//       _chunks.add(chunk);
//       print('Received audio chunk: ${chunk.length} bytes');
//       print('Preview: ${chunk.take(10).toList()}');
//     });
//
//     html.EventStreamProvider<html.Event>('stop')
//         .forTarget(recorder)
//         .listen((_) {
//         final allBytes = _chunks.expand((x) => x).toList();
//         final base64Audio = base64Encode(allBytes);
//
//       setState(() {
//         _audioBytes = allBytes;
//         _isRecording = false;
//       });
//
//       _stream.getTracks().forEach((track) => track.stop());
//       print("Audio as Base64 string (first 100 chars): ${base64Audio}");
//       widget.control.dispatchEvent("audio_recorded", base64Audio);
//
//     });
//
//     js_util.callMethod(recorder, 'start', []);
//     setState(() {
//       _mediaRecorder = recorder;
//       _audioBytes.clear();
//       _isRecording = true;
//     });
//   }
//
//   void _stopRecording() {
//     if (_mediaRecorder != null) {
//       js_util.callMethod(_mediaRecorder, 'stop', []);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return constrainedControl(
//       context,
//       ElevatedButton.icon(
//         onPressed: _isRecording ? _stopRecording : _startRecording,
//         icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//         label: Text(_isRecording ? "Stop Recording" : "Start Recording"),
//       ),
//       widget.parent,
//       widget.control,
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:flet/flet.dart';

class SoundbyteControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const SoundbyteControl({
    super.key,
    required this.parent,
    required this.control,
    required this.backend,
  });

  @override
  State<SoundbyteControl> createState() => _SoundbyteControlState();
}

class _SoundbyteControlState extends State<SoundbyteControl> {
  dynamic _mediaRecorder;
  List<Uint8List> _chunks = [];
  List<int> _audioBytes = [];
  bool _isRecording = false;
  late html.MediaStream _stream;

  Future<void> _startRecording() async {
  final mediaDevices = html.window.navigator.mediaDevices;

  if (mediaDevices == null) {
    throw Exception("⚠️ mediaDevices is not available in this browser.");
  }

  _stream = await mediaDevices.getUserMedia({'audio': true});
  final recorder = js_util.callConstructor(
    js_util.getProperty(html.window, 'MediaRecorder'),
    [_stream],
  );

  _chunks.clear();

  html.EventStreamProvider<html.Event>('dataavailable')
      .forTarget(recorder)
      .listen((event) async {
    final blob = js_util.getProperty(event, 'data');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    await reader.onLoad.first;

    final result = reader.result;
    late Uint8List chunk;

    if (result is ByteBuffer) {
      chunk = Uint8List.view(result);
    } else if (result is Uint8List) {
      chunk = result;
    } else {
      print('❌ Unexpected reader.result type: ${result.runtimeType}');
      return;
    }

    _chunks.add(chunk);
    print('📥 Received audio chunk: ${chunk.length} bytes');
  });

  html.EventStreamProvider<html.Event>('stop')
      .forTarget(recorder)
      .listen((_) {
    final allBytes = _chunks.expand((x) => x).toList();
    print("🧪 Final audio byte length: ${allBytes.length}");

    if (allBytes.isEmpty) {
      print("❌ No audio captured. Skipping event.");
      return;
    }

    final base64Audio = base64Encode(allBytes);
    print("✅ Encoded base64 length: ${base64Audio.length}");

    setState(() {
      _audioBytes = allBytes;
      _isRecording = false;
    });

    _stream.getTracks().forEach((track) => track.stop());

    widget.backend.triggerControlEvent(
      widget.control.id,
      "audio_recorded",
      base64Audio,
    );
  });

  js_util.callMethod(recorder, 'start', []);
  setState(() {
    _mediaRecorder = recorder;
    _audioBytes.clear();
    _isRecording = true;
  });
}


  void _stopRecording() async {
    if (_mediaRecorder != null) {
      final state = js_util.getProperty(_mediaRecorder, 'state');
      if (state == 'recording') {
        print("🛑 Stopping recording... requesting final chunk...");
        js_util.callMethod(_mediaRecorder, 'requestData', []);

        // 💡 Give the browser time to flush final data
        await Future.delayed(Duration(milliseconds: 300));

        js_util.callMethod(_mediaRecorder, 'stop', []);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return constrainedControl(
      context,
      ElevatedButton.icon(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: Text(_isRecording ? "Stop Recording" : "Start Recording"),
      ),
      widget.parent,
      widget.control,
    );
  }
}
