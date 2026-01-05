import 'package:math_expressions/math_expressions.dart';

class IteracaoNewton {
  final int n;
  final double xn;
  final double fx;

  IteracaoNewton(this.n, this.xn, this.fx);
}

// Classe para retornar o resultado completo
class ResultadoNewton {
  final String valorFinal;
  final List<IteracaoNewton> historico;

  ResultadoNewton(this.valorFinal, this.historico);
}

class NewtonLogic {
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
