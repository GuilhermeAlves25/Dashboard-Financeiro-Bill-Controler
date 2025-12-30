#  Bill Controler - Controle Financeiro Pessoal

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

**Um aplicativo completo de gestão financeira desenvolvido com Flutter e arquitetura BLoC**

</div>

---

## Sobre o Projeto

O **Bill Controler** é um aplicativo mobile de controle financeiro pessoal desenvolvido com **Flutter**, projetado para ajudar usuários a gerenciar suas finanças de forma simples e eficiente. O projeto implementa as melhores práticas de desenvolvimento mobile, incluindo **Clean Architecture** e padrão **BLoC** para gerenciamento de estado, garantindo código escalável, testável e de fácil manutenção.

### Problema Resolvido

Muitos aplicativos de controle financeiro são complexos demais ou não oferecem a flexibilidade necessária. O Bill Controler oferece uma solução equilibrada com:
- ✅ Interface intuitiva e responsiva
- ✅ Funcionamento 100% offline (sem necessidade de internet)
- ✅ Visualizações gráficas claras dos seus gastos
- ✅ Categorização personalizada de transações
- ✅ Exportação de dados para análise externa

---

## Características

### Dashboard Interativo
- Visão geral de **Receitas**, **Despesas** e **Saldo** do período selecionado
- Navegação por mês com botões intuitivos
- Gráficos de pizza mostrando distribuição por categoria
- Lista de transações recentes com scroll infinito

###  Gestão de Transações
- ➕ Adicionar receitas e despesas
- ✏️ Editar transações existentes
- 📝 Adicionar observações detalhadas
- 📅 Seleção de data personalizada

### Categorias Personalizadas
- Criar categorias customizadas com:
  - Cores personalizadas
  - Ícones do Material Design
  - Tipos (receita ou despesa)
- Edição e exclusão de categorias
- Validação automática antes de excluir (verifica transações vinculadas)

###  Filtros Avançados
- Filtrar por **período** (data início e fim)
- Filtrar por **tipo** (receita, despesa ou ambos)
- Filtrar por **múltiplas categorias**
- Combinação de filtros para análises precisas

###  Relatórios Visuais
- **Gráfico de Pizza**: Distribuição percentual por categoria
- **Gráfico de Barras**: Comparação visual entre categorias
- Alternância entre visualizações
- Análise de períodos personalizados
- Indicadores de receita, despesa e saldo líquido

###  Exportação de Dados
- Exportar relatórios em formato **CSV**
- Escolher período de exportação
- Dados prontos para análise em Excel/Google Sheets
- Backup manual dos dados financeiros

###  Persistência Local
- Banco de dados **SQLite** local
- Dados salvos offline (sem necessidade de internet)
- Privacidade total (seus dados permanecem no dispositivo)
- Performance otimizada para consultas rápidas

---

##  Tecnologias Utilizadas

### Core
- **Flutter** - Framework para desenvolvimento multiplataforma
- **Dart** - Linguagem de programação

### Gerenciamento de Estado
- **flutter_bloc (^8.1.3)** - Implementação do padrão BLoC
- **equatable (^2.0.5)** - Comparação eficiente de objetos

### Persistência de Dados
- **sqflite (^2.3.0)** - Banco de dados SQLite local
- **path (^1.8.3)** - Manipulação de caminhos de arquivos

### Visualização de Dados
- **fl_chart (^0.68.0)** - Gráficos interativos (pizza e barras)

### Utilitários
- **intl (^0.19.0)** - Formatação de datas e moedas (pt_BR)
- **google_fonts (^6.1.0)** - Tipografia customizada (Inter)

### Exportação
- **csv (^6.0.0)** - Geração de arquivos CSV
- **path_provider (^2.1.1)** - Acesso ao sistema de arquivos
- **permission_handler (^11.0.1)** - Gerenciamento de permissões

### Preparado para o Futuro
- **graphql_flutter (^5.1.2)** - Pronto para sincronização em nuvem

---

## Arquitetura

O projeto segue uma **arquitetura limpa e escalável** baseada nos seguintes princípios:

### Estrutura de Pastas

