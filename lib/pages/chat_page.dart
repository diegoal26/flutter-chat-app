import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();

  List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(children: [
        CircleAvatar(child: Text('Te', style: TextStyle(fontSize: 12),),
        backgroundColor: Colors.blue[100],),
        SizedBox(height: 3,),
        Text('Test1', style: TextStyle(color: Colors.black87, fontSize: 12),)

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

    print(texto);
    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new ChatMessage(texto: texto, uid: '123', 
    animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),);
    _messages.insert(0, newMessage);

    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });
  }

  @override
  void dispose() {
    for(ChatMessage chatMessage in _messages){
      chatMessage.animationController.dispose();
    }
    super.dispose();
  }
}