import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1_teste/util/teclado_numerico.dart';
import 'package:flutter_application_1_teste/util/campo_de_texto.dart';
import 'calculo.dart'; // Importa o cálculo de Newton

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PaginaTeste(),
  ));
}

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _EstadoPaginaTeste();
}

class _EstadoPaginaTeste extends State<PaginaTeste> {
  // --- Estados dos campos de texto (Mantidos) ---
  String campoSelecionado = 'funcao'; // 'funcao', 'x1' (X0), 'aproximacao'
  String campoDeFuncao = '';
  String campoDoX1 = '';
  String campoDeAproximacao = '';
  String resultado = ''; // Armazena o resultado do cálculo de Newton

  // --- Posições do cursor (Mantidas) ---
  int cursorPosFuncao = 0;
  int cursorPosX1 = 0;
  int cursorPosAproximacao = 0;

  // --- Controle do cursor (Mantido) ---
  bool _mostrarCursor = true;
  Timer? _timerCursor;

  // NOVO: Controla se a gaveta de funções extras está visível
  bool _gavetaAberta = false;

// --- Paleta de Cores ---
  final Color _corFundoPreto = const Color(0xFF121212);
  final Color _corAzulDisplay = const Color(0xFF2D85C4);

  final Color _corBtnNumero = const Color(0xFFE3F2FD);
  final Color _corBtnOperador = const Color(0xFFBBDEFB);
  final Color _corBtnX = const Color(0xFF90CAF9);

  // NOVAS CORES:
  final Color _corBtnDelete = const Color(0xFFEF9A9A); // Vermelho claro suave
  final Color _corBtnEnter = const Color(0xFFA5D6A7); // Verde claro suave

