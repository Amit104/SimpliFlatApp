import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/lists/suggestions.dart';
import '../utility.dart';

class ListItems extends StatefulWidget {
  final flatId;
  final listReference;

  ListItems(this.listReference, this.flatId);

  @override
  State<StatefulWidget> createState() {
    return ListItemsState(this.listReference, this.flatId);
  }
}

//TODO - get latest list item before update
//TODO - keep item limit
class ListItemsState extends State<ListItems> {
  var _navigatorContext;
  TextEditingController textField = TextEditingController();
  final flatId;
  final listReference;
  List _items;

  FocusNode _keyboardFocusNode = FocusNode();
  Suggestions _suggestions = Suggestions();

  ListItemsState(this.listReference, this.flatId);

  @override
  void initState() {
    super.initState();
    var tempList = listReference['items'] ?? new List();
    _items = new List<Map>.from(tempList);
  }

  TextEditingController inputController = new TextEditingController();

  void _addItem() {
    String item = inputController.text;
    if (item.length > 0 && item.length < 100) {
      setState(() {
        if (_items == null) _items = new List();
        Map m = new Map();
        m['item'] = item.trim();
        m['completed'] = false;
        _items.insert(0, m);
        _suggestions.add(item.trim());
        inputController.text = "";
      });
      Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.lists)
          .document(listReference.documentID)
          .updateData({'items': _items});
    } else if (item.length >= 100) {
      Utility.createErrorSnackBar(_navigatorContext, error: "Tooo Long!");
    }
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
          title: Text(listReference['title'].toString().trim()),
          elevation: 0.0,
          centerTitle: true,
          /*actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () async {
                var res = await Navigator.push(
                  _navigatorContext,
                  MaterialPageRoute(
                      builder: (context) => AddListItem(listReference, _items, flatId)),
                );
                if (res != null && res != "") _items = res;
              },
            ),
          ],*/
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          child: Icon(Icons.add),
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Stack(
            children: <Widget>[
              Container(
                child: getListItems(),
                padding: EdgeInsets.only(bottom: 60),
              ),
              Positioned(
                  bottom: 0.0,
                  width: MediaQuery.of(context).size.width, // width 100%
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0x80000000),
                            offset: Offset(0.0, 6.0),
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: inputController,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (dynamic x) => _addItem(),
                          autofocus: false,
                          focusNode: _keyboardFocusNode,
                          decoration: InputDecoration(
                            hintText: "New Item..",
                            contentPadding: EdgeInsets.all(20),
                          ),
                        ),
                        direction: AxisDirection.up,
                        hideOnEmpty: true,
                        suggestionsCallback: (pattern) {
                          if (pattern.length > 0) {
                            return _suggestions.get(pattern);
                          } else {
                            return [];
                          }
                        },
                        debounceDuration: Duration(milliseconds: 100),
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        transitionBuilder:
                            (context, suggestionsBox, animationController) =>
                                suggestionsBox,
                        // no animation
                        onSuggestionSelected: (suggestion) {
                          inputController.text = suggestion;
                          _addItem();
                          if (!_keyboardFocusNode.hasFocus) {
                            FocusScope.of(context)
                                .requestFocus(_keyboardFocusNode);
                          }
                        },
                      ))),
            ],
          );
        }),
      ),
    );
  }

  void reorderList(var oldIndex, var newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      setState(() {
        final item = _items.removeAt(oldIndex);
        _items.insert(newIndex, item);
      });
      Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.lists)
          .document(listReference.documentID)
          .updateData({'items': _items});
    });
  }

  Widget getListItems() {
    if (_items == null || _items.length == 0) return Container();
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        reorderList(oldIndex, newIndex);
      },
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      //children: _items.map<Widget>(_buildListItem).toList(),
      children: _items.asMap().entries.map((entry) {
        return _buildListItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget buildListTile(item) {
    Widget listTile;
    listTile = ListTile(
      key: Key(item),
      title: Text(item),
      leading: const Icon(Icons.drag_handle),
    );

    return listTile;
  }

  Widget _buildListItem(index, listitem) {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.subhead;
    debugPrint(index.toString() + " LISTITEM INDEX");
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(right: 1.0, left: 1.0),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: UniqueKey(),
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
                          'Are you sure you want to delete this item?'),
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
                _deleteListItem(_navigatorContext, index);
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
                            'Are you sure you want to delete this item?'),
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
                    _deleteListItem(_navigatorContext, index);
                    state.dismiss();
                  }
                },
              ),
            ],
            child: ListTile(
              title: Text(
                listitem['item'].toString().trim(),
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Montserrat',
                  color: listitem['completed'] ? Colors.black54 : Colors.black,
                  decoration: listitem['completed'] ? TextDecoration.lineThrough : null
                ),
              ),
              leading: const Icon(Icons.drag_handle),
              trailing: GestureDetector(
                child: listitem['completed'] ? Icon(Icons.check_circle, color: Colors.indigo,) : Icon(Icons.check_circle_outline),
                onTap: () {
                  listitem['completed'] = !listitem['completed'];
                  var newIndex = listitem['completed'] ? _items.length : 0;
                  var oldIndex = index;
                  reorderList(oldIndex, newIndex);
                },
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  _deleteListItem(scaffoldContext, index) {
    setState(() {
      _items.removeAt(index);
    });
    Firestore.instance
        .collection(globals.flat)
        .document(flatId)
        .collection(globals.lists)
        .document(listReference.documentID)
        .updateData({'items': _items});
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
