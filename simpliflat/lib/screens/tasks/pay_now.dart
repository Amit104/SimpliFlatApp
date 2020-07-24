import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upi_pay/upi_pay.dart';

class PayNow extends StatefulWidget {
  final _flatId, _payee, _amt, _taskId;

  PayNow(this._taskId, this._flatId, this._payee, this._amt);

  @override
  State<StatefulWidget> createState() {
    return _PayNow(this._taskId, this._flatId, this._payee, this._amt);
  }
}

class _PayNow extends State<PayNow> {
  final _flatId, _payee, _amt, _taskId;
  var _navigatorContext;

  String _upiAddrError;

  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isUpiEditable = false;
  Future<List<ApplicationMeta>> _appsFuture;

  _PayNow(this._taskId, this._flatId, this._payee, this._amt);

  @override
  void initState() {
    super.initState();
    if (_amt != null && _amt != "" && double.tryParse(_amt) != null) {
      _amountController.text = double.parse(_amt).toStringAsFixed(2);
    }
    if (_payee != null && _payee != '-' && _payee != '') {
      _upiAddressController.text = _payee;
    }
    _appsFuture = UpiPay.getInstalledUpiApplications();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err.toString();
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    debugPrint("Starting transaction with id $transactionRef");

    var amount = '';
    if (_amountController.text != null && _amountController.text != "" && double.tryParse(_amountController.text) != null) {
      amount = double.parse(_amountController.text).toStringAsFixed(2);
      final response = await UpiPay.initiateTransaction(
          amount: amount,
          app: app.upiApplication,
          receiverUpiAddress: _upiAddressController.text,
          transactionRef: transactionRef,
          receiverName: _upiAddressController.text.split('@')[0].toString()
      );
      if(response.status == UpiTransactionStatus.success) {
        Utility.createErrorSnackBar(_navigatorContext, error: "Payment successful!");
        var _userId = await Utility.getUserId();
        var _userName = await Utility.getUserName();
        var payHistoryData = {
          "created_at": DateTime.now(),
          "completed_by": _userId,
          "user_name": _userName,
          "app" : app.upiApplication.toString(),
          "amount": amount,
          "receiverUpiAddress": _upiAddressController.text,
          "rawResponse": response.rawResponse.toString()
        };
        Firestore.instance
            .collection(globals.flat)
            .document(_flatId)
            .collection(globals.tasks)
            .document(_taskId)
            .collection(globals.paymentHistory)
            .add(payHistoryData);
        Navigator.pop(_navigatorContext, true);
      } else {
        Utility.createErrorSnackBar(_navigatorContext, error: "Payment failed!");
      }
      //debugPrint(a.status.toString() + " " + a.rawResponse.toString() + a.responseCode.toString() + " " + a.approvalRefNo.toString() + " " + a.txnRef.toString() + " " + a.txnId.toString());
    } else {
      Utility.createErrorSnackBar(_navigatorContext, error: "Invalid Amount!");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay Now"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _upiAddressController,
                          enabled: _isUpiEditable,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'address@upi',
                            labelText: 'Receiving UPI Address',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: IconButton(
                          icon: Icon(
                            _isUpiEditable ? Icons.check : Icons.edit,
                          ),
                          onPressed: () {
                            setState(() {
                              _isUpiEditable = !_isUpiEditable;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_upiAddrError != null)
                  Container(
                    margin: EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      _upiAddrError,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 65, bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Pay Using',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      FutureBuilder<List<ApplicationMeta>>(
                        future: _appsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return Container();
                          }

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.6,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data
                                .map((it) => Material(
                                      key: ObjectKey(it.upiApplication),
                                      color: Colors.white,
                                      child: InkWell(
                                        onTap: () => _onTap(it),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.memory(
                                              it.icon,
                                              width: 45,
                                              height: 45,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 8),
                                              child: Text(
                                                it.upiApplication.getAppName(),
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontFamily: 'Montserrat',
                                                      color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  String _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI Address is required.';
    }
    if (!UpiPay.checkIfUpiAddressIsValid(value)) {
      return 'UPI Address is invalid.';
    }
    return null;
  }
}
