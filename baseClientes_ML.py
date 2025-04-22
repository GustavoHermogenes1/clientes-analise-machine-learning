import pandas as pd                                                 # Tratamento e manipulação dos dados
from sklearn.preprocessing import StandardScaler, OneHotEncoder     # Normalização de variáveis categóricas e colocar variáveis numéricas em mesma escala
from sklearn.cluster import KMeans                                  # Modelo de previsão não supervisionado para agrupamento (clusterização)
from sklearn.compose import ColumnTransformer                       # Aplicar a transformação dos dados no algoritmo
from sklearn.pipeline import Pipeline                               # Pipeline para integrar o pré-processamento dos dados e o algoritmo
from sklearn.ensemble import RandomForestClassifier                 # Algoritmo de classificação para classificar os possíveis novos clientes depois de agrupados
from sqlalchemy import create_engine                                # Conexão ao banco de dados MySQL


# df_clientes -> base com somente clientes vindo do SGBD
# df_possiveis -> base com leads (possíveis clientes)

'''
    Conexão com o banco de dados MySQL via pacote sqlalchemy e importação da tabela clientes para o código Python
'''

print("🔧 Conectando via SQLAlchemy...")

# Faz a conexão usando pymysql como driver e passando os dados de usuário, senha, host e o database do SGBD
engine = create_engine("mysql+pymysql://root:admin@localhost:3306/banco")

# Tratamento de exceções em caso de erros de conexão
try:
    df_clientes = pd.read_sql("SELECT * FROM clientes", engine)    # Passando como argumentos a query para obter a tabela clientes e o cursor
    print("✅ Dados carregados!")
    print(df_clientes.head())   # Print para visualizar as 5 primeiras linhas da tabela clientes

except Exception as e:
    print("❌ Erro ao carregar dados:", e)      # Tratamento do possível erro

'''
    Limpeza e tratamento dos dados para preparar o dataset para a análise preditiva
'''

# Comando para ter uma visão geral do data frame e entender sua forma, disposição das colunas e tipos de dados
df_clientes.info()

# Combinação das colunas nome e sobrenome em apenas uma para reduzir colunas e otimizar o processo de análise.
df_clientes['Nome'] = df_clientes['Nome']+' '+df_clientes['Sobrenome']

# Exclusão de colunas que não agregrarão valor ao processo no momento
df_clientes = df_clientes.drop(columns=['Data_Nascimento', 'Telefone', 'Sobrenome', 'Email'])

# Visualizando o dataFrame final que será usado na previsão
print(df_clientes.head())

'''
    # Trabalhando com a lista de possíveis clientes # 

    Essa lista foi solicitada ao ChatGPT, porém pode ser representada como leads obtidos de campanhas de marketing.

    O modelo preditivo terá a função de analisar as variáveis dos registro dessa lista e classificá-los como possíveis clientes ou não.
'''

