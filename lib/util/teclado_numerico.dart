import 'package:flutter/material.dart';
import 'package:flutter_application_1_teste/const.dart';

class meuBotao extends StatelessWidget {
  final String child;
  final VoidCallback onTap;
  var buttonColor = Colors.deepPurple[400];

  meuBotao({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle;
    if (child == 'DEL') {
      buttonColor = Colors.red;
    } else if (child == 'PROX') {
      buttonColor = Colors.green;
    } else if (child == 'AC') {
      buttonColor = Colors.grey;
    } else if (child == '0' ||
        child == '1' ||
        child == '2' ||
        child == '3' ||
        child == '4' ||
        child == '5' ||
        child == '6' ||
        child == '7' ||
        child == '8' ||
        child == '9') {
      buttonColor = Colors.deepPurple[300];
      textStyle = TextStyle(
        color: Colors.deepPurple[400], // Define a cor da fonte como azul
        fontWeight: FontWeight.bold, // Define o peso da fonteD
      );
    }

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(child, style: padraoTextoBranco),
          ),
        ),
      ),
    );
  }
}
