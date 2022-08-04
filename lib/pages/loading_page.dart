import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/usuarios_page.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../services/socket_service.dart';
import 'login_page.dart';

class LoadingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(future: checkLoginState(context),
        builder: (context,  snapshot) { 
        return Center(child: Text('Espere...'),);
       },
      ));
  }

  Future checkLoginState(BuildContext context) async{
    final authService = Provider.of<AuthService>(context, listen: false);

    final socketService = Provider.of<SocketService>(context, listen: false);

    final autenticado = await authService.isLoggedIn();

    if(autenticado){
      socketService.connect();
      //Navigator.pushReplacementNamed(context, 'usuarios');
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___)=>UsuariosPage()));
    }else{
      //Navigator.pushReplacementNamed(context, 'login');
       Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___)=>LoginPage()));
    }
  }
}