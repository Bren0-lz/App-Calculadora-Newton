import 'package:math_expressions/math_expressions.dart';

class IteracaoNewton {
  final int n;
  final double xn;
  final double fx;

  IteracaoNewton(this.n, this.xn, this.fx);
}

String prepararParaCalculo(String tex) {
  return tex
      .replaceAll('{', '(')
      .replaceAll('}', ')')
      .replaceAll(r'\sin', 'sin')
      .replaceAll(r'\cos', 'cos')
      .replaceAll(r'\cdot', '*');
}

// Classe para retornar o resultado completo
class ResultadoNewton {
  final String valorFinal;
  final List<IteracaoNewton> historico;

  ResultadoNewton(this.valorFinal, this.historico);
}

class NewtonLogic {
  static String converterParaLatex(String texto) {
    if (texto.isEmpty) return "";

    String latex = texto;

    // Substituições básicas de sintaxe
    latex = latex.replaceAll('*', r' \cdot ');
    latex = latex.replaceAll('x', r'x');

    // Funções Trigonométricas
    latex = latex.replaceAll('sen', r'\sin');
    latex = latex.replaceAll('cos', r'\cos');
    latex = latex.replaceAll('tg', r'\tan');

    // Potência: transforma x^2 em x^{2}
    // Nota: Para potências complexas, um Regex seria necessário
    RegExp exp = RegExp(r"\^(\w+|\(.+?\))");
    latex = latex.replaceAllMapped(exp, (match) => "^{${match.group(1)}}");

    return latex;
  }

  // Agora recebemos a Expression diretamente, sem precisar de novo Parser
  static ResultadoNewton calcularRaiz(
      Expression exp, double x0, double tolerancia) {
    List<IteracaoNewton> historico = [];
    try {
      ContextModel cm = ContextModel();
      Variable x = Variable('x');

      // A derivada agora é gerada diretamente da Expression recebida
      Expression derivada = exp.derive('x');

      double xn = x0;
      int i = 0;
      while (i < 50) {
        cm.bindVariable(x, Number(xn));
        double fx = exp.evaluate(EvaluationType.REAL, cm);

        historico.add(IteracaoNewton(i, xn, fx));

        double fDashx = derivada.evaluate(EvaluationType.REAL, cm);
        if (fDashx.abs() < 1e-10)
          return ResultadoNewton("Erro: Derivada Nula", historico);

        double proxXn = xn - (fx / fDashx);
        if ((proxXn - xn).abs() < tolerancia) {
          // Última iteração de sucesso
          cm.bindVariable(x, Number(proxXn));
          historico.add(IteracaoNewton(
              i + 1, proxXn, exp.evaluate(EvaluationType.REAL, cm)));
          return ResultadoNewton(proxXn.toStringAsFixed(6), historico);
        }
        xn = proxXn;
        i++;
      }
      return ResultadoNewton(xn.toStringAsFixed(6), historico);
    } catch (e) {
      return ResultadoNewton("Erro no Cálculo: $e", []);
    }
  }
}
