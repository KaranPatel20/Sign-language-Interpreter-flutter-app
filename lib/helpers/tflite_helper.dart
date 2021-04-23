import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tensorflow_lite_flutter/models/result.dart';
import 'package:tflite/tflite.dart';

import 'app_helper.dart';

class TFLiteHelper {

  static StreamController<List<Result>> tfLiteResultsController = new StreamController.broadcast();
  static List<Result> _outputs = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async{
    AppHelper.log("loadModel", "Loading model..");

    return Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.txt",
    );
  }

  static classifyImage(CameraImage image) async {

    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            numResults: 5)
        .then((value) {
      if (value.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['label']));

          AppHelper.log("classifyImage",
              "${element['label']}");
        });
      }

      //Sort results according to most confidenc

      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel(){
    Tflite.close();
    tfLiteResultsController.close();
  }
}
