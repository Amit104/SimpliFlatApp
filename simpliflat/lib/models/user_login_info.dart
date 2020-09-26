import 'package:cloud_firestore/cloud_firestore.dart';

enum Flag {
    NEW_USER,
    FLAT_NOT_ASSIGNED,
    FLAT_ASSIGNED
}

enum RequestStatus {
  PENDING,
  DENIED,
  NONE
}

class FlatIncomingReq {
  DocumentReference ref;
  String displayId;

  FlatIncomingReq(this.ref, this.displayId);

  DocumentReference get docRef {
    return ref;
  }

  set docRef(dRef) {
    ref = dRef;
  }

  String get displayIdFlat {
    return displayId;
  }

  set displayIdFlat(display) {
    displayId = display;
  }
}

class UserLoginInfo {
  
  Flag flag;

  String flatId;

  List<String> incomingRequests;

  RequestStatus requestStatus;
  
}