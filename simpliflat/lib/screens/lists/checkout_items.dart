import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:simpliflat/service/ecomm_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class CheckoutItems extends StatefulWidget {
  final flatId;
  final listReference;
  final listItems;

  CheckoutItems(this.listReference, this.listItems, this.flatId);

  @override
  State<StatefulWidget> createState() {
    return CheckoutItemsState(this.listReference, this.listItems, this.flatId);
  }
}

class CheckoutItemsState extends State<CheckoutItems> {
  final flatId;
  final listReference;
  final listItems;
  var _navigatorContext;


  Map _items;

  int verticalThreshold = 3;

  List ecomms;
  List ecommsExpanded;

  Map selectedValues;
  CheckoutItemsState(this.listReference, this.listItems, this.flatId);

  @override
  void initState() {
    super.initState();

    ecomms = EcommService.getEcomms();
    ecommsExpanded = new List();

    _items = EcommService.getData();
    selectedValues = new Map();
    for(int i = 0; i < ecomms.length; i++) {
      ecommsExpanded.add(false);
      selectedValues[ecomms[i]] = new List<bool>.filled(_items[ecomms[i]].length, false);
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
          title:
                Text('Checkout items'),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
                _navigatorContext = scaffoldC;
                return ListView(
                  children: [
                    
                    ExpansionPanelList (
                      expandedHeaderPadding: EdgeInsets.all(10.0),
                      children: getExpansionListItems(),
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          ecommsExpanded[index] = !isExpanded;
                        });
                      },
                    )
                  ],
                );
        }),
      ),
    );
  }

  List<ExpansionPanel> getExpansionListItems() {
    List<ExpansionPanel> w = new List();
    for(int i = 0; i < ecomms.length; i++) {
      w.add(
        ExpansionPanel(
          isExpanded: ecommsExpanded[i],
          headerBuilder: (BuildContext context, bool isExpanded) {
            return new ListTile(
                        title: new Text(
                          ecomms[i],
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                    );
          },
          body: Column (
            children: getEcommWiseItems(_items[ecomms[i]], ecomms[i]),
          ),
        )
      );

    }
    return w;
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    Navigator.pop(_navigatorContext, "");
  }

  /*List<Widget> getListItems() {
    List<Widget> w = new List();
    for(int i = 0; i < ecomms.length; i++) {
      if (_items[ecomms[i]] == null || _items[ecomms[i]].length == 0) {
        w.add(
          Container(
            width: MediaQuery.of(_navigatorContext).size.width,
            child: LoadingContainerVertical(3),
          ),
        );
      }
      else {
        w.add(
            Container(
              margin: EdgeInsets.only(bottom:2.0),
              width: MediaQuery.of(_navigatorContext).size.width,
              child: Container(
                child: Card (
                  color: Colors.grey[150],
                  child: ExpansionTile( 
                    key: UniqueKey(),
                    initiallyExpanded: false,
                    title: Text(ecomms[i],
                      style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                      ),
                    ),
                    children: getEcommWiseItems(_items[ecomms[i]], ecomms[i]),
                  ),
                ),
              ),
            ),
        );
      }
    }

    return w;
  }*/

  List<Widget> getEcommWiseItems(List ecommItems, String ecommNameStr) {

    debugPrint('Ecomm = ' + ecommNameStr);
    List<Widget> w = new List();
    if(ecommItems.length == 0) {
      return w;
    }

    
    
    for(int i = 0; i < verticalThreshold && i < ecommItems.length; i++) {
      w.add(_buildListItem(i, ecommItems[i], false, ecommNameStr));
    }

    debugPrint('Ecomm before horizontal = ' + ecommNameStr);

    Widget horizontalList;
    if (ecommItems == null || ecommItems.length == 0)
      horizontalList =  LoadingContainerVertical(3);
    else {
      horizontalList = Container (
        height: 150.0,
        margin: EdgeInsets.only(top: 10.0, bottom:10.0),
        padding: EdgeInsets.only(top: 10.0, bottom:10.0),
        color: Colors.grey[100],
        child: ListView (
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          //children: _items.map<Widget>(_buildListItem).toList(),
          children: getHorizontalListItems(ecommItems, ecommNameStr),
        ),
      );
    }

    w.add(horizontalList);
    
    Widget raisedButton = 
                           Container (
                            margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
                            width: MediaQuery.of(_navigatorContext).size.width,
                            child: RaisedButton(
                            padding: EdgeInsets.only(top:25.0, bottom: 25.0),
                            child: Text(
                              'Add to Cart',
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              for(int j = 0; j < ecomms.length; j++) { 
                                for(int i = 0; i < selectedValues[ecomms[j]].length; i++) {
                                  debugPrint(i.toString() + ' ' + selectedValues[ecomms[j]][i].toString());
                                }
                              }
                            },
                            color: Colors.amber,
                          ),
                        );
                      
    w.add(raisedButton);
    return w;
  }

  List<Widget> getHorizontalListItems(List ecommItems, String ecommNameStr) {
    List<Widget> w = new List();
    debugPrint('Ecomm during horizontal = ' + ecommNameStr);
    for(int i = verticalThreshold; i < ecommItems.length; i++) {
      w.add(_buildListItem(i, ecommItems[i], true, ecommNameStr));
    }

    return w;
  }



  Widget _buildListItem(index, listitem, horizontal, ecommName) {
    double widthRatio;
    if(horizontal)
      widthRatio = 0.9;
    else
      widthRatio = 1; 
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(right: 1.0, left: 1.0),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width * widthRatio,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Row (
            children: <Widget> [
              Image.network(listitem['imageLocation'],
                width: MediaQuery.of(context).size.width * 0.30, 
                height: 100.0,
              ),
              Expanded (
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(listitem['productName'] + ' (' + listitem['quantity'] + ')',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                      
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0, left: 2.0),
                          child:Text(listitem['price']),
                        ),
                        Visibility (
                          visible: listitem['rating'] != ''? true:false,
                          child:Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child:RatingBarIndicator(
                              rating: double.parse(listitem['rating'] == ''? '0': listitem['rating']),
                              itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 15.0,
                              direction: Axis.horizontal,
                            )
                          ),
                        ),
                      ]
                    ),
                  ],
                ),
              ),
              Container (
                  padding: EdgeInsets.only(left:5.0, right:5.0),
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    key: UniqueKey(),
                    value: selectedValues[ecommName][index],
                    onChanged: (selected) {
                      setState(() {
                        selectedValues[ecommName][index] = selected;            
                      });
                    },
                  ),
                ),
            ]),
        ),
      ),
    );
  }

}