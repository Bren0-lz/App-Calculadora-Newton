import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_teste/util/teclado_numerico.dart';
import 'package:flutter_application_1_teste/util/campo_de_texto.dart';
import 'calculo.dart'; // Importa o cálculo de Newton

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _EstadoPaginaTeste();
}

class _EstadoPaginaTeste extends State<PaginaTeste> {
  // Nós de foco para os campos de texto
  final FocusNode _focusFuncao = FocusNode();
  final FocusNode _focusX1 = FocusNode();
  final FocusNode _focusAproximacao = FocusNode();

  // Estado dos campos de texto
  String campoSelecionado = 'funcao';
  String campoDeFuncao = '';
  String campoDoX1 = '';
  String campoDeAproximacao = '';

  // Posições do cursor
  int cursorPosFuncao = 0;
  int cursorPosX1 = 0;
  int cursorPosAproximacao = 0;

  // Controle do cursor piscando
  bool _mostrarCursor = true;
  Timer? _timerCursor;

  // Teclado numérico e funções matemáticas
  final List<String> tecladoNumerico = [
    'sen',
    'cos',
    'mod',
    'csc',
    'sec',
    'cot',
    'tg',
    '√',
    'ln',
    'log',
    '<-',
    '->',
    '+',
    '-',
    '7',
    '8',
    '9',
    'AC',
    '*',
    'x',
    '4',
    '5',
    '6',
    'DEL',
    '/',
    '^',
    '1',
    '2',
    '3',
    'PROX',
    'e',
    'π',
    '.',
    '0',
    '(',
    ')',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarCursorPiscando();
  }

  @override
  void dispose() {
    _timerCursor?.cancel();
    _focusFuncao.dispose();
    _focusX1.dispose();
    _focusAproximacao.dispose();
    super.dispose();
  }

