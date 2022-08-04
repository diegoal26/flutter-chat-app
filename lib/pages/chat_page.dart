import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/chat_service.dart';
import 'package:flutter_chat/widgets/chat_message.dart';
import 'package:provider/provider.dart';

import '../models/mensajes_response.dart';
import '../services/socket_service.dart';

class ChatPage extends StatefulWidget {

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();

  List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('mensaje-personal', _escucharMensaje);

    _cargarHistorial(this.chatService.usuarioPara.uid);
    
  }

  void _cargarHistorial(String usuarioId) async{
    List<Mensaje> chat = await this.chatService.getChat(usuarioId);

    for (var item in chat) {
      final chatMessage = new ChatMessage(texto: item.mensaje, uid: item.de, 
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 0))..forward());
      

      setState(() {
       _messages.add(chatMessage);
    });
    }

  }

  void _escucharMensaje(dynamic payload){
    //print('Tengo mensaje $data');
    final message = new ChatMessage(texto: payload['mensaje'], uid: payload['de'], 
    animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),);

    setState(() {
       _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(children: [
        CircleAvatar(child: Text(chatService.usuarioPara.nombre.substring(0,2), style: TextStyle(fontSize: 12),),
        backgroundColor: Colors.blue[100],),
        SizedBox(height: 3,),
        Text(chatService.usuarioPara.nombre, style: TextStyle(color: Colors.black87, fontSize: 12),)

      ],),),
      body: Container(child: Column(
        children: [
          Flexible(
            child: ListView.builder(reverse: true,
              physics: BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (_, i)=>_messages[i]),
          ),
          Divider(height: 1,),
          //Caja de texto
          Container(color: Colors.white,
          child: _inputChat(),)
        ],
      )),
      );
  }

  Widget _inputChat(){
    return SafeArea(child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(children: [
        Flexible(
          child: TextField(controller: _textController, onSubmitted: _handleSubmit
          ,
          onChanged: (String texto){
            setState(() {
              if(texto.trim().length > 0){
                _estaEscribiendo = true;
              }else{
                 _estaEscribiendo = false;
              }
            });
          },
          decoration: InputDecoration.collapsed(hintText: 'Enviar mensaje'),
          focusNode: _focusNode,),
        ),
        Container(margin: EdgeInsets.symmetric(horizontal: 4),
        child: Platform.isIOS ? CupertinoButton(child: Text('Enviar'), onPressed: _estaEscribiendo ? ()=> _handleSubmit(_textController.text):null)
        :Container(margin: EdgeInsets.symmetric(horizontal: 4),
        child: IconTheme(
          data: IconThemeData(color: Colors.blue[400]),
          child: IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: _estaEscribiendo ? ()=> _handleSubmit(_textController.text):null, icon: Icon(Icons.send,)),
        ),),)
      ],),
    ));
  }

  _handleSubmit(String texto){
    if(texto.length == 0) return null;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new ChatMessage(texto: texto, uid: authService.usuario.uid, 
    animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),);
    _messages.insert(0, newMessage);

    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });

    this.socketService.emit('mensaje-personal', {'de': this.authService.usuario.uid,
    'para': this.chatService.usuarioPara.uid,
    'mensaje': texto});

  }

  @override
  void dispose() {
    for(ChatMessage chatMessage in _messages){
      chatMessage.animationController.dispose();
    }

    this.socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}