```
lib/
├── main.dart                      # Ponto de entrada
├── blocos/                        # Gerenciamento de Estado (BLoC)
│   ├── categorias/
│   │   └── categoria_bloc.dart    # Eventos, Estados e Lógica
│   ├── transacoes/
│   │   └── transacao_bloc.dart
│   ├── filtros/
│   │   └── filtro_bloc.dart
│   └── relatorios/
│       └── relatorio_bloc.dart
├── modelos/                       # Modelos de Dados
│   ├── modelo_categoria.dart
│   ├── modelo_transacao.dart
│   └── modelo_filtro.dart
├── dados/                         # Camada de Dados
│   └── banco_dados.dart           # SQLite Helper
├── telas/                         # Interface do Usuário
│   ├── tela_inicio.dart           # Dashboard principal
│   ├── tela_transacoes.dart       # Lista completa
│   ├── tela_nova_transacao.dart   # Formulário
│   ├── tela_nova_categoria.dart
│   └── tela_relatorios.dart       # Gráficos e análises
└── componentes/                   # Widgets Reutilizáveis
    ├── cartao_saldo.dart
    └── item_transacao.dart
```

### Padrão BLoC (Business Logic Component)

O projeto implementa o padrão **BLoC** para separar a lógica de negócio da interface:

```dart
UI → Evento → BLoC → Estado → UI
```

**Benefícios:**
- ✅ Separação clara de responsabilidades
- ✅ Código testável unitariamente
- ✅ Reatividade automática da UI
- ✅ Gerenciamento previsível de estado

### Fluxo de Dados

1. **Camada de Apresentação (UI)**: Widgets Flutter
2. **Camada de Lógica (BLoC)**: Processamento de eventos e emissão de estados
3. **Camada de Dados**: Acesso ao SQLite através do `AuxiliarBancoDeDados`
4. **Modelos**: Classes com serialização/deserialização para o banco

---

##  Instalação

### Pré-requisitos

- Flutter SDK (3.0.0 ou superior)
- Dart SDK (3.0.0 ou superior)
- Android Studio / Xcode (para emuladores)
- Git

### Passos

1. **Clone o repositório**
```bash
git clone https://github.com/GuilhermeAlves25/Dashboard-Financeiro-Bill-Controler.git
cd Dashboard-Financeiro-Bill-Controler
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
# Android
flutter run

# iOS (necessário macOS)
flutter run -d ios

# Web
flutter run -d chrome
```

---

##  Como Usar

### 1. Primeiro Acesso
Ao abrir o app pela primeira vez, você verá o dashboard vazio. Comece criando suas categorias!

### 2. Criar Categorias
1. Acesse a tela de categorias
2. Clique no botão "+"
3. Defina nome, ícone, cor e tipo (receita/despesa)
4. Salve

### 3. Adicionar Transações
1. No dashboard, clique no botão "+"
2. Preencha descrição, valor, data e categoria
3. Adicione observações (opcional)
4. Salve

### 4. Visualizar Relatórios
1. Acesse a aba "Relatórios"
2. Selecione o período desejado
3. Alterne entre gráfico de pizza e barras
4. Exporte para CSV se necessário

### 5. Filtrar Transações
1. Na tela de transações, use o botão de filtro
2. Selecione período, tipo ou categorias
3. Visualize apenas as transações relevantes

##  Banco de Dados

### Esquema SQLite

**Tabela: categorias**
```sql
CREATE TABLE categorias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  codigoPontoIcone INTEGER NOT NULL,
  valorCor INTEGER NOT NULL,
  tipo TEXT NOT NULL
)
```

**Tabela: transacoes**
```sql
CREATE TABLE transacoes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  descricao TEXT NOT NULL,
  valor REAL NOT NULL,
  data TEXT NOT NULL,
  idCategoria INTEGER NOT NULL,
  tipo TEXT NOT NULL,
  observacao TEXT,
  FOREIGN KEY (idCategoria) REFERENCES categorias (id)
)
```

---

##  Design

- **Paleta de cores principal**: Azul marinho (#1E3A8A)
- **Tipografia**: Google Fonts - Inter
- **Componentes**: Material Design 3
- **Tema**: Claro (com preparação para tema escuro)

---


##  Autor

**Guilherme Alves**

- LinkedIn: [Guilherme Alves](https://www.linkedin.com/in/guilhermealvesdevfull)
- GitHub: [@GuilhermeAlves25](https://github.com/GuilhermeAlves25)
- Email: coradodasilva33@gmail.com


