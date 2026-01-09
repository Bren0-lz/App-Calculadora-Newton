# Newton Finder - Calculadora de Raízes

![Status](https://img.shields.io/badge/Status-Concluído%20(Ajustes%20Mínimos)-green?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

O **Newton Finder** é uma ferramenta de alta precisão desenvolvida em **Flutter** para resolver equações não lineares através do **Método de Newton-Raphson**. O projeto foi focado em fornecer uma interface acadêmica robusta, sendo ideal para estudantes de Engenharia e Ciências Exatas.

## Funcionalidades e Diferenciais

* **Entrada Matemática Nativa:** Utiliza o `math_keyboard` para permitir a digitação de funções complexas diretamente no dispositivo móvel.
* **Renderização LaTeX em Tempo Real:** Visualização instantânea da função digitada com formatação matemática profissional via `flutter_math_fork`.
* **Navegação Fluida (UX):** Lógica de foco customizada que permite navegar entre os campos (f(x), Chute Inicial e Aproximação) através da tecla "Enter" sem fechar o teclado.
* **Segurança de Processamento:** Implementação de uma trava de segurança que interrompe o cálculo após **100 iterações**, evitando loops infinitos em funções divergentes.
* **Histórico Detalhado:** Exibição de todas as etapas do cálculo (iteração, valor de $x_n$ e $f(x_n)$ ) em uma tabela dinâmica organizada.

## O Método Matemático

O motor de cálculo avalia a função e sua derivada simbólica para encontrar a aproximação da raiz através da fórmula:

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

## Stack Técnica

* **Framework:** Flutter (Null Safety)
* **Processamento Simbólico:** `math_expressions` (Parser de TeX e derivação automática).
* **Gerenciamento de Estado:** `StatefulWidget` com otimização de renderização.
* **Arquitetura:** Modelos de dados com parâmetros nomeados para maior manutenibilidade.

## Instalação e Execução

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/Bren0-lz/App-Calculadora-Newton.git](https://github.com/Bren0-lz/App-Calculadora-Newton.git)

2. **Obtenha as dependências:**
   ```bash
   flutter pub get
   
3. **Rode o projeto:**
   ```bash
   flutter run

## Contexto Acadêmico

Este projeto foi desenvolvido como parte integrante da minha formação em Engenharia de Computação no IFF (Instituto Federal Fluminense). Ele reflete a aplicação de conceitos de Cálculo 1 e Desenvolvimento Mobile.

## Autor

**Breno Luiz**
* [LinkedIn](https://www.linkedin.com/in/breno-luiz-silva-do-carmo-19451a243/)
* [GitHub](https://github.com/Bren0-lz)
