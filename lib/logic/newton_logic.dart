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

  static ResultadoNewton calcularRaiz(
      String fString, String x0String, String aproxString) {
    List<IteracaoNewton> historico = [];
    try {
      Parser p = Parser();
      ContextModel cm = ContextModel();
      Variable x = Variable('x');
      Expression exp = p.parse(fString);
      Expression derivada = exp.derive('x');

      double xn = double.parse(x0String.replaceAll(',', '.'));
      double tolerancia = double.parse(aproxString.replaceAll(',', '.'));

      int i = 0;
      while (i < 50) {
        cm.bindVariable(x, Number(xn));
        double fx = exp.evaluate(EvaluationType.REAL, cm);

        // Salvamos a iteração atual
        historico.add(IteracaoNewton(i, xn, fx));

        double fDashx = derivada.evaluate(EvaluationType.REAL, cm);
        if (fDashx.abs() < 1e-10)
          return ResultadoNewton("Erro: Derivada Nula", historico);

        double proxXn = xn - (fx / fDashx);
        if ((proxXn - xn).abs() < tolerancia) {
          historico.add(IteracaoNewton(
              i + 1,
              proxXn,
              exp.evaluate(
                  EvaluationType.REAL, cm..bindVariable(x, Number(proxXn)))));
          return ResultadoNewton(proxXn.toStringAsFixed(6), historico);
        }
        xn = proxXn;
        i++;
      }
      return ResultadoNewton(xn.toStringAsFixed(6), historico);
    } catch (e) {
      return ResultadoNewton("Erro de Sintaxe", []);
    }
  }
}
