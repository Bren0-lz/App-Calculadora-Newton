import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/botao_calculadora.dart'; // Import do componente refatorado
import 'logic/newton_logic.dart'; // Import da lógica de cálculo
import 'package:math_keyboard/math_keyboard.dart';

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _EstadoPaginaTeste();
}

class _EstadoPaginaTeste extends State<PaginaTeste> {
  // --- Estados dos campos e navegação ---
  // Substitua suas strings antigas por estas:
  final _controllerFuncao = MathFieldEditingController();
  final _controllerX0 = MathFieldEditingController();
  final _controllerAprox = MathFieldEditingController();

// Variável para saber qual campo está com foco (para o efeito visual de escala)
  String campoAtivo = 'funcao';

  // Adicione os FocusNodes junto aos controladores
  final _focusFuncao = FocusNode();
  final _focusX1 = FocusNode();
  final _focusAprox = FocusNode();

  @override
  void initState() {
    super.initState();
    // Listeners para atualizar o zoom do display quando o foco mudar
    _focusFuncao
        .addListener(() => _atualizarFoco('funcao', _focusFuncao.hasFocus));
    _focusX1.addListener(() => _atualizarFoco('x1', _focusX1.hasFocus));
    _focusAprox
        .addListener(() => _atualizarFoco('aproximacao', _focusAprox.hasFocus));
  }

  void _atualizarFoco(String id, bool temFoco) {
    if (temFoco) setState(() => campoAtivo = id);
  }

  List<IteracaoNewton> _historico = [];

  // Posições do cursor para cada campo
  int cursorPosFuncao = 0;
  int cursorPosX1 = 0;
  int cursorPosAproximacao = 0;

  // Controle do cursor e gaveta
  bool _mostrarCursor = true;
  bool _gavetaAberta = false;
  Timer? _timerCursor;

  // --- Paleta de Cores e Estilo ---
  final Color _corFundoPreto = const Color(0xFF121212);
  final Color _corAzulDisplay = const Color(0xFF2D85C4);
  final Color _corBtnNumero = const Color(0xFFE3F2FD);
  final Color _corBtnOperador = const Color(0xFFBBDEFB);
  final Color _corBtnX = const Color(0xFF90CAF9);
  final Color _corBtnDelete = const Color(0xFFEF9A9A);
  final Color _corBtnEnter = const Color(0xFFA5D6A7);

  // Layouts dos teclados
  final List<String> novoTeclado = [
    'X',
    '+',
    '7',
    '8',
    '9',
    '^',
    '-',
    '4',
    '5',
    '6',
    '()',
    '*',
    '1',
    '2',
    '3',
    '/',
    '.',
    '⌫',
    '0',
    '↵',
  ];

  final List<String> funcoesAvancadas = [
    'sen',
    'cos',
    'tg',
    'mod',
    'csc',
    'sec',
    'cot',
    '√',
    'ln',
    'log',
    'e',
    'π'
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _iniciarCursorPiscando();
  // }

  @override
  void dispose() {
    _timerCursor?.cancel();
    super.dispose();
  }

  void _iniciarCursorPiscando() {
    _timerCursor = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _mostrarCursor = !_mostrarCursor);
    });
  }

  // --- Lógica de Interface ---
//
//   Color _getCorBotao(String label) {
//     if (label == 'X') return _corBtnX;
//     if (label == '⌫') return _corBtnDelete;
//     if (label == '↵') return _corBtnEnter;
//     if ('+-*/^().'.contains(label) || label == '()') return _corBtnOperador;
//     return _corBtnNumero;
//   }

//   void botaoFoiApertado(String botao) {
//     setState(() {
//       String textoAtual = _getTextoAtual();
//       int pos = _getPosCursorAtual();

//       if (botao == '⌫') {
//         if (textoAtual.isNotEmpty && pos > 0) {
//           textoAtual =
//               textoAtual.substring(0, pos - 1) + textoAtual.substring(pos);
//           pos--;
//         }
//       } else if (botao == '↵') {
//         _navegarOuCalcular();
//         return;
//       } else {
//         String inserir = (botao == 'X') ? 'x' : botao;
//         textoAtual =
//             textoAtual.substring(0, pos) + inserir + textoAtual.substring(pos);
//         pos += inserir.length;
//       }

//       _atualizarTextoEPosicao(textoAtual, pos);
//       resultado = ''; // Limpa resultado ao editar
//     });
//   }

//   // Auxiliares de estado para simplificar o código
//   String _getTextoAtual() {
//     if (campoSelecionado == 'funcao') return campoDeFuncao;
//     if (campoSelecionado == 'x1') return campoDoX1;
//     return campoDeAproximacao;
//   }

//   int _getPosCursorAtual() {
//     if (campoSelecionado == 'funcao') return cursorPosFuncao;
//     if (campoSelecionado == 'x1') return cursorPosX1;
//     return cursorPosAproximacao;
//   }

