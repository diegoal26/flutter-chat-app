import 'package:flutter/material.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/usuarios_service.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_chat/models/usuario.dart';

import '../services/chat_service.dart';
import '../services/socket_service.dart';

class UsuariosPage extends StatefulWidget {

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuarioService = new UsuariosService();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<Usuario> usuarios = [];

  @override
  void initState() {
    this._cargarUsuarios();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    final socketService = Provider.of<SocketService>(context);

    
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text(authService.usuario.nombre, style: TextStyle(color: Colors.black87),),
      backgroundColor: Colors.white,
      leading: IconButton(onPressed: (){
        //TODO: Desconectar el socket server
        socketService.disconnect();
        authService.logout();
        Navigator.pushReplacementNamed(context, 'login');
      }, icon: Icon(Icons.exit_to_app, color: Colors.black87,)),
      actions: [
        Container(margin: EdgeInsets.only(right: 10), child: (socketService.serverStatus==ServerStatus.Online)?Icon(Icons.check_circle, color: Colors.blue[400],):
        Icon(Icons.offline_bolt, color:Colors.red),

        )
      ],
      elevation: 1,),
      body: SmartRefresher(controller: _refreshController,
      onRefresh: _cargarUsuarios,
      header: WaterDropHeader(complete: Icon(Icons.check, color: Colors.blue[400],),
      waterDropColor: Colors.blue[400]!,),
      child: _listViewUsuarios(),)
      );
  }

  _cargarUsuarios() async{
   usuarios = await usuarioService.getUsuarios();
    setState(() {
      
    });
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  ListView _listViewUsuarios() {
    return ListView.separated(physics: BouncingScrollPhysics(),
      itemBuilder: (_, i)=> _usuarioListTile(usuarios[i]), 
    separatorBuilder: (_, i)=>Divider(), itemCount: usuarios.length);
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[200],
        child: Text(usuario.nombre.substring(0,1)),
      ),
      trailing: Container(width: 10, height: 10,
      decoration: BoxDecoration(color: usuario.online?Colors.green[300]:Colors.red,
      borderRadius: BorderRadius.circular(100)),),
      onTap: (){
        final chatService = Provider.of<ChatService>(context, listen: false);
      chatService.usuarioPara = usuario;
      Navigator.pushNamed(context, 'chat');}
    );
  }
}