# Lista de Leads
possiveis_clientes = [
    {'Idade': 28, 'Escolaridade': 'Pós-graduado', 'Estado_Civil': 'Solteiro', 'Renda_Anual': 48000, 'Qtd_Filhos': 0, 'Sexo': 'Feminino'},
    {'Idade': 35, 'Escolaridade': 'Ensino médio',    'Estado_Civil': 'Casado',   'Renda_Anual': 55000, 'Qtd_Filhos': 2, 'Sexo': 'Masculino'},
    {'Idade': 42, 'Escolaridade': 'Parcial', 'Estado_Civil': 'Solteiro', 'Renda_Anual': 30000, 'Qtd_Filhos': 1, 'Sexo': 'Masculino'},
    {'Idade': 24, 'Escolaridade': 'Graduação', 'Estado_Civil': 'Solteiro', 'Renda_Anual': 36000, 'Qtd_Filhos': 0, 'Sexo': 'Feminino'},
    {'Idade': 50, 'Escolaridade': 'Ensino médio',    'Estado_Civil': 'Casado',   'Renda_Anual': 70000, 'Qtd_Filhos': 3, 'Sexo': 'Feminino'},
    {'Idade': 31, 'Escolaridade': 'Graduação', 'Estado_Civil': 'Casado',    'Renda_Anual': 62000, 'Qtd_Filhos': 1, 'Sexo': 'Masculino'},
    {'Idade': 38, 'Escolaridade': 'Parcial', 'Estado_Civil': 'Casado', 'Renda_Anual': 41000, 'Qtd_Filhos': 2, 'Sexo': 'Feminino'},
    {'Idade': 45, 'Escolaridade': 'Ensino médio',    'Estado_Civil': 'Solteiro', 'Renda_Anual': 52000, 'Qtd_Filhos': 2, 'Sexo': 'Masculino'},
    {'Idade': 29, 'Escolaridade': 'Graduação', 'Estado_Civil': 'Solteiro', 'Renda_Anual': 47000, 'Qtd_Filhos': 0, 'Sexo': 'Feminino'},
    {'idade': 60, 'Escolaridade': 'Parcial', 'Estado_Civil': 'Casado', 'Renda_Anual': 39000, 'Qtd_Filhos': 3, 'Sexo': 'Masculino'},
    {'idade': 21, 'Escolaridade': 'Graduação', 'Estado_Civil': 'Casado', 'Renda_Anual': 30000, 'Qtd_Filhos': 0, 'Sexo': 'Masculino'}
]

# Transformando os dados em um DataFrame
df_possiveis = pd.DataFrame(possiveis_clientes)

'''
    # Pré-processamento dos dados #

    Essa etapa é de extrema importância para o funcionamento eficaz do modelo de machine learning. É aqui que serão definidas
    as variáveis de interesse, separação das colunas de acordo com o tipo de dado, normalização e escalonamento dos valores.

    Tendo em vista que a máquina não entende textos, será necessária a normalização dos dados categóricos utilizando o One Hot Encoder,
    por isso esses valores receberão dados binários (0 e 1). A opção pelo OneHotEncoder foi decidido pois não existe uma ordem 
    definida nas variáveis. Além disso, os valores numéricos passarão por um processo para serem colocados em escala usando o
    Standard Scaler e, assim, auxiliar na aprendizagem da máquina.
'''
# Definindo as variáveis de interesse para o modelo preditivo. 
# Essas variáveis serão analisadas pelo modelo. Elas foram definidas como importante pois o agrupamento pode ser feito a partir delas.
variaveis = ['Escolaridade', 'Estado_Civil', 'Sexo', 'Idade', 'Renda_Anual', 'Qtd_Filhos']

# Separando o dataframe da base clientes com as variáveis de interesse 
X_clientes = df_clientes[variaveis]

# Colocando o dataframe de leads em uma nova variável para não alterar o original e manter a legibilidade do código
X_possiveis = df_possiveis[variaveis]

# Pré-processamento das variáveis. Separação das colunas numéricas e categóricas para serem usadas na normalização e processo de escala.
colunas_numericas = ['Idade', 'Renda_Anual', 'Qtd_Filhos']
colunas_categoricas = ['Escolaridade', 'Estado_Civil', 'Sexo']

# Criando uma instância que será usado como pré-processador das variáveis
preprocessador = ColumnTransformer([
    ('num', StandardScaler(), colunas_numericas),           # Colocando os valores numéricos em escala
    ('cat', OneHotEncoder(drop='first'), colunas_categoricas)   # Normalizando as colunas categóricas. O drop='first' é usado ficar com menos colunas e não sobrecarregar.
])

