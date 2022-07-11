
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/chat_page.dart';
import 'package:flutter_chat/pages/loading_page.dart';
import 'package:flutter_chat/pages/login_page.dart';
import 'package:flutter_chat/pages/usuarios_page.dart';
import '../pages/register_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'usuarios':(_)=>UsuariosPage(),
  'chat':(_)=>ChatPage(),
  'register':(_)=>RegisterPage(),
  'login':(_)=>LoginPage(),
  'loading':(_)=>LoadingPage()
};