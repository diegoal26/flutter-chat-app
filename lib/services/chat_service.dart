import 'package:flutter/material.dart';
import 'package:flutter_chat/global/environment.dart';
import 'package:flutter_chat/models/mensajes_response.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ChatService with ChangeNotifier{

  late Usuario usuarioPara;

  Future <List<Mensaje>> getChat(String usuarioId) async{
    final String? token = await AuthService.getToken();
    final resp = await http.get(Uri.parse('${Environment.apiUrl}/mensajes/$usuarioId'),
    headers: {'Content-Type':'application/json',
      'x-token':token!=null?token:''});

    final mensajesResponse = mensajesResponseFromJson(resp.body);

    return mensajesResponse.mensajes;

  }

}