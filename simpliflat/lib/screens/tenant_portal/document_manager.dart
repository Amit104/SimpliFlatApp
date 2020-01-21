import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import '../utility.dart';
import 'package:simpliflat/screens/globals.dart' as globals;

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
          return Column(
            children: <Widget>[
              Expanded(
                child: getLists(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget getLists() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.documentManager)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return LoadingContainerVertical(3);
        if (snapshot.data.documents.length == 0)
          return Container(
            child: CommonWidgets.textBox("", 22),
          );
        snapshot.data.documents
            .sort((a, b) => b['created_at'].compareTo(a['created_at']));
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int position) {
              return _buildListItem(
                  snapshot.data.documents[position], position);
            });
      },
    );
  }

  Widget _buildListItem(DocumentSnapshot list, index) {
    var datetime = (list['created_at'] as Timestamp).toDate();
    var numToMonth = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec'
    };
    final f = new DateFormat.jm();
    var datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        " - " +
        f.format(datetime);

    var userName =
        list['user_name'] == null ? "" : list['user_name'].toString().trim();

    var color = list['user_id'].toString().trim().hashCode;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: new Key(index.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              closeOnCanceled: true,
              dismissThresholds: <SlideActionType, double>{
                SlideActionType.primary: 1.0
              },
              onWillDismiss: (actionType) {
                return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text('Delete'),
                      content: new Text(
                          'Are you sure you want to delete this document?'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        new FlatButton(
                          child: new Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (actionType) {
                _deleteList(_navigatorContext, list.reference);
              },
            ),
            secondaryActions: <Widget>[
              new IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () async {
                  var state = Slidable.of(context);
                  var dismiss = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return new AlertDialog(
                        title: new Text('Delete'),
                        content: new Text(
                            'Are you sure you want to delete this document?'),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          new FlatButton(
                            child: new Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  if (dismiss) {
                    _deleteList(_navigatorContext, list.reference);
                    state.dismiss();
                  }
                },
              ),
            ],
            child: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Text(userName,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                          color:
                              Colors.primaries[color % Colors.primaries.length],
                        )),
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  Text(list['file_name'].toString().trim(),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      )),
                ],
              ),
              subtitle: Padding(
                child: Text(datetimeString,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black45,
                    )),
                padding: EdgeInsets.only(top: 6.0),
              ),
              trailing: InkWell(
                child: Icon(Icons.file_download),
                onTap: () {
                  downloadFile(list['file_url'], list['file_name']);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TODO Delete actual file
  _deleteList(scaffoldContext, docReference) {
    Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection(globals.documentManager)
        .document(docReference.documentID)
        .get()
        .then((freshDoc) {
      if (freshDoc == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        Firestore.instance
            .collection(globals.flat)
            .document(_flatId)
            .collection(globals.documentManager)
            .document(freshDoc.documentID)
            .delete()
            .then((deleted) {
          if (mounted)
            Utility.createErrorSnackBar(context, error: "Document Deleted");
        }, onError: (e) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      }
    }, onError: (e) {
      if (mounted) Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  void _openFileExplorer() async {
    File file;
    String _fileName;
    var fileLength;

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
                .replaceAll("-", "") +
            rng.nextInt(100).toString();
      } else {
        if (_fileName.contains(".")) {
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") +
              rng.nextInt(100).toString();
        } else {
          _fileName = _fileName +
              "_" +
              DateTime.now()
                  .toLocal()
                  .toString()
                  .replaceAll(":", "")
                  .replaceAll(" ", "")
                  .replaceAll(".", "")
                  .replaceAll("-", "") +
              rng.nextInt(100).toString();
        }
      }
      debugPrint(_fileName + " is uploading");
      debugPrint("File size is " + file.lengthSync().toString());
      fileLength = file.lengthSync();
      await uploadFile(file, _fileName, fileLength);
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
  }

  uploadFile(file, _fileName, fileLength) async {
    String fileUrl;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("TenantDocuments/" + _fileName);
    StorageUploadTask uploadTask = storageReference.putFile(file);
    if (mounted)
      Utility.createErrorSnackBar(_navigatorContext, error: "Uploading...");
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      if (fileURL != null || fileURL != "") {
        if (mounted) {
          Utility.createErrorSnackBar(_navigatorContext,
              error: "Upload Complete");
          fileUrl = fileURL;
        }
        addDocument(_fileName, fileUrl, fileLength);
      }
    });
  }

  downloadFile(fileUrl, name) async {
    String _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    debugPrint(_localPath + " - Saved");
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    final taskId = await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: _localPath,
      fileName: name,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Future<String> _findLocalPath() async {
    final directory = Theme.of(_navigatorContext).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  addDocument(_fileName, fileUrl, fileLength) {
    var timeNow = DateTime.now();
    var data = {
      'file_name': _fileName.replaceAll("_" + _fileName.split("_").last, ""),
      'file_url': fileUrl,
      'file_size': fileLength,
      'is_created_by_tenant': 1,
      'user_id': _userId,
      'created_at': timeNow,
      'updated_at': timeNow,
      'user_name': _userName
    };
    setState(() {
      addNote.text = '';
    });
    DocumentReference addNoteRef = Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection(globals.documentManager)
        .document();
    addNoteRef.setData(data).then((v) {}, onError: (e) {});
  }
}