  // --- NOVO Layout do Teclado (5x4) ---
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
    'π',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarCursorPiscando();
    // Define a cor da barra de status do sistema
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: _corAzulDisplay,
    ));
  }

  @override
  void dispose() {
    _timerCursor?.cancel();
    super.dispose();
  }

  void _iniciarCursorPiscando() {
    _timerCursor = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _mostrarCursor = !_mostrarCursor;
      });
    });
  }

  String _getTextoComCursor(String texto, int posCursor, bool mostrarCursor) {
    if (!mostrarCursor) return texto;
    // Usa um caractere de cursor mais sutil
    return '${texto.substring(0, posCursor)}|${texto.substring(posCursor)}';
  }

  // --- NOVA Função auxiliar para obter o texto e rótulo do campo atual ---
  (String label, String valorComCursor) _getDadosCampoAtual() {
    String texto = '';
    int cursor = 0;
    String label = '';

    switch (campoSelecionado) {
      case 'funcao':
        texto = campoDeFuncao;
        cursor = cursorPosFuncao;
        label = 'f(x) =';
        break;
      case 'x1':
        texto = campoDoX1;
        cursor = cursorPosX1;
        label = 'X0 =';
        break;
      case 'aproximacao':
        texto = campoDeAproximacao;
        cursor = cursorPosAproximacao;
        label = 'Aprox =';
        break;
    }
    return (label, _getTextoComCursor(texto, cursor, _mostrarCursor));
  }

  // --- Lógica do botão simplificada para o novo teclado ---
  void botaoFoiApertado(String botao) {
    setState(() {
      // Referências para o campo e cursor ativos
      String textoAtual;
      int posCursorAtual;

      if (campoSelecionado == 'funcao') {
        textoAtual = campoDeFuncao;
        posCursorAtual = cursorPosFuncao;
      } else if (campoSelecionado == 'x1') {
        textoAtual = campoDoX1;
        posCursorAtual = cursorPosX1;
      } else {
        textoAtual = campoDeAproximacao;
        posCursorAtual = cursorPosAproximacao;
      }

      // Lógica de ação
      if (botao == '⌫') {
        if (textoAtual.isNotEmpty && posCursorAtual > 0) {
          textoAtual = textoAtual.substring(0, posCursorAtual - 1) +
              textoAtual.substring(posCursorAtual);
          posCursorAtual--;
        }
      } else if (botao == '↵') {
        if (campoSelecionado == 'funcao') {
          campoSelecionado = 'x1';
        } else if (campoSelecionado == 'x1') {
          campoSelecionado = 'aproximacao';
        } else if (campoSelecionado == 'aproximacao') {
          // SE ESTIVER NO ÚLTIMO CAMPO: CALCULA
          _executarCalculo();
        }
        return;
      } else {
        // Inserção de caracteres (números, operadores, X, (), .)
        String textoParaInserir = botao;
        // Se o botão for 'X', insere a variável 'x' minúscula
        if (botao == 'X') textoParaInserir = 'x';

        textoAtual = textoAtual.substring(0, posCursorAtual) +
            textoParaInserir +
            textoAtual.substring(posCursorAtual);
        posCursorAtual += textoParaInserir.length;
      }

      // Atualiza o estado do campo correto
      if (campoSelecionado == 'funcao') {
        campoDeFuncao = textoAtual;
        cursorPosFuncao = posCursorAtual;
      } else if (campoSelecionado == 'x1') {
        campoDoX1 = textoAtual;
        cursorPosX1 = posCursorAtual;
      } else {
        campoDeAproximacao = textoAtual;
        cursorPosAproximacao = posCursorAtual;
      }
    });
  }

  // Função para executar o cálculo (antigo botão "Calcular")
  void _executarCalculo() {
    if (campoDeFuncao.isNotEmpty &&
        campoDoX1.isNotEmpty &&
        campoDeAproximacao.isNotEmpty) {
      // Substitua pelo seu método de cálculo real
      print(
          "Calculando: f(x)=$campoDeFuncao, X0=$campoDoX1, Aprox=$campoDeAproximacao");
      // calcularRaizNewton(context, campoDeFuncao, campoDoX1, campoDeAproximacao);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculando... (Verifique o console)')));
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro', style: TextStyle(color: Colors.black)),
          content: const Text(
              'Preencha todos os campos (f(x), X0 e Aprox) antes de calcular.',
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _abrirGaveta(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _corFundoPreto,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.4, // 40% da tela
          child: Column(
            children: [
              // "Alça" para indicar que pode puxar/fechar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 botões por linha na gaveta
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: funcoesAvancadas.length,
                  itemBuilder: (context, index) {
                    return _BotaoArredondado(
                      label: funcoesAvancadas[index],
                      color: _corBtnOperador,
                      onTap: () {
                        botaoFoiApertado(funcoesAvancadas[index]);
                        Navigator.pop(context); // Fecha a gaveta
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Função para determinar a cor do botão
  Color _getCorBotao(String label) {
    if (label == 'X') return _corBtnX;

    // NOVAS VERIFICAÇÕES:
    if (label == '⌫') return _corBtnDelete; // Vermelho para deletar
    if (label == '↵') return _corBtnEnter; // Verde para enter/próximo

    if ('+-*/^().'.contains(label) || label == '()') {
      return _corBtnOperador;
    }
    return _corBtnNumero;
  }

  Widget _buildLinhaDisplay({
    required String label,
    required String valor,
    required String campoID,
  }) {
    bool estaAtivo = campoSelecionado == campoID;

    // NOVAS PROPORÇÕES: Mais equilibradas para leitura
    double tamanhoFonte = estaAtivo ? 45 : 32;
    double opacidade =
        estaAtivo ? 1.0 : 0.5; // Aumentei a opacidade inativa também

    int posCursor = 0;
    if (campoID == 'funcao') posCursor = cursorPosFuncao;
    if (campoID == 'x1') posCursor = cursorPosX1;
    if (campoID == 'aproximacao') posCursor = cursorPosAproximacao;

    return GestureDetector(
      onTap: () => setState(() => campoSelecionado = campoID),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic, // Curva de animação mais suave
        padding:
            EdgeInsets.symmetric(vertical: estaAtivo ? 8 : 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Rótulo animado (f(x), X0, etc)
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: Colors.white.withOpacity(opacidade * 0.6),
                fontSize:
                    tamanhoFonte * 0.6, // Segue o tamanho da fonte principal
                fontStyle: FontStyle.italic,
                fontFamily: 'Arial',
              ),
              child: Text(label),
            ),
            const SizedBox(width: 12),
            // Valor animado com Cursor Estável
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
                    fontFamily: 'Arial',
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: valor.substring(0, posCursor)),
                        TextSpan(
                          text: '|',
                          style: TextStyle(
                            color: (estaAtivo && _mostrarCursor)
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                        TextSpan(text: valor.substring(posCursor)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dadosCampoAtual = _getDadosCampoAtual();

    return Scaffold(
        backgroundColor: _corFundoPreto,
        // Appbar "invisível" só para definir a cor da área da status bar
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: _corAzulDisplay,
          elevation: 0,
        ),
        body: Column(
          children: [
            // --- 1. Área do DISPLAY MULTILINHA ---
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
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // EMPURRA TUDO PARA BAIXO (Próximo ao botão da seta/teclado)
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

                    // O resultado aparece fixo no pé do display se existir
                    if (resultado.isNotEmpty) ...[
                      const Divider(color: Colors.white24),
                      Text(
                        "Raiz ≈ $resultado",
                        style: const TextStyle(
                          color: Color(0xFFFFF176),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- 2. Botão da Gaveta (Seta) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: _corFundoPreto,
                  borderRadius: BorderRadius.circular(20),
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
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: _corAzulDisplay, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 3. Área do Teclado (Mantida a proporção fixa) ---
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
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
                            return _BotaoArredondado(
                              label: label,
                              color: _getCorBotao(label),
                              onTap: () => botaoFoiApertado(label),
                            );
                          },
                        ),
                      ),

                      // Gaveta de Funções (Mantida)
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
                              return _BotaoArredondado(
                                label: funcoesAvancadas[index],
                                color: _corBtnOperador.withOpacity(0.8),
                                onTap: () {
                                  botaoFoiApertado(funcoesAvancadas[index]);
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
        ));
  }
}

class _BotaoArredondado extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BotaoArredondado({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      // Define o arredondamento das bordas.
      // 16 a 20 costuma ser o padrão para o visual do Figma.
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        // É essencial repetir o borderRadius aqui para o efeito de clique
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: label.length > 2
                  ? 20
                  : 26, // Diminui a fonte se o texto for longo (ex: PROX)
              fontWeight: FontWeight.w600,
              color: const Color(
                  0xFF1A237E), // Um azul marinho bem escuro fica mais elegante que o preto puro
            ),
          ),
        ),
      ),
    );
  }
}
