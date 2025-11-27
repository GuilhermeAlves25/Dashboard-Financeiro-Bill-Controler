**Bill Controler**

O Bill Controler é um aplicativo de gestão financeira pessoal desenvolvido em Flutter. O projeto foi construído com foco em Clean Architecture e Separation of Concerns, utilizando o padrão de gerência de estado BLoC para garantir escalabilidade e testabilidade.

**Funcionalidades**

- Dashboard Financeiro: Visão geral de Receitas, Despesas e Saldo atual.

- Gestão de Transações: Adicionar, editar e excluir movimentações financeiras.

- Categorias Personalizadas: Criação de categorias com ícones e cores customizáveis.

- Filtros Avançados: Busca por período (datas), tipo de transação e categorias múltiplas.

- Relatórios Visuais: Gráficos interativos (Pizza e Barras) para análise de gastos.

- Exportação de Dados: Geração de relatórios em formato CSV para backup.

- Persistência Local: Dados salvos offline utilizando SQLite.

**Tecnologias e Arquitetura**

- O projeto segue uma arquitetura reativa baseada em eventos.

Principais Pacotes

flutter_bloc & equatable: Gerenciamento de estado e comparação de objetos.

sqflite & path: Banco de dados SQL local.

fl_chart: Renderização de gráficos financeiros.

intl: Internacionalização e formatação de datas/moedas.

csv & path_provider: Manipulação de arquivos e exportação.

graphql_flutter: (Camada preparada para futura sincronização em nuvem).