'''
    # Algoritmo KMeans #

    A decisão para a utilização desse algoritmo foi baseada em sua facilidade de manipulação e no fácil entendimento de seu funcionamento.

    Esse algoritmo é baseado em cálculos matemáticos de distância para agrupamentos dos dados.

    É definido uma quantidade de centroides de acordo com o número de clusters (grupos a partir de similaridades) que agruparão os dados.
    O agrupamento é feito com base no cálculo da distância de um dado para todos os centroides, o que tiver a menor distância será o grupo para o dado.
'''

# Pipeline para pré-processamento e algoritmo KMeans
# Esse Pipeline é uma sequência de etapas que é resultado da junção do pré-processamento e o algoritmo de agrupamento utilizado
# K-Means é o algoritmo de agrupamento que será utilizado
pipeline_kmeans = Pipeline(steps=[
    ('preprocessamento', preprocessador),           # Esse é o pré-processamento dos dados feito anteriormente
    ('kmeans', KMeans(n_clusters=3, random_state=1))  # A quantidade de clusters (grupos separados por similaridades) foi definido como 3 e o random state = 1 é para o código gerar o mesmo resultado. 
])

# Treinando o algoritmo K-Means na base de clientes
pipeline_kmeans.fit(X_clientes)

# Obtendo os rótulos dos clusters (agrupamentos com base nas similaridades das variáveis)
grupos_clientes = pipeline_kmeans.named_steps['kmeans'].labels_

'''
    # Algoritmo Random Forest #

    Esse algoritmo será utilizado a partir do agrupamento dos dados com o KMeans. Depois dos dados serem agrupados de acordo com as similaridades
    e treinado o algoritmo, precisaremos de um algoritmo classificador para rotular os novos dados a partir dos treinos.

    Então, basicamente, o KMeans foi utilizado para agrupar os dados com as similaridades e o Random Forest fará a classificação. Por isso serão utilizados juntos neste código.

    O Random Forest é um algoritmo de classificação com aprendizado supervisionado, ou seja, precisa dos rótulos no dataset.
    A escolha por esse algoritmo foi baseada em sua boa manipulação com variáveis numéricas e categóricas, evita overfitting (previsão muito ajustada nos dados de treino)
    e não precisa de muitos ajustes. Esse algoritmo é uma floresta de árvores de decisão (modelo mais simples de machine learning).
'''

# Treinando o algoritmo classificador (neste caso a random forest) para prever o cluster (perfil de possíveis clientes) 
X_clientes_tratado = pipeline_kmeans.named_steps['preprocessamento'].transform(X_clientes) # Aplicando o pré-processamento para o algoritmo de classificação
classificador = RandomForestClassifier(random_state=1) # Criando o classificador utilizando o algoritmo random forest
classificador.fit(X_clientes_tratado, grupos_clientes)  # Treinando o classificador com as variáveis e seus rótulos

# Tratando o grupo dos possíveis clientes e fazendo a previsão de classificação
X_possiveis_tratado = pipeline_kmeans.named_steps['preprocessamento'].transform(X_possiveis) # Aplicando o pré-processamento dos dados para a base de possíveis clientes
grupos_possiveis = classificador.predict(X_possiveis_tratado)   # Previsão dos grupos dos possíveis clientes

# Adicionando o resultado da previsão dos grupos no DataFrame de possíveis clientes
df_possiveis['perfil_cliente'] = ['Sim' if grupo == 1 else 'Não' for grupo in grupos_possiveis]

'''
    # Resultado Final #

    O resultado final de fato combina com as análises feitas anteriormente em SQL, evidenciando que o perfil de clientes é 
    voltado ao público casado, escolaridade baixa e de baixa renda.

    Portanto, avalio o resultado final como extremamente positivo e útil para a empresa, deixando o processo de análise de dados
    mais eficiente e, claro, possibilitando em um melhor direcionamento de vendas.
'''

# Exibir o resultado final da previsão de possíveis clientes
print(df_possiveis[['Escolaridade', 'Estado_Civil', 'Sexo', 'Idade', 'Renda_Anual', 'Qtd_Filhos', 'perfil_cliente']])