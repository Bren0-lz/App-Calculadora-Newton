# Newton Finder — Calculadora de Raízes pelo Método de Newton-Raphson

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Plataformas](https://img.shields.io/badge/Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-555?style=for-the-badge)
![Licença](https://img.shields.io/badge/Licen%C3%A7a-Todos%20os%20direitos%20reservados-red?style=for-the-badge)

Aplicativo multiplataforma em **Flutter/Dart** que encontra raízes de equações não lineares pelo
**Método de Newton-Raphson**, com teclado matemático nativo, renderização LaTeX em tempo real,
derivação simbólica automática e tabela com o histórico de cada iteração.

---

## Comprovação de experiência

| | |
|---|---|
| **Autor** | Breno Luiz Silva do Carmo — único autor de todos os commits deste repositório |
| **Tipo** | Item de portfólio de autoria própria (aplicativo multiplataforma) |
| **Período de desenvolvimento** | 27/12/2025 a 08/01/2026 — 25 commits |
| **Contexto** | Engenharia de Computação — IFF (Instituto Federal Fluminense), aplicação de Cálculo I |
| **Verificação** | O histórico de commits (`git log`) registra autoria, datas e a evolução do projeto |

### Competências técnicas evidenciadas

| Competência | Onde verificar neste repositório |
|---|---|
| **GitHub / versionamento** | 25 commits descritivos, com refatorações e resolução de conflito de merge registradas no histórico |
| **Framework de desenvolvimento multiplataforma** | Flutter com alvos `android/`, `ios/`, `web/`, `windows/`, `linux/` e `macos/` |
| **Design e prototipagem de interfaces** | [`lib/pagina_principal.dart`](lib/pagina_principal.dart) — display multilinha interativo, navegação entre campos pela tecla *Enter* sem fechar o teclado, tabela de iterações |
| **Lógica e algoritmos numéricos** | [`lib/logic/newton_logic.dart`](lib/logic/newton_logic.dart) — Newton-Raphson com derivada simbólica, critério de parada, proteção contra derivada nula e limite de 100 iterações |
| **Modelagem de dados** | Classes `IteracaoNewton` e `ResultadoNewton` com parâmetros nomeados obrigatórios |
| **Integração de bibliotecas** | `math_expressions` (parser e derivação), `math_keyboard` (entrada), `flutter_math_fork` (LaTeX) |

---

## Funcionalidades

- **Entrada matemática nativa** — `math_keyboard` permite digitar funções complexas no celular.
- **LaTeX em tempo real** — a função digitada é renderizada com `flutter_math_fork`.
- **Derivada automática** — `math_expressions` deriva f(x) simbolicamente; o usuário não precisa
  informar f'(x).
- **Navegação fluida** — o foco percorre f(x), chute inicial (x₀) e tolerância pela tecla *Enter*.
- **Proteções numéricas** — interrompe com mensagem clara se a derivada zerar ou se o método não
  convergir em 100 iterações.
- **Histórico detalhado** — tabela com n, xₙ e f(xₙ) de cada iteração.

## O método

A cada passo, a aproximação é atualizada por

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

e o cálculo termina quando |f(xₙ)| fica abaixo da tolerância informada.

## Arquitetura

```
lib/
  main.dart                 ponto de entrada (MaterialApp)
  pagina_principal.dart     interface: entrada, display LaTeX, tabela de resultados
  logic/
    newton_logic.dart       motor de cálculo: conversão para LaTeX + Newton-Raphson
```

A lógica numérica fica isolada da interface em `NewtonLogic`, com métodos estáticos puros que
recebem a expressão e devolvem um `ResultadoNewton`. Isso permite testá-la sem montar widgets.

## Como executar

Pré-requisito: [Flutter SDK](https://docs.flutter.dev/get-started/install) com Dart ≥ 3.6.

```bash
git clone https://github.com/Bren0-lz/App-Calculadora-Newton.git
cd App-Calculadora-Newton
flutter pub get
flutter run
```

## Limitações conhecidas

- `test/widget_test.dart` ainda é o teste padrão gerado pelo Flutter e não cobre o app;
  testes unitários de `NewtonLogic` são o próximo passo.

## Autor

**Breno Luiz Silva do Carmo**
[LinkedIn](https://www.linkedin.com/in/breno-luiz-silva-do-carmo-19451a243/) ·
[GitHub](https://github.com/Bren0-lz)

## Licença

Copyright (c) 2026 Breno Luiz Silva do Carmo. Todos os direitos reservados.
Nenhuma parte deste código pode ser utilizada, reproduzida, distribuída ou modificada sem
autorização prévia por escrito do autor. Veja [LICENSE](LICENSE).