//   void _atualizarTextoEPosicao(String novoTexto, int novaPos) {
//     if (campoSelecionado == 'funcao') {
//       campoDeFuncao = novoTexto;
//       cursorPosFuncao = novaPos;
//     } else if (campoSelecionado == 'x1') {
//       campoDoX1 = novoTexto;
//       cursorPosX1 = novaPos;
//     } else {
//       campoDeAproximacao = novoTexto;
//       cursorPosAproximacao = novaPos;
//     }
//   }

//   void _navegarOuCalcular() {
//     if (campoSelecionado == 'funcao') {
//       campoSelecionado = 'x1';
//     } else if (campoSelecionado == 'x1') {
//       campoSelecionado = 'aproximacao';
//     } else {
//       // Agora recebemos o objeto completo
//       final res = NewtonLogic.calcularRaiz(
//           campoDeFuncao, campoDoX1, campoDeAproximacao);
//       setState(() {
//         resultado = res.valorFinal;
//         _historico = res.historico;
//       });
//     }
//   }

//   void _limparTudo() {
//     setState(() {
//       campoDeFuncao = '';
//       campoDoX1 = '';
//       campoDeAproximacao = '';
//       resultado = '';
//       _historico = []; // Limpa também a tabela de iterações
//       cursorPosFuncao = 0;
//       cursorPosX1 = 0;
//       cursorPosAproximacao = 0;
//       campoSelecionado = 'funcao'; // Volta o foco para o início
//     });

//     // Feedback tátil ou visual opcional
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Sistema reiniciado!'),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }

  // --- Componentes do Display ---
  Widget _buildLinhaMatematica({
    required String label,
    required MathFieldEditingController controller,
    required FocusNode focusNode,
    required String campoID,
    required String hint,
  }) {
    bool estaAtivo = campoAtivo == campoID;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: estaAtivo ? 12 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(estaAtivo ? 0.9 : 0.4),
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: DefaultTextStyle(
              // SOLUÇÃO DO 'style': O MathField herda deste estilo
              style: TextStyle(
                color: Colors.white,
                fontSize: estaAtivo ? 38 : 26,
              ),
              child: MathField(
                controller: controller,
                focusNode: focusNode, // SOLUÇÃO DO 'onTap'
                variables: const ['x'],
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoMatematico({
    required String label,
    required MathFieldEditingController controller,
    String hint = "",
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              // SOLUÇÃO PARA O ESTILO: Envolver em DefaultTextStyle
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white, fontSize: 22),
                child: MathField(
                  controller: controller,
                  variables: const ['x'],
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) {
                    // SOLUÇÃO PARA O TEXSTRING: 'value' já é a String em formato TeX
                    print("Fórmula em TeX: $value");
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarTabelaIteracoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Fundo escuro
      isScrollControlled:
          true, // Permite que o bottom sheet ocupe mais espaço se necessário
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.6, // Define 60% da altura da tela
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Histórico de Iterações",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial'),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _historico.isEmpty
                    ? const Center(
                        child: Text("Nenhuma iteração registrada",
                            style: TextStyle(color: Colors.white54)))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          // Scroll horizontal caso os números sejam grandes
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 35,
                            columns: const [
                              DataColumn(
                                  label: Text("n",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("xn",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("f(xn)",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: _historico
                                .map((it) => DataRow(
                                      cells: [
                                        DataCell(Text(it.n.toString(),
                                            style: const TextStyle(
                                                color: Colors.white))),
                                        DataCell(Text(it.xn.toStringAsFixed(6),
                                            style: const TextStyle(
                                                color: Colors.white))),
                                        DataCell(Text(
                                            it.fx.toStringAsExponential(2),
                                            style: const TextStyle(
                                                color: Colors.white))),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // O MathKeyboardView deve envolver o Scaffold para o teclado funcionar
    return MathKeyboardViewInsets(
      child: Scaffold(
        backgroundColor: _corFundoPreto,
        body: Column(
          children: [
            // --- 1. ÁREA DO DISPLAY AZUL (Estilo GeoGebra/Photomath) ---
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _corAzulDisplay,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(28, 50, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dentro da sua Column no display azul:
                    _buildLinhaMatematica(
                      label: "f(x) = ",
                      controller: _controllerFuncao,
                      focusNode: _focusFuncao,
                      campoID: 'funcao',
                      hint: "x^2 - 4",
                    ),
                    _buildLinhaMatematica(
                      label: "X0 = ",
                      controller: _controllerX0,
                      focusNode: _focusX1,
                      campoID: 'x1',
                      hint: "1.0",
                    ),
                    _buildLinhaMatematica(
                      label: "Aprox = ",
                      controller: _controllerAprox,
                      focusNode: _focusAprox,
                      campoID: 'aproximacao',
                      hint: "0.001",
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. ÁREA DOS BOTÕES (Seu teclado customizado) ---
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Aqui entram as suas linhas de botões (7, 8, 9, /, etc.)
                    // Dica: Use o seu _buildLinhaBotoes aqui
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
