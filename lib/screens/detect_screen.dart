import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tensorflow_lite_flutter/helpers/app_helper.dart';
import 'package:tensorflow_lite_flutter/helpers/camera_helper.dart';
import 'package:tensorflow_lite_flutter/helpers/tflite_helper.dart';
import 'package:tensorflow_lite_flutter/models/result.dart';

class DetectScreen extends StatefulWidget {
  DetectScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DetectScreenPageState createState() => _DetectScreenPageState();
}

class _DetectScreenPageState extends State<DetectScreen>
    with TickerProviderStateMixin {

  List<Result> outputs;

  void initState() {
    super.initState();

    //Load TFLite Model
    TFLiteHelper.loadModel().then((value) {
      setState(() {
        TFLiteHelper.modelLoaded = true;
      });
    });

    //Initialize Camera
    CameraHelper.initializeCamera();

    TFLiteHelper.tfLiteResultsController.stream.listen((value) {
      outputs = value;

      //Update results on screen
      setState(() {
        //Set bit to false to allow detection again
        CameraHelper.isDetecting = false;
      });
    }, onDone: () {

    }, onError: (error) {
      AppHelper.log("listen", error);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraPreview(CameraHelper.camera),
                _buildResultsWidget(width, outputs)
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera.dispose();
    AppHelper.log("dispose", "Clear resources.");
    super.dispose();
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),

                      ],
                    );
                  })
              : Center(
                  child: Text("Wating for model to detect..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

}
