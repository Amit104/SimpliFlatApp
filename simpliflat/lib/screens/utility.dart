import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/profile/profile_options.dart';

class Utility {
  static void navigateToProfileOptions(context) async {
    var userName = await Utility.getUserName();
    var userPhone = await Utility.getUserPhone();
    var flatName = await Utility.getFlatName();
    var displayId = await Utility.getFlatDisplayId();

    Map result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfileOptions(userName, userPhone, flatName, displayId)),
    );
  }

  static void createErrorSnackBar(scaffoldContext,
      {error: 'Something went wrong. Try again!'}) {
    final snackBar = SnackBar(
      content: Text(error),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  static void addToSharedPref(
      {userName: 'null',
      userPhone: '',
      userId: 'null',
      flatId: 'null',
      displayId: 'null',
      notificationToken: 'null',
      flatName: 'null',
      landlordId: 'null',
      landlordName: 'null',
      apartmentName: 'null',
      apartmentNumber: 'null',
      zipcode: 'null',
      noticeboardLastUpdated:'null'}) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != 'null')
      await prefs.setString(globals.userName, userName.toString());
    if (userPhone != 'null')
      await prefs.setString(globals.userPhone, userPhone.toString());
    if (userId != 'null')
      await prefs.setString(globals.userId, userId.toString());
    if (displayId != 'null')
      await prefs.setString(globals.displayId, displayId.toString());
    if (flatId != 'null')
      await prefs.setString(globals.flatId, flatId.toString());
    if (notificationToken != 'null')
      await prefs.setString(globals.notificationToken, notificationToken);
    if (flatName != 'null') await prefs.setString(globals.flatName, flatName);
    if (landlordId != 'null')
      await prefs.setString(globals.landlordId, landlordId);
    if (landlordName != 'null')
      await prefs.setString(globals.landlordName, landlordName);
    if (apartmentName != 'null')
      await prefs.setString(globals.apartmentName, apartmentName);
    if (apartmentNumber != 'null')
      await prefs.setString(globals.apartmentNumber, apartmentNumber);
    if (zipcode != 'null') await prefs.setString(globals.zipcode, zipcode);
    if (noticeboardLastUpdated != 'null')
      await prefs.setString(globals.noticeboardLastUpdated, noticeboardLastUpdated);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.userName);
  }

  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.userPhone);
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.userId);
  }

  static Future<String> getFlatId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.flatId);
  }

  static Future<String> getFlatDisplayId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.displayId);
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.notificationToken);
  }

  static Future<String> getFlatName() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.flatName);
  }

  static Future<String> getLandlordId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.landlordId);
  }

  static Future<String> getLandlordName() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.landlordName);
  }

  static Future<String> getApartmentName() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.apartmentName);
  }

  static Future<String> getApartmentNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.apartmentNumber);
  }

  static Future<String> getZipcode() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.zipcode);
  }

  static Future<String> getNoticeboardLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get(globals.noticeboardLastUpdated);
  }

  static removeLandlordId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(globals.landlordId);
    await prefs.remove(globals.landlordName);
  }

  static double getAdjustedHeight(double height, BuildContext context) {
    return height * MediaQuery.of(context).size.height / 640.0;
  }

  static Color userIdColor(userId) {
    var color = userId.toString().trim().hashCode;
    return Colors.primaries[color % Colors.primaries.length];
  }
}
