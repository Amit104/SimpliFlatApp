import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddListItem extends StatefulWidget {
  final flatId;
  final listReference;
  final listItems;

  AddListItem(this.listReference, this.listItems, this.flatId);

  @override
  State<StatefulWidget> createState() {
    return AddListItemState(this.listReference, this.listItems, this.flatId);
  }
}

//TODO - add database of items
class AddListItemState extends State<AddListItem> {
  var _navigatorContext;
  TextEditingController listItemController = TextEditingController();
  final flatId;
  final listReference;
  final listItems;
  var _formKey1 = GlobalKey<FormState>();
  List _items;

  AddListItemState(this.listReference, this.listItems, this.flatId);

  @override
  void initState() {
    super.initState();
    var tempList = listItems ?? new List();
    _items = new List<String>.from(tempList);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text("Add item to " + listReference['title'].toString().trim()),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          TextStyle textStyle = Theme.of(_navigatorContext).textTheme.subhead;
          return Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 20,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0,top: 8.0,),
                              child: TextFormField(
                                autofocus: true,
                                keyboardType: TextInputType.text,
                                style: textStyle,
                                controller: listItemController,
                                validator: (String value) {
                                  if (value.isEmpty)
                                    return "Cannot add empty name!";
                                  if (value.length > 25) return "Too long!";
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Eg. Milk",
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700),
                                  errorStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.0,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 6,
                            child: OutlineButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                padding: const EdgeInsets.all(1.0),
                                textColor: Colors.indigo[900],
                                child: Text('Add',
                                    style: TextStyle(
                                        color: Colors.indigo[900],
                                        fontSize: 14.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700)),
                                onPressed: () {
                                  if (_formKey1.currentState.validate()) {
                                    _items.add(listItemController.text
                                        .toString()
                                        .trim());
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(flatId)
                                        .collection(globals.lists)
                                        .document(listReference.documentID)
                                        .updateData({'items': _items});
                                    Navigator.pop(_navigatorContext, _items);
                                  }
                                }),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, "");
  }
}
