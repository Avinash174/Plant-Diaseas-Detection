import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/model/plant_disease.tflite',
    );
  }

  List<double> predict(File imageFile) {
    final Float32List input = _imageToTensor(imageFile);

    final output = List.filled(1 * 5, 0.0).reshape([1, 5]);

    _interpreter.run(input.reshape([1, 224, 224, 3]), output);

    return output[0];
  }

  /// Converts image to Float32List (image ^4.x compatible)
  Float32List _imageToTensor(File file) {
    final image = img.decodeImage(file.readAsBytesSync())!;
    final resized = img.copyResize(image, width: 224, height: 224);

    final Float32List buffer = Float32List(224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);

        buffer[index++] = pixel.r / 255.0;
        buffer[index++] = pixel.g / 255.0;
        buffer[index++] = pixel.b / 255.0;
      }
    }

    return buffer;
  }
}
