import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackapp/helpers/admin_user.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  bool _isAdmin = false;
  // ignore: prefer_final_fields
  final List _userList = [];
  Auth([this._token, this._userId]);

  get isAuth {
    return token != "";
  }

  get userList {
    return _userList;
  }

  get isAdmin {
    return _isAdmin;
  }

  get token {
    if (_token != null) {
      return _token;
    }
    return "";
  }

  get userId {
    return _userId;
  }

  Future<List> getAllUsers() async {
    _userList.clear();
    final url = Uri.parse(
        'https://trackapp-bc490-default-rtdb.europe-west1.firebasedatabase.app/users.json?key=AIzaSyB0WzgOCTnba1aKYm-ivSFizMO8D4ivhVI');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      responseData.forEach((key, value) {
        _userList.add(value);
      });
      return _userList;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> postUser(String email, String userId) async {
    final url = Uri.parse(
        'https://trackapp-bc490-default-rtdb.europe-west1.firebasedatabase.app/users.json');
    try {
      final response = await http.post(url,
          body: json.encode({"userId": userId, "email": email}));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, dynamic>;
    await logIn(extractedUserData['email'], extractedUserData['password']);
    return true;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB0WzgOCTnba1aKYm-ivSFizMO8D4ivhVI');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      if (_userId == Admin().adminUid) {
        _isAdmin = true;
      } else {
        _isAdmin = false;
      }
      if (urlSegment == "signUp") {
        postUser(email, userId);
      }
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'email': email,
        'password': password,
      });
      prefs.setString("userData", userData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}
