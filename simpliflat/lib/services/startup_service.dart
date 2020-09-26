import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/models/user.dart';
import 'package:simpliflat/models/user_login_info.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/constants/globals.dart' as globals;

class StartupService {
  static Future<UserLoginInfo> getUserLoginInfo() async {
    var userId;
    var flatId;

    UserLoginInfo userLoginInfo = new UserLoginInfo();

    userId = Utility.getUserId();
    flatId = Utility.getFlatId();

    if (userId == null) {
      userLoginInfo.flag = Flag.NEW_USER;
    } else if (flatId == null || flatId == "null" || flatId == "") {
      Firestore.instance
          .collection("joinflat")
          .where("user_id", isEqualTo: userId)
          .getDocuments()
          .then((requests) {
        debugPrint("AFTER JOIN REQ");
        if (requests.documents != null && requests.documents.length != 0) {
          bool userRequested = false;
          String statusForUserReq = "";
          List<String> incomingRequests = new List<String>();

          List<FlatIncomingReq> flatIdGetDisplay = new List();
          requests.documents.sort((a, b) =>
              a.data['updated_at'].compareTo(b.data['updated_at']) > 0
                  ? 1
                  : -1);
          for (int i = 0; i < requests.documents.length; i++) {
            var data = requests.documents[i].data;
            var reqFlatId = data['flat_id'];
            var reqStatus = data['status'];
            var reqFromFlat = data['request_from_flat'];

            if (reqFromFlat.toString() == "0") {
              userRequested = true;
              statusForUserReq = reqStatus.toString();
              flatId = reqFlatId.toString();
            } else {
              // case where flat made a request to add user
              // show all these flats to user on next screen - Create or join
              if (reqStatus.toString() == "0")
                flatIdGetDisplay.add(FlatIncomingReq(
                    Firestore.instance.collection("flat").document(reqFlatId),
                    ''));
            }
          }

          //get Display IDs for flats with incoming requests
          Firestore.instance.runTransaction((transaction) async {
            for (int i = 0; i < flatIdGetDisplay.length; i++) {
              DocumentSnapshot flatData =
                  await transaction.get(flatIdGetDisplay[i].ref);
              if (flatData.exists)
                flatIdGetDisplay[i].displayId = flatData.data['display_id'];
            }
          }).whenComplete(() {
            for (int i = 0; i < flatIdGetDisplay.length; i++) {
              incomingRequests.add(flatIdGetDisplay[i].displayId);
            }
            debugPrint("IN NAVIGATE");
            debugPrint(incomingRequests.length.toString());
            if (userRequested) {
              userId = userId.toString();
              flatId = flatId.toString();
              if (statusForUserReq == "1") {
                Utility.addToSharedPref(flatId: flatId);
                userLoginInfo.flag = Flag.FLAT_ASSIGNED;
                userLoginInfo.flatId = flatId;
                //_navigate(_navigatorContext, 3, flatId: flatId);
              } else if (statusForUserReq == "-1") {
                userLoginInfo.flag = Flag.FLAT_NOT_ASSIGNED;
                userLoginInfo.incomingRequests = incomingRequests;
                userLoginInfo.requestStatus = RequestStatus.DENIED;
                //_navigate(_navigatorContext, 2,
                //    requestDenied: -1, incomingRequests: incomingRequests);
              } else {
                userLoginInfo.flag = Flag.FLAT_NOT_ASSIGNED;
                userLoginInfo.incomingRequests = incomingRequests;
                userLoginInfo.requestStatus = RequestStatus.PENDING;
                //_navigate(_navigatorContext, 2,
                //    requestDenied: 0, incomingRequests: incomingRequests);
              }
            } else {
              userLoginInfo.flag = Flag.FLAT_NOT_ASSIGNED;
              userLoginInfo.incomingRequests = incomingRequests;
              userLoginInfo.requestStatus = RequestStatus.NONE;
              //_navigate(_navigatorContext, 2,
              //    requestDenied: 2, incomingRequests: incomingRequests);
            }
          }).catchError((e) {
            debugPrint("SERVER TRANSACTION ERROR");
            //Utility.createErrorSnackBar(_navigatorContext);
          });
        } else {
          debugPrint("IN ELSE FLAT NULL");
          //_navigate(_navigatorContext, 2, requestDenied: 2);
          userLoginInfo.flag = Flag.FLAT_NOT_ASSIGNED;
          userLoginInfo.requestStatus = RequestStatus.NONE;
        }
      }, onError: (e) {
        debugPrint("CALL ERROR");
        //Utility.createErrorSnackBar(_navigatorContext);
      }).catchError((e) {
        debugPrint("SERVER ERROR");
        debugPrint(e.toString());
        //Utility.createErrorSnackBar(_navigatorContext);
      });
    } else {
      debugPrint("IN ELSE");
      //_navigate(_navigatorContext, 3, flatId: flatId);
      userLoginInfo.flag = Flag.FLAT_ASSIGNED;
      userLoginInfo.flatId = flatId;
    }

    return userLoginInfo;
  }
}
