# Projeto Completo de Análise de Dados

📌 **Descrição**

Análise completa de dados a partir de tabelas armazenadas em um banco MySQL. O projeto abrange manipulação e modelagem de dados com SQL, visualização interativa com Power BI e aplicação de um algoritmo de Machine Learning em Python para prever potenciais novos clientes com base no perfil dos clientes atuais.

📌 **Objetivo**

A partir de uma base de dados contendo informações sobre clientes, lojas, produtos e pedidos, o objetivo é:

1. **Analisar o perfil predominante dos clientes** atuais para direcionamento de campanhas e priorização de vendas.
2. **Criar visualizações e indicadores** em um dashboard no Power BI conectado ao MySQL para auxiliar na tomada de decisão baseada nos dados.
3. **Construir um modelo preditivo** em Python para classificar novos dados como potenciais clientes ou não a partir de um treinamento na base de clientes atuais.

📌 **Estrutura do Projeto**


🗃️ **Base de Dados**

Os dados estão armazenados em um banco **MySQL**, com as seguintes tabelas principais:

**- `clientes`:** *Tabela dimensão com informações clientes atuais*
**- `lojas`:** *Tabela dimensão com informações das lojas e suas respectivas vendas*
**- `pedidos`:** *Tabela fato do banco de dados referente ao histórico do pedidos*
**- `produtos`** *Tabela dimensão referente aos produtos da empresa*

🔍 **Análise Exploratória dos Dados (EDA) - Linguagem SQL**

Uso da linguagem de programação SQL no SGBD (Sistema Gerenciador de Banco de Dados) para a limpeza, tratamento, manipulação e entendimento dos dados. A partir do uso do SQL, foi possível constatar o perfil de clientes existente, além de entender quais produtos e lojas mais venderam. Portanto, o SQL auxiliou no entendimento de como os dados estavam dispostos e quais as relações entre eles.

Comandos usados nas consultas:

**- DDL**: *CREATE, ALTER e DROP*
**- DML**: *SELECT, INSERT, DELETE e UPDATE*
**- Filtros**: *WHERE e HAVING*
**- Agrupamento**: *GROUP BY*
**- Ordenação**: *ORDER BY*
**- Comparação**: *LIKE, BETWEEN, =, <>*
**- Funções de Agregação**: *SUM, AVG, COUNT, MIN e MAX*
**- Window Functions (Funções de Janela)**: *Comando OVER() com funções de agregação como soma e contagem, RANK(), DENSE_RANK()*
**- Funções**: *ROUND, CONCAT, TIMESTAMPDIFF(usada para subtrair datas), CURDATE(usada para obter a data atual), ISNULL*
**- Stored Procedures**: *Procedure 'insereCliente' criada para inserir automaticamente informações de um novo cliente e aumentar a eficiência*
**- CTE**: *Criação de CTE (Common Table Expression) para auxiliar a manter a legibilidade do código e facilitar na manipualação dos dados*
**- JOIN**: *Uso do JOIN e LEFT JOIN para combinar os valores das tabelas nas consultas*
**- VIEW**: *Criação de VIEWS para criar uma nova visualização da tabela produtos que contenha as categorias obtidas a partir de um JOIN*
**- Variáveis**: *Criação de variáveis 'produtoMaisVendido', 'mediaReceita' e 'LojaMaisVendeu' para aumentar a eficiência do código e manter a legibilidade*
**- Subqueries**: *Uso de subconsultas para aumentar a eficiência e obter valores oriundos de outras tabelas ou consultas, por exemplo a média.*

📊 **Visualização Interativa dos Dados - Dashboard Power BI**

Conexão do Power BI diretamente ao MySQL a partir da instalação de um driver e criação de um dashboard interativo com:

- KPIs sobre faturamento, custo e quantidade vendida.
- Distribuição de renda média, idade e escolaridade.
- Filtros por estado civil, sexo e localização.
- Principais características do cliente padrão.

🤖 **Machine Learning - Linguagem de Programação Python**

Foi utilizado o modelo de **aprendizagem não supervisionada KMeans** para identificar **perfis (clusters)** dos clientes. Em seguida, um modelo **Random Forest** supervisionado foi treinado para **prever o perfil de novos possíveis clientes** com base nas seguintes variáveis:

- `Escolaridade`
- `Estado_Civil`
- `Sexo`
- `Idade`
- `Renda_Anual`
- `Qtd_Filhos`

**Como funciona o modelo:**

1. Os dados de clientes existentes são tratados e agrupados em clusters com o KMeans.
2. Um classificador Random Forest é treinado com os rótulos desses grupos.
3. Novos dados são processados da mesma forma e classificados conforme o perfil aprendido.
4. O resultado é uma classificação: **'Sim'** (tem perfil de cliente) ou **'Não'**.

**Tecnologias e bibliotecas usadas:**

**- `Pandas`**: *Para manipualação e tratamento de dados*
**- `scikit-learn`**: *É uma das bibliotecas utilizadas para machine learning em Python. Contém toda a parte de pré-processamento dos dados e os modelos preditivos*
**- `SQLAlchemy`**: *Para conexão ao SGBD MySQL a partir de dados como host, user, senha e database*
**- `KMeans`**: *Para clusterização (agrupamento) dos clientes de acordo com as similaridades. A decisão para a utilização desse algoritmo foi baseada em sua facilidade de manipulação e no fácil entendimento de seu funcionamento. Esse algoritmo é baseado em cálculos matemáticos de distância para agrupamentos dos dados.*
**- `RandomForestClassifier`**: *Para classificação de potenciais clientes a partir dos rótulos criados com o KMeans. A escolha por esse algoritmo foi baseada em sua boa manipulação com variáveis numéricas e categóricas, evita overfitting (previsão muito ajustada nos dados de treino) e não precisa de muitos ajustes. Esse algoritmo é uma floresta de árvores de decisão (modelo mais simples de machine learning).*

**Resultado:**

A maioria dos clientes possui **baixa renda**, **baixa escolaridade**, têm **mais de 50 anos** e são **casados**. O resultado final de fato combina com as análises feitas anteriormente em SQL. Portanto, avalio o resultado final como extremamente positivo e útil para a empresa, deixando o processo de análise de dados mais eficiente e, claro, possibilitando em um melhor direcionamento de vendas.

🧠 **Conclusão do Projeto**

A realização deste projeto demonstrou o poder e a relevância da análise de dados como ferramenta de apoio à tomada de decisão nas empresas. Ao integrar dados armazenados em um banco relacional (MySQL), realizar a exploração e visualização com Power BI, e aplicar técnicas de Machine Learning em Python, foi possível construir uma solução completa e eficiente para prever possíveis novos clientes com base em padrões reais de comportamento.

Esse tipo de abordagem permite às organizações antecipar oportunidades, personalizar estratégias de marketing, otimizar recursos e direcionar ações com maior assertividade, promovendo ganhos em performance e competitividade.

Nos dias atuais, em que o volume de dados cresce exponencialmente, utilizar análises baseadas em dados concretos não é mais um diferencial, é uma necessidade. Projetos como este mostram como a inteligência de dados pode transformar informações brutas em insights estratégicos, impactando diretamente nos resultados e no crescimento sustentável das empresas.

