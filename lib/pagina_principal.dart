import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/botao_calculadora.dart'; // Import do componente refatorado
import 'logic/newton_logic.dart'; // Import da lógica de cálculo

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _EstadoPaginaTeste();
}

class _EstadoPaginaTeste extends State<PaginaTeste> {
  // --- Estados dos campos e navegação ---
  String campoSelecionado = 'funcao';
  String campoDeFuncao = '';
  String campoDoX1 = '';
  String campoDeAproximacao = '';
  String resultado = '';

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

  @override
  void initState() {
    super.initState();
    _iniciarCursorPiscando();
  }

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

  Color _getCorBotao(String label) {
    if (label == 'X') return _corBtnX;
    if (label == '⌫') return _corBtnDelete;
    if (label == '↵') return _corBtnEnter;
    if ('+-*/^().'.contains(label) || label == '()') return _corBtnOperador;
    return _corBtnNumero;
  }

  void botaoFoiApertado(String botao) {
    setState(() {
      String textoAtual = _getTextoAtual();
      int pos = _getPosCursorAtual();

      if (botao == '⌫') {
        if (textoAtual.isNotEmpty && pos > 0) {
          textoAtual =
              textoAtual.substring(0, pos - 1) + textoAtual.substring(pos);
          pos--;
        }
      } else if (botao == '↵') {
        _navegarOuCalcular();
        return;
      } else {
        String inserir = (botao == 'X') ? 'x' : botao;
        textoAtual =
            textoAtual.substring(0, pos) + inserir + textoAtual.substring(pos);
        pos += inserir.length;
      }

      _atualizarTextoEPosicao(textoAtual, pos);
      resultado = ''; // Limpa resultado ao editar
    });
  }

  // Auxiliares de estado para simplificar o código
  String _getTextoAtual() {
    if (campoSelecionado == 'funcao') return campoDeFuncao;
    if (campoSelecionado == 'x1') return campoDoX1;
    return campoDeAproximacao;
  }

  int _getPosCursorAtual() {
    if (campoSelecionado == 'funcao') return cursorPosFuncao;
    if (campoSelecionado == 'x1') return cursorPosX1;
    return cursorPosAproximacao;
  }

  void _atualizarTextoEPosicao(String novoTexto, int novaPos) {
    if (campoSelecionado == 'funcao') {
      campoDeFuncao = novoTexto;
      cursorPosFuncao = novaPos;
    } else if (campoSelecionado == 'x1') {
      campoDoX1 = novoTexto;
      cursorPosX1 = novaPos;
    } else {
      campoDeAproximacao = novoTexto;
      cursorPosAproximacao = novaPos;
    }
  }

  void _navegarOuCalcular() {
    if (campoSelecionado == 'funcao') {
      campoSelecionado = 'x1';
    } else if (campoSelecionado == 'x1') {
      campoSelecionado = 'aproximacao';
    } else {
      // Agora recebemos o objeto completo
      final res = NewtonLogic.calcularRaiz(
          campoDeFuncao, campoDoX1, campoDeAproximacao);
      setState(() {
        resultado = res.valorFinal;
        _historico = res.historico;
      });
    }
  }

  void _limparTudo() {
    setState(() {
      campoDeFuncao = '';
      campoDoX1 = '';
      campoDeAproximacao = '';
      resultado = '';
      _historico = []; // Limpa também a tabela de iterações
      cursorPosFuncao = 0;
      cursorPosX1 = 0;
      cursorPosAproximacao = 0;
      campoSelecionado = 'funcao'; // Volta o foco para o início
    });

    // Feedback tátil ou visual opcional
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sistema reiniciado!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // --- Componentes do Display ---

  Widget _buildLinhaDisplay(
      {required String label, required String valor, required String campoID}) {
    bool estaAtivo = campoSelecionado == campoID;
    double tamanhoFonte = estaAtivo ? 45 : 32;
    double opacidade = estaAtivo ? 1.0 : 0.5;
    int pos = (campoID == 'funcao')
        ? cursorPosFuncao
        : (campoID == 'x1')
            ? cursorPosX1
            : cursorPosAproximacao;

    return GestureDetector(
      onTap: () => setState(() => campoSelecionado = campoID),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding:
            EdgeInsets.symmetric(vertical: estaAtivo ? 8 : 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                  color: Colors.white.withOpacity(opacidade * 0.6),
                  fontSize: tamanhoFonte * 0.6,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Arial'),
              child: Text(label),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                      color: Colors.white.withOpacity(opacidade),
                      fontSize: tamanhoFonte,
                      fontWeight: estaAtivo ? FontWeight.bold : FontWeight.w400,
                      fontFamily: 'Arial'),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: valor.substring(0, pos)),
                      TextSpan(
                          text: '|',
                          style: TextStyle(
                              color: (estaAtivo && _mostrarCursor)
                                  ? Colors.white
                                  : Colors.transparent)),
                      TextSpan(text: valor.substring(pos)),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                                        // Forçamos a cor branca em cada célula
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
    return Scaffold(
      backgroundColor: _corFundoPreto,
      body: Column(
        children: [
          // --- 1. Área do DISPLAY DINÂMICO ---
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
                  _buildLinhaDisplay(
                    label: "f(x) = ",
                    valor: campoDeFuncao,
                    campoID: 'funcao',
                  ),
                  _buildLinhaDisplay(
                    label: "X0 = ",
                    valor: campoDoX1,
                    campoID: 'x1',
                  ),
                  _buildLinhaDisplay(
                    label: "Aprox = ",
                    valor: campoDeAproximacao,
                    campoID: 'aproximacao',
                  ),

                  // RESULTADO INTERATIVO
                  if (resultado.isNotEmpty) ...[
                    const Divider(color: Colors.white24, height: 30),
                    InkWell(
                      onTap: () => _mostrarTabelaIteracoes(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Raiz ≈ ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Arial',
                              ),
                            ),
                            Text(
                              resultado,
                              style: const TextStyle(
                                color: Color(0xFFFFF176),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.analytics_outlined,
                              color: Color(0xFFFFF176),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- 2. Botão da Gaveta (Seta com Glow) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: _corFundoPreto,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _corAzulDisplay.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: _corAzulDisplay.withOpacity(0.2)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _gavetaAberta = !_gavetaAberta),
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _gavetaAberta ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _corAzulDisplay,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- 3. Área do Teclado e Gaveta ---
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Teclado Principal
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: novoTeclado.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final label = novoTeclado[index];
                          return BotaoCalculadora(
                            label: label,
                            color: _getCorBotao(label),
                            onTap: () => botaoFoiApertado(label),
                            // Se o botão for o de apagar, adiciona o clique longo
                            onLongPress: label == '⌫' ? _limparTudo : null,
                          );
                        },
                      ),
                    ),

                    // Gaveta Animada (Funções Avançadas)
                    ClipRect(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: _gavetaAberta ? constraints.maxHeight : 0,
                        width: double.infinity,
                        color: _corFundoPreto,
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: funcoesAvancadas.length,
                          itemBuilder: (context, index) {
                            final label = funcoesAvancadas[index];
                            return BotaoCalculadora(
                              label: label,
                              color: _corBtnOperador.withOpacity(0.8),
                              onTap: () {
                                botaoFoiApertado(label);
                                setState(() => _gavetaAberta = false);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
