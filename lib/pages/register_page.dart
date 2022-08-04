import 'package:flutter/material.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/widgets/boton_azul.dart';
import 'package:flutter_chat/widgets/custom_input.dart';
import 'package:flutter_chat/widgets/labels.dart';
import 'package:flutter_chat/widgets/logo.dart';
import 'package:provider/provider.dart';

import '../helpers/mostrar_alerta.dart';
import '../services/socket_service.dart';

class RegisterPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Logo(titulo: 'Registro',),
              _Form(),
              Labels(ruta: 'login', label1:'Ya tienes cuenta?', label2:'Ingresa con la misma!'),
              Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),)
            ],),
          ),
        ),
      )
      );
  }
}

class _Form extends StatefulWidget {

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(children: [
        CustomInput(icon: Icons.perm_identity_outlined, placeholder: 'Nombre',
        keyboardType: TextInputType.text, textController: nameCtrl,),

        CustomInput(icon: Icons.email_outlined, placeholder: 'Correo',
        keyboardType: TextInputType.emailAddress, textController: emailCtrl,),
        
        CustomInput(icon: Icons.password_outlined, placeholder: 'Password',
        textController: passCtrl, isPassword: true,),

        BotonAzul(texto: 'Crear Cuenta', onPressed: authService.autenticando?null : ()async{
          final resul = await authService.register(nameCtrl.text, emailCtrl.text, passCtrl.text);
          if(resul == true){
            socketService.connect();
            Navigator.pushReplacementNamed(context, 'usuarios');
          }else{
            mostrarAlerta(context, 'Correo ya registrado', resul);
          }
          //print(emailCtrl.text);
        },)
      ],),
    );
  }
}