  // Inicia o timer para o cursor piscar
  void _iniciarCursorPiscando() {
    _timerCursor = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _mostrarCursor = !_mostrarCursor;
      });
    });
  }

  // Retorna o texto com o cursor na posição correta
  String _getTextoComCursor(String texto, int posCursor, bool mostrarCursor) {
    if (!mostrarCursor) return texto;
    return texto.substring(0, posCursor) + '|' + texto.substring(posCursor);
  }

  // Lógica para quando um botão é pressionado
  void botaoFoiApertado(String botao) {
    setState(() {
      if (botao == 'DEL') {
        // Lógica para deletar caracteres
        if (campoSelecionado == 'funcao' &&
            campoDeFuncao.isNotEmpty &&
            cursorPosFuncao > 0) {
          campoDeFuncao = campoDeFuncao.substring(0, cursorPosFuncao - 1) +
              campoDeFuncao.substring(cursorPosFuncao);
          cursorPosFuncao--;
        } else if (campoSelecionado == 'x1' &&
            campoDoX1.isNotEmpty &&
            cursorPosX1 > 0) {
          campoDoX1 = campoDoX1.substring(0, cursorPosX1 - 1) +
              campoDoX1.substring(cursorPosX1);
          cursorPosX1--;
        } else if (campoSelecionado == 'aproximacao' &&
            campoDeAproximacao.isNotEmpty &&
            cursorPosAproximacao > 0) {
          campoDeAproximacao =
              campoDeAproximacao.substring(0, cursorPosAproximacao - 1) +
                  campoDeAproximacao.substring(cursorPosAproximacao);
          cursorPosAproximacao--;
        }
      } else if (botao == '<-') {
        // Move o cursor para a esquerda
        if (campoSelecionado == 'funcao' && cursorPosFuncao > 0) {
          cursorPosFuncao--;
        } else if (campoSelecionado == 'x1' && cursorPosX1 > 0) {
          cursorPosX1--;
        } else if (campoSelecionado == 'aproximacao' &&
            cursorPosAproximacao > 0) {
          cursorPosAproximacao--;
        }
      } else if (botao == '->') {
        // Move o cursor para a direita
        if (campoSelecionado == 'funcao' &&
            cursorPosFuncao < campoDeFuncao.length) {
          cursorPosFuncao++;
        } else if (campoSelecionado == 'x1' && cursorPosX1 < campoDoX1.length) {
          cursorPosX1++;
        } else if (campoSelecionado == 'aproximacao' &&
            cursorPosAproximacao < campoDeAproximacao.length) {
          cursorPosAproximacao++;
        }
      } else if (botao == 'PROX') {
        // Alterna entre os campos de texto
        if (campoSelecionado == 'funcao') {
          campoSelecionado = 'x1';
          _focusX1.requestFocus();
        } else if (campoSelecionado == 'x1') {
          campoSelecionado = 'aproximacao';
          _focusAproximacao.requestFocus();
        } else if (campoSelecionado == 'aproximacao') {
          campoSelecionado = 'funcao';
          _focusFuncao.requestFocus();
        }
      } else if (botao == 'AC') {
        // Limpa o campo selecionado
        if (campoSelecionado == 'funcao') {
          campoDeFuncao = '';
          cursorPosFuncao = 0;
        } else if (campoSelecionado == 'x1') {
          campoDoX1 = '';
          cursorPosX1 = 0;
        } else if (campoSelecionado == 'aproximacao') {
          campoDeAproximacao = '';
          cursorPosAproximacao = 0;
        }
      } else {
        // Insere o texto do botão no campo selecionado
        if (campoSelecionado == 'funcao') {
          campoDeFuncao = campoDeFuncao.substring(0, cursorPosFuncao) +
              botao +
              campoDeFuncao.substring(cursorPosFuncao);
          cursorPosFuncao += botao.length;
        } else if (campoSelecionado == 'x1') {
          campoDoX1 = campoDoX1.substring(0, cursorPosX1) +
              botao +
              campoDoX1.substring(cursorPosX1);
          cursorPosX1 += botao.length;
        } else if (campoSelecionado == 'aproximacao') {
          campoDeAproximacao =
              campoDeAproximacao.substring(0, cursorPosAproximacao) +
                  botao +
                  campoDeAproximacao.substring(cursorPosAproximacao);
          cursorPosAproximacao += botao.length;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _CampoComRotulo(
                  rotulo: 'f(x) = ',
                  texto: _getTextoComCursor(
                    campoDeFuncao,
                    cursorPosFuncao,
                    campoSelecionado == 'funcao' && _mostrarCursor,
                  ),
                  focusNode: _focusFuncao,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) setState(() => campoSelecionado = 'funcao');
                  },
                ),
                const SizedBox(height: 8),
                _CampoComRotulo(
                  rotulo: 'X0 = ',
                  texto: _getTextoComCursor(
                    campoDoX1,
                    cursorPosX1,
                    campoSelecionado == 'x1' && _mostrarCursor,
                  ),
                  focusNode: _focusX1,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) setState(() => campoSelecionado = 'x1');
                  },
                ),
                const SizedBox(height: 8),
                _CampoComRotulo(
                  rotulo: 'Aprox = ',
                  texto: _getTextoComCursor(
                    campoDeAproximacao,
                    cursorPosAproximacao,
                    campoSelecionado == 'aproximacao' && _mostrarCursor,
                  ),
                  focusNode: _focusAproximacao,
                  onFocusChange: (hasFocus) {
                    if (hasFocus)
                      setState(() => campoSelecionado = 'aproximacao');
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (campoDeFuncao.isNotEmpty &&
                  campoDoX1.isNotEmpty &&
                  campoDeAproximacao.isNotEmpty) {
                calcularRaizNewton(
                  context,
                  campoDeFuncao,
                  campoDoX1,
                  campoDeAproximacao,
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Erro'),
                    content: const Text(
                        'Preencha todos os campos antes de calcular.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Calcular'),
          ),
          const Spacer(),
          Container(
            color: Colors.deepPurple,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: tecladoNumerico.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
              ),
              itemBuilder: (context, index) {
                return meuBotao(
                  child: tecladoNumerico[index],
                  onTap: () {
                    botaoFoiApertado(tecladoNumerico[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoComRotulo extends StatelessWidget {
  final String rotulo;
  final String texto;
  final FocusNode focusNode;
  final Function(bool) onFocusChange;

  const _CampoComRotulo({
    required this.rotulo,
    required this.texto,
    required this.focusNode,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontSize: 30, // Maior visibilidade
              fontWeight: FontWeight.bold, // Negrito
              fontStyle: FontStyle.italic, // Itálico
              color: Colors.white, // Melhor contraste
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Espaço entre rótulo e campo
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: focusNode.hasFocus ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                texto.isEmpty ? "" : texto, // Placeholder
                style: TextStyle(
                  fontSize: 20, // Aumentar fonte
                  fontWeight: FontWeight.bold, // Negrito
                  fontFamily: 'Courier', // Fonte Monospace
                  color: Colors.white, // Melhor contraste
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
