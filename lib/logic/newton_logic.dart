import 'package:math_expressions/math_expressions.dart';

// Modelo para cada linha da tabela de iterações
class IteracaoNewton {
  final int n;
  final double xn;
  final double fx;

  // Construtor nomeado para evitar erros de posição
  IteracaoNewton({required this.n, required this.xn, required this.fx});
}

// Modelo para o resultado final do cálculo
class ResultadoNewton {
  final double valorFinal;
  final List<IteracaoNewton> historico;
  final bool sucesso;

  ResultadoNewton(
      {required this.valorFinal,
      required this.historico,
      required this.sucesso});
}

class NewtonLogic {
  /// Converte texto simples para o formato LaTeX (ex: x^2 vira x^{2})
  static String converterParaLatex(String texto) {
    if (texto.isEmpty) return "";

    String latex = texto;

    // Substituições básicas de sintaxe
    latex = latex.replaceAll('*', r' \cdot ');

    // Funções Trigonométricas
    latex = latex.replaceAll('sen', r'\sin');
    latex = latex.replaceAll('cos', r'\cos');
    latex = latex.replaceAll('tg', r'\tan');

    // Potência: garante que o expoente fique entre chaves {}
    RegExp exp = RegExp(r"\^(\w+|\(.+?\))");
    latex = latex.replaceAllMapped(exp, (match) => "^{${match.group(1)}}");

    return latex;
  }

  /// Executa o Algoritmo de Newton-Raphson
  static ResultadoNewton calcularRaiz(Expression f, double x0, double aprox,
      {int maxIteracoes = 100} // Trava de segurança contra loops infinitos
      ) {
    List<IteracaoNewton> historico = [];
    double xn = x0;
    int contador = 0;

    // Definição da variável e sua derivada simbólica
    Variable x = Variable('x');
    Expression derivada = f.derive('x');

    // Loop do Método Numérico
    while (contador < maxIteracoes) {
      ContextModel cm = ContextModel()..bindVariable(x, Number(xn));

      double fx = f.evaluate(EvaluationType.REAL, cm);
      double dfx = derivada.evaluate(EvaluationType.REAL, cm);

      // Registra o estado atual na lista de histórico
      historico.add(IteracaoNewton(n: contador, xn: xn, fx: fx));

      // Critério de Parada: f(x) suficientemente próximo de zero
      if (fx.abs() < aprox) {
        return ResultadoNewton(
            valorFinal: xn, historico: historico, sucesso: true);
      }

      // Prevenção de divisão por zero (Derivada Nula)
      if (dfx == 0) {
        throw Exception("Derivada nula em x = $xn. O método divergiu.");
      }

      // Aplicação da fórmula: x_{n+1} = x_n - f(x_n) / f'(x_n)
      xn = xn - (fx / dfx);
      contador++;
    }

    // Se atingir o limite sem convergir, lança erro para a UI capturar
    throw Exception(
        "O método não convergiu após $maxIteracoes iterações. Tente outro X0.");
  }
}
