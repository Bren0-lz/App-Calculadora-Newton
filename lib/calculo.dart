import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

String _converterFuncao(String funcao) {
  // Substitui as funções escritas de forma alternativa
  funcao = funcao.replaceAll('mod', 'abs');
  funcao = funcao.replaceAll('√', 'sqrt');
  funcao = funcao.replaceAll('sen', 'sin'); // Converte "sen" para "sin"
  funcao = funcao.replaceAll('tg', 'tan'); // Converte "tg" para "tan"
  funcao = funcao.replaceAll('π', 'pi'); // Converte "π" para "pi"

  // Substitui sec, csc e cot pelas expressões equivalentes
  funcao = funcao.replaceAllMapped(
    RegExp(r'sec\(([^)]+)\)'), // Captura sec(x)
    (match) => '(1 / cos(${match.group(1)}))', // Substitui por 1/cos(x)
  );
  funcao = funcao.replaceAllMapped(
    RegExp(r'csc\(([^)]+)\)'), // Captura csc(x)
    (match) => '(1 / sin(${match.group(1)}))', // Substitui por 1/sin(x)
  );
  funcao = funcao.replaceAllMapped(
    RegExp(r'cot\(([^)]+)\)'), // Captura cot(x)
    (match) => '(1 / tan(${match.group(1)}))', // Substitui por 1/tan(x)
  );
  return funcao;
}

double calcularDerivadaNumerica(
    Expression exp, double x, ContextModel cm, double h) {
  cm.bindVariable(Variable('x'), Number(x + h));
  double fxMaisH = exp.evaluate(EvaluationType.REAL, cm);

  cm.bindVariable(Variable('x'), Number(x - h));
  double fxMenosH = exp.evaluate(EvaluationType.REAL, cm);

  return (fxMaisH - fxMenosH) / (2 * h);
}

void calcularRaizNewton(
    BuildContext context, String funcao, String x1, String tolerancia) {
  try {
    if (funcao.isEmpty) {
      throw Exception('A função não foi fornecida.');
    }

    // Converte a função para o formato reconhecido pela math_expressions
    funcao = _converterFuncao(funcao);

    Parser parser = Parser();
    Expression exp;
    try {
      exp = parser.parse(funcao);
    } catch (e) {
      throw Exception('Erro ao analisar a função. Verifique a expressão.');
    }

    Expression? derivada;
    try {
      derivada = exp.derive('x').simplify();
    } catch (e) {
      derivada = null;
    }

    double xAtual = double.tryParse(x1) ??
        (throw Exception('Valor inicial (X1) inválido.'));
    double tol = double.tryParse(tolerancia) ??
        (throw Exception('Tolerância inválida.'));
    if (tol <= 0) {
      throw Exception(
          'Tolerância inválida. Deve ser um número maior que zero.');
    }

    ContextModel cm = ContextModel();
    double diferenca;
    int iteracoes = 0;
    const int maxIteracoes = 200;

    String logIteracoes = "";

    do {
      cm.bindVariable(Variable('x'), Number(xAtual));

      double fx;
      try {
        fx = exp.evaluate(EvaluationType.REAL, cm);
      } catch (e) {
        throw Exception('Erro ao avaliar f(x) em x = $xAtual.');
      }

      double fxDerivada;
      if (derivada != null) {
        try {
          fxDerivada = derivada.evaluate(EvaluationType.REAL, cm);
        } catch (e) {
          fxDerivada = calcularDerivadaNumerica(exp, xAtual, cm, 1e-6);
          logIteracoes +=
              "Atenção: Derivada simbólica falhou. Usando derivada numérica.\n";
        }
      } else {
        fxDerivada = calcularDerivadaNumerica(exp, xAtual, cm, 1e-6);
        logIteracoes +=
            "Atenção: Derivada simbólica indisponível. Usando derivada numérica.\n";
      }

      if (fxDerivada == 0) {
        throw Exception(
            'Derivada igual a zero em x = $xAtual. Escolha outro ponto inicial.');
      }

      double xNovo = xAtual - (fx / fxDerivada);
      diferenca = (xNovo - xAtual).abs();
      xAtual = xNovo;

      logIteracoes += "X${iteracoes + 1} = $xAtual\n";

      iteracoes++;
    } while (diferenca > tol && iteracoes < maxIteracoes);

    if (iteracoes >= maxIteracoes) {
      throw Exception('Número máximo de iterações alcançado sem convergência.');
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado'),
        content: Text(
          'A raiz aproximada é: $xAtual\nNúmero de iterações: $iteracoes\n\nLog de iterações:\n$logIteracoes',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text('Erro ao calcular a raiz: ${e.toString()}'),
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
