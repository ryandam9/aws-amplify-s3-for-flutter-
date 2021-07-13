import 'dart:io';

import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aws_s3/providers/s3_handler.dart';
import 'package:flutter_aws_s3/widgets/app_drawer.dart';

class SelectImage extends StatefulWidget {
  const SelectImage({Key? key}) : super(key: key);

  @override
  _SelectImageState createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _fileName;
  List<PlatformFile>? _paths;
  String? _bucketObjectName;

  // To read Images
  final FileType _fileType = FileType.image;
  final bool _pickMultipleImages = false;
  bool _uploadInProgress = false;
  bool? _uploadSuccess;
  var _storageAccessLevel = StorageAccessLevel.guest;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Convert the String 'value' to Storage Access level. This is required to
  // set S3 object permission.
  void _readStorageAccessLevel(String value) {
    switch (value) {
      case 'Guest':
        _storageAccessLevel = StorageAccessLevel.guest;
        break;
      case 'Private':
        _storageAccessLevel = StorageAccessLevel.private;
        break;
      case 'Protected':
        _storageAccessLevel = StorageAccessLevel.protected;
        break;
    }
  }

  // Opens Device gallery to select an Image.
  void _openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _fileType,
        allowMultiple: _pickMultipleImages,
      ))
          ?.files;
    } on PlatformException catch (e) {
      final String msg = "Unsupported operation - ${e.toString()}";
      _showDialog(msg);
    } catch (exception) {
      final String msg = "Unsupported operation - ${exception.toString()}";
      _showDialog(msg);
    }

    if (!mounted) return;

    setState(() {
      if (_paths != null) {
        _fileName = _paths![0].path.toString();
        _bucketObjectName = _fileName!.split("/").last;
      }
    });
  }

  // Alert Dialog to show any error messages.
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // Upload the Image to S3
  void _uploadFile() async {
    setState(() {
      _uploadInProgress = true;
      _uploadSuccess = null;
    });

    try {
      await S3Handler.uploadFile(
        filePath: _fileName!,
        accessLevel: _storageAccessLevel,
      );
      _uploadSuccess = true;
    } on StorageException catch (e) {
      var message = e.message;
      _uploadSuccess = false;
      _showDialog(message);
    } catch (error) {
      _uploadSuccess = false;
      var message = "Unable to upload the Image to S3 Bucket!";
      _showDialog(message);
    }

    setState(() {
      _uploadInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Upload Images'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _fileName != null
                      ? Image.file(
                          File(_fileName!),
                        )
                      : Container(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _fileName != null
                  ? Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '$_bucketObjectName',
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              _fileName != null
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: StorageAcceesLevel(
                              callback: _readStorageAccessLevel),
                        ),
                        Divider(),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: FloatingActionButton(
                                heroTag: "tag1",
                                onPressed: _uploadFile,
                                child: const Icon(Icons.upload),
                              ),
                            ),
                            if (_uploadInProgress) CircularProgressIndicator(),
                            if (_uploadInProgress) Text('Upload In Progress'),
                            if (_uploadSuccess != null)
                              _uploadSuccess!
                                  ? Text('Upload Complete!')
                                  : Text('Upload Failed!'),
                          ],
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.image),
          onPressed: _openFileExplorer,
          heroTag: "btn2",
        ),
      ),
    );
  }
}

///
/// Create a Dropdown button to select Object access level
///
class StorageAcceesLevel extends StatefulWidget {
  const StorageAcceesLevel({
    Key? key,
    required this.callback,
  }) : super(key: key);
  final void Function(String) callback;

  @override
  _StorageAcceesLevelState createState() => _StorageAcceesLevelState();
}

class _StorageAcceesLevelState extends State<StorageAcceesLevel> {
  String? dropdownValue = 'Guest';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Selected required Access Level',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1.0,
                  style: BorderStyle.solid,
                  color: Colors.blueAccent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
              child: DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(null),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue;
                    widget.callback(dropdownValue!);
                  });
                },
                items: <String>[
                  'Private',
                  'Guest',
                  'Protected',
                ].map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
