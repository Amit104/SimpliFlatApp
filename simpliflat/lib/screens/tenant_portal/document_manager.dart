import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utility.dart';

class DocumentManager extends StatefulWidget {
  final _flatId;

  DocumentManager(this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _DocumentManager(_flatId);
  }
}

class _DocumentManager extends State<DocumentManager> {
  final _flatId;
  var _userId, _userName;
  var _navigatorContext;
  var date = DateFormat("yyyy-MM-dd");
  TextEditingController note = TextEditingController();
  TextEditingController addNote = TextEditingController();

  String _path;
  String _extension;
  FileType _pickingType = FileType.ANY;
  bool _loadingPath = false;

  File file;
  String _fileName;
  var fileLength;
  String fileUrl;

  _DocumentManager(this._flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Utility.getUserId().then((id) {
      _userId = id;
    });
    Utility.getUserName().then((name) {
      _userName = name;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Document Manager"),
        centerTitle: true,
        elevation: 0.0,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _openFileExplorer();
        },
        tooltip: 'New Document',
        backgroundColor: Colors.red[900],
        child: new Icon(Icons.add),
      ),
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loadingPath
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator())
                    : _path != null
                        ? new Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: new Scrollbar(
                                child: new ListView.separated(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                final String name =
                                    'File: ' + _fileName ?? '...';
                                final path = _path;

                                return new ListTile(
                                  title: new Text(
                                    name,
                                  ),
                                  subtitle: new Text(path),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      new Divider(),
                            )),
                          )
                        : new Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      file = await FilePicker.getFile(type: _pickingType);
      _fileName = file.path?.split("/")?.last;
      var rng = new Random();
      if (_fileName == null || _fileName == "") {
        _fileName = _userName +
            DateTime.now()
                .toLocal()
                .toString()
                .replaceAll(":", "")
                .replaceAll(" ", "")
                .replaceAll(".", "")
                .replaceAll("-", "") + rng.nextInt(100).toString();
      } else {
        if(_fileName.contains(".")){
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") + rng.nextInt(100).toString();
        } else {
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") + rng.nextInt(100).toString();
        }
      }
      debugPrint(_fileName + " is uploading");
      debugPrint("File size is " + file.lengthSync().toString());
      fileLength = file.lengthSync();
      await uploadFile();
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
  }

  uploadFile() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("TenantDocuments/" + _fileName);
    StorageUploadTask uploadTask = storageReference.putFile(file);
    if (mounted) Utility.createErrorSnackBar(context, error: "Uploading...");
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        debugPrint('file = ' + fileURL);
      });
      if (fileURL != null || fileURL != "") {
        fileUrl = fileURL;
        if (mounted)
          Utility.createErrorSnackBar(context, error: "Upload Complete");
      }
    });
  }
}
