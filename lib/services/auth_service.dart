import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat/global/environment.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_chat/models/login_response.dart';
import 'package:flutter_chat/models/usuario.dart';

class AuthService with ChangeNotifier{
  late Usuario usuario;

  bool _autenticando = false;

  // Create storage
final _storage = new FlutterSecureStorage();

  bool get autenticando =>this._autenticando;

  set autenticando(bool valor){
    this._autenticando = valor;
    notifyListeners();
  }

  static Future<String?> getToken()async{
    final _storage = new FlutterSecureStorage();
    final token = _storage.read(key: 'token');

    return token;
  }

  static Future<void> deleteToken()async{
    final _storage = new FlutterSecureStorage();
    _storage.delete(key: 'token');

  }

  Future<bool> login(String email, String password)async{
    this.autenticando = true;
    final data = {
      'email':email,
      'password':password
    };

    final resp = await http.post(Uri.parse('${Environment.apiUrl}/login'),
      body:jsonEncode(data),
      headers: {'Content-Type':'application/json'}
    );

    this.autenticando = false;

    if(resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      await this._guardarToken(loginResponse.token);

      return true;
    }else{
      
      return false;
    }
  }

  Future register(String nombre, String email, String password)async{
    this.autenticando = true;
    final data = {'nombre':nombre, 
                'email':email, 'password':password};

     final resp = await http.post(Uri.parse('${Environment.apiUrl}/login/new'),
      body:jsonEncode(data),
      headers: {'Content-Type':'application/json'}
    );
    this.autenticando = false;
    if(resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      await this._guardarToken(loginResponse.token);
      return true;
    }else{
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future _guardarToken(String token) async{

  await _storage.write(key: 'token', value: token);

  }

  Future logout() async{
  await _storage.delete(key: 'token');
  }

  Future isLoggedIn() async{
    final String? token = await this._storage.read(key: 'token');

    final resp = await http.get(Uri.parse('${Environment.apiUrl}/login/renew'),
      headers: {'Content-Type':'application/json',
      'x-token':token!=null?token:''}
    );
    if(resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      await this._guardarToken(loginResponse.token);
      return true;
    }else{
      this.logout();
      return false;
    }
    
    print(token);
  }
}
