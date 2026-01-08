import 'package:flutter/material.dart';
import 'logic/newton_logic.dart'; // Import da lógica de cálculo
import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _EstadoPaginaTeste();
}

class _EstadoPaginaTeste extends State<PaginaTeste> {
  // --- Estados dos campos e navegação ---

  final _controllerFuncao = MathFieldEditingController();
  final _controllerX0 = MathFieldEditingController();
  final _controllerAprox = MathFieldEditingController();
  final _focusFuncao = FocusNode();
  final _focusX1 = FocusNode();
  final _focusAprox = FocusNode();

  // Variável para saber qual campo está com foco (para o efeito visual de escala)
  String campoAtivo = 'funcao';

  @override
  void initState() {
    super.initState();
    // Listener para garantir que a UI mude assim que o foco for solicitado
    _focusFuncao
        .addListener(() => _atualizarFoco('funcao', _focusFuncao.hasFocus));
    _focusX1.addListener(() => _atualizarFoco('x1', _focusX1.hasFocus));
    _focusAprox
        .addListener(() => _atualizarFoco('aproximacao', _focusAprox.hasFocus));
  }

  void _atualizarFoco(String id, bool temFoco) {
    if (temFoco) {
      setState(() => campoAtivo = id);
      // Remove foco de outros campos
      if (id != 'funcao') _focusFuncao.unfocus();
      if (id != 'x1') _focusX1.unfocus();
      if (id != 'aproximacao') _focusAprox.unfocus();
    }
  }

  List<IteracaoNewton> _historico = [];

  // --- Paleta de Cores e Estilo ---
  final Color _corFundoPreto = const Color(0xFF121212);
  final Color _corAzulDisplay = const Color(0xFF2D85C4);

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

  Widget _buildLinhaMatematica({
    required String label,
    required MathFieldEditingController controller,
    required FocusNode focusNode,
    required String campoID,
    required String hint,
    required Function(String)
        aoMudar, // Este é o parâmetro que o compilador sentiu falta
    required String valorRaw,
  }) {
    bool estaAtivo = campoAtivo == campoID;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => campoAtivo = campoID);
        // Pequeno atraso para garantir que o widget MathField seja montado antes do foco
        Future.delayed(
            const Duration(milliseconds: 50), () => focusNode.requestFocus());
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: estaAtivo ? 20 : 8),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withOpacity(estaAtivo ? 1.0 : 0.4),
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: estaAtivo
                    ? MathField(
                        key: ValueKey('active_$campoID'),
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: aoMudar,
                        variables: const ['x'],
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.1)),
                          border: InputBorder.none,
                        ),
                      )
                    : Math.tex(
                        // Renderiza o LaTeX nativamente (ex: x²) sem cursor
                        valorRaw.isEmpty ? hint : valorRaw,
                        mathStyle: MathStyle.display,
                        textStyle: TextStyle(
                          color: Colors.white
                              .withOpacity(valorRaw.isEmpty ? 0.2 : 0.2),
                          fontSize: 25,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Variáveis para guardar o texto puro (LaTeX)
  String _funcaoRaw = 'x^{2}-4';
  String _x0Raw = '1';
  String _aproxRaw = '0.001';

  void _executarCalculo() {
    // Remove o foco de qualquer campo antes de processar o Newton-Raphson
    FocusScope.of(context).unfocus();

    // 1. Verificação rigorosa
    if (_funcaoRaw.isEmpty ||
        _funcaoRaw == '{}' ||
        _x0Raw.isEmpty ||
        _aproxRaw.isEmpty) {
      _mostrarErro("Preencha todos os campos antes de calcular.");
      return;
    }

    try {
      // 2. Forçar minúsculas para o 'x' não ser lido como constante 'X'
      final String fProcessada = _funcaoRaw.toLowerCase();

      // 3. Conversão segura para o motor de cálculo
      final Expression fExpression = TeXParser(fProcessada).parse();
      final double x0 = double.parse(TeXParser(_x0Raw).parse().toString());
      final double aprox =
          double.parse(TeXParser(_aproxRaw).parse().toString());

      ResultadoNewton resultado =
          NewtonLogic.calcularRaiz(fExpression, x0, aprox);

      setState(() => _historico = resultado.historico);
      _mostrarTabelaIteracoes(context);
    } catch (e) {
      print("ERRO DE ENGENHARIA: $e");
      _mostrarErro(
          "Erro de sintaxe. Algum campo pode estar incorreto ou vazio.");
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos se algum dos campos está com foco real
    bool tecladoAberto =
        _focusFuncao.hasFocus || _focusX1.hasFocus || _focusAprox.hasFocus;

    return MathKeyboardViewInsets(
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Garante que o Scaffold reaja ao teclado
        backgroundColor: _corFundoPreto,
        body: Column(
          children: [
            // --- 1. ÁREA DO DISPLAY AZUL (Estilo GeoGebra/Photomath) ---
            Expanded(
              flex: tecladoAberto
                  ? 10
                  : 5, // Aumenta o display quando teclado abre
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
                    _buildLinhaMatematica(
                      label: "f(x) = ",
                      controller: _controllerFuncao,
                      focusNode: _focusFuncao,
                      campoID: 'funcao',
                      hint: "x^2 - 4",
                      valorRaw: _funcaoRaw,
                      aoMudar: (val) =>
                          setState(() => _funcaoRaw = val), // ADICIONADO
                    ),
                    _buildLinhaMatematica(
                      label: "X0 = ",
                      controller: _controllerX0,
                      focusNode: _focusX1,
                      campoID: 'x1',
                      hint: "1.0",
                      valorRaw: _x0Raw,
                      aoMudar: (val) =>
                          setState(() => _x0Raw = val), // ADICIONADO
                    ),
                    _buildLinhaMatematica(
                      label: "Aprox = ",
                      controller: _controllerAprox,
                      focusNode: _focusAprox,
                      campoID: 'aproximacao',
                      hint: "0.001",
                      valorRaw: _aproxRaw,
                      aoMudar: (val) =>
                          setState(() => _aproxRaw = val), // ADICIONADO
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. ÁREA DOS BOTÕES (Seu teclado customizado) ---
            Expanded(
              flex: 7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão Principal de Calcular
                    GestureDetector(
                      onTap: _executarCalculo,
                      child: Container(
                        width: 250,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _corAzulDisplay,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 40),
                            SizedBox(width: 10),
                            Text(
                              "CALCULAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "O resultado será exibido em uma tabela detalhada.",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
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
