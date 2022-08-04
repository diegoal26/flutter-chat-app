import 'package:flutter_chat/global/environment.dart';
import 'package:flutter_chat/models/usuarios_response.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat/models/usuario.dart';

class UsuariosService{

  Future <List<Usuario>> getUsuarios()async{

    try {
      final String? token = await AuthService.getToken();
      final resp = await http.get(Uri.parse('${Environment.apiUrl}/usuarios'),
      headers: {'Content-Type':'application/json',
      'x-token':token!=null?token:''});

      final usuariosResponse = usuariosResponseFromJson(resp.body);

      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }

  }
}