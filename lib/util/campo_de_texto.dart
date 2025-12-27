import 'package:flutter/material.dart';
import 'package:flutter_application_1_teste/const.dart';

Container criaCampoDeTexto(String nomeDoCampo, String campoDeEscritura) {
  return Container(
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nomeDoCampo,
            style: padraoTextoBranco,
          ),
          Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  campoDeEscritura,
                  style: padraoTextoBranco,
                ),
              ))
        ],
      ),
    ),
  );
}
