# Projeto Análise de dados com Linguagem SQL #

# Análise base Clientes:

## Em relação ao sexo dos clientes:
-- Essa base de clientes está bem equilibrada em relação ao sexo das pessoas.
-- As vendas de acordo com o sexo também indicam esse equilíbrio, o que deixa evidente que as vendas não são afetadas por essa variável.
-- O sexo masculino teve um faturamento levemente maior nas vendas e eles representam 48% da base de clientes.
-- Os homens ganham menos do que as mulheres e, como o produto está muito direcionado para renda baixa, esse pode ser o motivo por mais vendas para homens.

## Em relação a escolaridade dos clientes:
-- A maior parte dos clientes são de escolaridade baixa, como Ensino médio ou Parcial. Ambas são as que possuem menor renda média. 
-- Portanto, está em linha com o nosso perfil de cliente.

## Em relação ao Estado Civil dos clientes
-- Filtrando o perfil de clients masculinos, os casados são a maioria e eles possuem quase o triplo de filhos em relação aos solteiros. 
-- Os homens casados compraram muito mais do que os solteiros. 
-- Mulheres casadas também compraram bastante, porém menos do que os homens.

-- Portanto, se fizer o direcionamento para os clientes masculinos, é de extrema importância selecionar homens casados e com filhos.

## Em relação a idade dos clientes:
-- A maior parte dos clientes têm mais do que 35 anos. Os que mais compraram tem idade maior do que 50 anos.

## Perfil da base clientes
-- Analisando o pefil dessa base, a maior parte são pessoas casadas (independente do sexo, pois está bem equilibrado), escolaridade parcial ou ensino médio,
-- com 2 ou mais filhos e maior que 35 anos.
-- Filtrando o perfil de clients masculinos, os casados são a maioria e eles possuem quase o triplo de filhos em relação aos solteiros. 
-- Portanto, se fizer o direcionamento para os clientes masculinos, é de extrema importância selecionar homens casados e com filhos.

## Conclusão
-- Analisando a base de clientes, esse perfil acima é a maioria em nossa base, portanto, ao que tudo indica, as pessoas de baixa renda anual, casado, idade maior que 35 anos,
-- com filhos e escolaridade Parcial e Ensino Médio são as que mais compram os produtos.
-- De acordo com a análise, é interessante fazer uma separação entre os sexos, direcionando um pouco mais as campanhas para o sexo masculino com o perfil acima.
-- Acredito que seria ainda algo equilibrado entre os sexos, porém os homens se interessaram mais pelos produtos do que as mulheres, mesmo sendo em menor quantidade.
-- Portanto, fica evidente a necessidade de fazer mudanças nessa base de clientes e, também, no direcionamento das campanhas de marketing para atrair mais leads.

-- Comando para selecionar o banco de dados que contém as tabelas utilizadas
USE banco;

# Visão Geral da Base. 
-- Esse passo é o ínicio da análise, então é primordial ter uma visão completa dos dados, suas principais características e a forma que estão distribuídos.

-- Usei o LIMIT para não carregar todos os dados nessa visão inicial e sobrecarregar memória, pois a intenção é apenas visualizar como a tabela está dimensionada. 
SELECT * FROM clientes LIMIT 10;

# Transformação dos dados

-- Alterando os valores de Sexo para MASCULINO e FEMININO no lugar de M e F, respectivamente. Essa mudança é feita para melhorar a legibilidade da tabela (questão pessoal)
-- Utilizando o comando CASE para analisar os casos e retornar os resultados se forem verdadeiros. Senão, o ELSE retornará apenas o valor de Sexo.
UPDATE clientes
SET Sexo = CASE
	WHEN Sexo = "M" THEN "Masculino"
	WHEN Sexo = "F" THEN "Feminino"
    ELSE Sexo
END;

-- Atualizando também os valores de Estado Civil dos registros para "Casado" e "Solteiro" no lugar de "C" e "S".
UPDATE clientes
SET Estado_Civil = CASE
	WHEN Estado_Civil = 'C' THEN 'Casado'
    WHEN Estado_Civil = 'S' THEN 'Solteiro'
    ELSE Estado_Civil
END;

-- Criando a coluna idade na tabela a partir do comando DDL ALTER TABLE
-- Essa variável é muito importante nas análises pois podem representar preferências e possíveis direcionamentos de perfil.
-- CONSTRAINT unsigned utilizada para que não sejam aceitos valores negativos. 
-- Tinyint é um tipo de dado recomendado para armazenar valores de idade e, assim, economizar memória.	
ALTER TABLE  clientes
ADD COLUMN idade TINYINT UNSIGNED; 		

-- Atualizando a coluna idade com os valores resultantes da função timestampdiff() que retorna a diferença em anos entre duas datas.
-- Para isso foi utilizado o argumento YEAR para transformar na função
-- A função curdate() é usada para representar a data atual.
UPDATE clientes
SET idade = TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE());

-- Visualizando a tabela atualizada
SELECT * FROM clientes LIMIT 5;

-- Mudando o nome da coluna Idade para colocar a primeira letra como maiúscula. Para essa mudança no nome é usado o comando CHANGE
ALTER TABLE clientes
CHANGE COLUMN idade Idade TINYINT UNSIGNED;

# Criação de Procedure que permita a inserção de novos dados de clientes

-- A Procedure será importante para o processo, principalmente por conta da reutilização de código
-- Ou seja, se for necessária a inserção de um novo cliente, não precisará digitar todo o código de alter table insert into values...
-- Poderá apenas chamar a procedure insereClientes que tem dentro dela a função para inserção.

-- Procedure
DELIMITER $$								-- É preciso alterar o delimitador pois, dentro da procedure, precisamos usar o ';' 

-- Criação da Procedure insereCliente que terá a função com parâmetros que serão inseridos na tabela clientes
CREATE PROCEDURE insereCliente (
	IN p_Nome VARCHAR(100),
	IN p_Sobrenome VARCHAR(100),
	IN p_Data_Nascimento DATE,
	IN p_Estado_Civil VARCHAR(30),
	IN p_Sexo VARCHAR(20),
	IN p_Email VARCHAR(255),
	IN p_Telefone VARCHAR(20),
	IN p_Renda_Anual INT,
	IN p_Qtd_Filhos TINYINT,
	IN p_Escolaridade VARCHAR(30),
    IN p_Idade TINYINT
)
BEGIN
	INSERT INTO clientes (					-- Inserir nas respectivas colunas da tabela clientes
		Nome,
		Sobrenome,
		Data_Nascimento,
		Estado_Civil,
		Sexo,
		Email,
		Telefone,
		Renda_Anual,
		Qtd_Filhos,
		Escolaridade,
        Idade
	)
	VALUES (								-- Os valores passados na procedure
		p_Nome,
		p_Sobrenome,
		p_Data_Nascimento,
		p_Estado_Civil,
		p_Sexo,
		p_Email,
		p_Telefone,
		p_Renda_Anual,
		p_Qtd_Filhos,
		p_Escolaridade,
        p_Idade
	);
END$$									-- Fim da procedure

DELIMITER ;								-- Retorna para o delimitador ';'

-- Definindo o ID_Cliente como autoincremento para não precisar passar o ID na procedure
ALTER TABLE clientes
MODIFY ID_Cliente INT AUTO_INCREMENT PRIMARY KEY;

-- Chama a procedure insereCliente para inserir os dados de um novo cliente na tabela.
CALL insereCliente(
	'Gustavo',
    'Hermogenes',
    '2003-12-31',
    'Solteiro',
    'Masculino',
    'gustavo.hermogenes.03@gmail.com',
    '(11) 99007-5915',
    40000,
    0,
    'Graduação',
    21
);

-- Visualização do registro na tabela clientes após o filtro pelo sobrenome
SELECT * FROM clientes WHERE Sobrenome = 'Hermogenes';

-- Visualizando a tabela inteira
SELECT * FROM clientes;

-- Caso queira excluir apenas o valor inserido
DELETE FROM clientes
WHERE ID_Cliente = 101;

# Manipulação e Análise dos Dados

-- Clientes de acordo com o sexo. 
-- Utilização da Função de Janela (comando Over() ) para calcular o percentual de ambos os sexos referente a quantidade total de pessoas.
-- Comando GROUP BY utilizado para agrupar os valores de acordo com o Sexo, neste caso.
SELECT 
	Sexo,									-- sum(): soma
    count(Sexo) AS qtde_Sexo,				-- count(): contagem
    avg(Renda_Anual) AS renda_media,		-- avg(): média
    round( count(Sexo) / sum(count(Sexo)) OVER(), 2) * 100 AS '%Total'		-- round(): arrendondar o resultado. Neste caso, 2 números após a vírgula.
FROM clientes
GROUP BY Sexo;

-- Clientes agrupados de acordo com o estado civil. Buscando encontrar relações entre as variáveis da tabela Clientes
-- Comando de ordenação ORDER BY utilizado para ordernar os valores. Neste caso serão ordenados de forma decrescente a partir do comando DESC.
SELECT 
	Estado_Civil,
    count(Estado_Civil) AS qtde_Estado_Civil,
    round(avg(Renda_Anual)) AS media_Renda,
    sum(Qtd_Filhos) AS qtde_Filhos,
    avg(Qtd_Filhos) AS Filhos_por_Pessoa
FROM clientes
GROUP BY Estado_Civil 
ORDER BY media_Renda DESC;

-- Analisando quantos filhos a maior parte dos clientes têm. Entendendo a relação entre quantidade de filhos e o perfil dos clientes
SELECT
	Qtd_Filhos, 
	sum(Qtd_Filhos) AS soma
FROM clientes
GROUP BY Qtd_Filhos
ORDER BY soma DESC;

-- Dividindo essa análise entre os sexos dos clientes. Começando pelo sexo feminino:
SELECT 
	Estado_Civil,
    count(Estado_Civil) AS qtde_Estado_Civil,
    round(avg(Renda_Anual)) AS media_Renda,
    sum(Qtd_Filhos) AS qtde_Filhos,
    avg(Qtd_Filhos) AS Filhos_por_Pessoa
FROM clientes WHERE Sexo = 'Feminino'			-- Cláusula WHERE para fazer o filtro na consulta.
GROUP BY Estado_Civil 
ORDER BY media_Renda DESC;

-- Agora com o sexo masculino
SELECT 
	Estado_Civil,
    count(Estado_Civil) AS qtde_Estado_Civil,
    round(avg(Renda_Anual)) AS media_Renda,
    sum(Qtd_Filhos) AS qtde_Filhos,
    avg(Qtd_Filhos) AS Filhos_por_Pessoa
FROM clientes WHERE Sexo = 'Masculino'
GROUP BY Estado_Civil
ORDER BY media_Renda DESC;

-- Visualizando a média da distribuição de renda de acordo com a escolaridade dos clientes. Buscando encontrar conexões entre variáveis para entender o perfil dos clientes.
SELECT 
	Escolaridade,
	round(AVG(Renda_Anual)) AS renda_media
FROM clientes
GROUP BY Escolaridade
ORDER BY renda_media DESC;

-- Entendendo a distribuição dos atributos a partir do filtro para Sexo Feminino. Visualizando de forma mais aprofundada clientes do sexo feminino
SELECT
	Escolaridade, 
    count(Escolaridade) AS qtde,
    sum(Qtd_Filhos) AS qtde_Filhos,
	round(avg(Renda_Anual)) AS media_Renda
FROM clientes
WHERE Sexo = "Feminino"
GROUP BY Escolaridade
ORDER BY media_Renda DESC;

-- Aplicando o mesmo processo para clientes masculino
SELECT
	Escolaridade, 
    count(Escolaridade) AS qtde,
    sum(Qtd_Filhos) AS qtde_Filhos,
	round(avg(Renda_Anual)) AS media_Renda
FROM clientes
WHERE Sexo = "Masculino"
GROUP BY Escolaridade
ORDER BY media_Renda DESC;

-- Os cálculos a seguir são feitos para buscar relações entre as variáveis. Neste caso, a intenção é observar se a menor média de renda anual está relacionado com a maior
-- média de filhos entre os clientes. O resultado é que não, pois a menor renda tem a segunda menor média de filhos. Contudo, analisando pelo lado de a maior renda 
-- estar ligada com a menor quantidade de filhos, é uma afirmação verdadeira para ambos os sexos.

-- Clientes do sexo feminino
SELECT
	Escolaridade,
	round(avg(Renda_Anual)) AS media_Renda,
    round(sum(Qtd_Filhos) / count(Escolaridade), 2) AS media_Filhos    
FROM clientes
WHERE Sexo = 'Feminino'
GROUP BY Escolaridade
ORDER BY media_Renda ASC;

-- Clientes do sexo masculino
SELECT
	Escolaridade,
	round(avg(Renda_Anual)) AS media_Renda,
    round(sum(Qtd_Filhos) / count(Escolaridade), 2) AS media_Filhos    
FROM clientes
WHERE Sexo = 'Masculino'
GROUP BY Escolaridade
ORDER BY media_Renda ASC; 

-- TOP 5 Clientes que mais compraram. Utilizando a função de janela DENSE RANK() para criar um ranking
-- Também foi utilizado o INNER JOIN para fazer a junção entre dados da tabela clientes e pedidos, buscando entender a relação entre ambos.
SELECT
	DENSE_RANK() OVER(ORDER BY sum(Receita_Venda) DESC) AS ranking,
	concat(c.Nome, ' ', c.Sobrenome) AS nomeCliente,		-- Função concat() para unir textos. Neste caso faz a união das colunas nome e sobrenome do cliente.
    sum(pd.Qtd_Vendida) AS qtdeComprada,
    sum(Receita_Venda) AS faturamentoCompra,
    c.Sexo,
    c.Escolaridade,
    c.Estado_Civil,
    c.Idade
FROM clientes c JOIN pedidos pd				-- Criando ALIAS para as tabelas
ON c.ID_Cliente = pd.ID_Cliente				-- Unindo a partir de chaves estrangeiras (Foreign Keys)
GROUP BY nomeCliente, c.Sexo, c.Escolaridade, c.Estado_Civil, c.Idade
LIMIT 5;

-- Visualizando a classificação da renda e a quantidade vendida para cada uma delas.
-- Resultado: Quanto menor a renda, mais vendas. Portanto, quanto maior a renda, menos vendas.
-- Então, evidencia que os produtos são destinados a pessoas com baixa renda.
SELECT 
	c.Renda_Anual,
    CASE
		WHEN c.Renda_Anual >= (SELECT AVG(Renda_Anual) FROM clientes)
        THEN 'Acima da Média'
        ELSE 'Abaixo da Média'
	END AS classificacaoRenda,
    sum(pd.Qtd_Vendida) AS qtdeVendida
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
GROUP BY Renda_Anual
ORDER BY Renda_Anual ASC;

-- Analisando as vendas por Escolaridade
SELECT
	c.Escolaridade,
    sum(pd.Qtd_Vendida) AS qtdeComprada,
    sum(Receita_Venda) AS faturamentoCompra
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
GROUP BY c.Escolaridade
ORDER BY faturamentoCompra DESC;

-- Analisando as vendas por Sexo
SELECT
	c.Sexo,
    sum(pd.Qtd_Vendida) AS qtdeComprada,
    sum(Receita_Venda) AS faturamentoCompra
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
GROUP BY c.Sexo
ORDER BY faturamentoCompra DESC;

-- Analisando as vendas por Estado Civil
-- Resultado: Homens casados compraram muito mais
SELECT
	c.Estado_Civil,
    sum(pd.Qtd_Vendida) AS qtdeComprada,
    sum(Receita_Venda) AS faturamentoCompra
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE c.Sexo = 'Masculino'
GROUP BY c.Estado_Civil
ORDER BY faturamentoCompra DESC;

-- Analisando vendas por Estado Civil
-- Resultado: Mulheres casadas compraram mais também, mas homens estão a frente
SELECT
	c.Estado_Civil,
    sum(pd.Qtd_Vendida) AS qtdeComprada,
    sum(Receita_Venda) AS faturamentoCompra
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE c.Sexo = 'Feminino'
GROUP BY c.Estado_Civil
ORDER BY faturamentoCompra DESC;

-- Analisando vendas por faixa etária
-- Foi utilizado o conceito CTE (Commom Table Expression) para melhorar a legibilidade do código e facilitar a manipulação de dados, otimizando a consulta.
WITH faixaEtaria AS (
	SELECT
		ID_Cliente,
		Idade,
        CASE									-- Coluna 'faixaEtaria' criada dependente dos valores de idade. Foi criada para facilitar a análise classificando os clientes em faixas etárias.
			WHEN idade <= 35
			THEN 'Até 35 Anos'
			WHEN Idade BETWEEN 36 AND 50 		-- Idade ENTRE 36 e 50 anos
			THEN 'Até 50 Anos'
			ELSE 'Maior que 50 Anos'
		END AS faixaEtaria
    FROM clientes
),
pedidos AS (									-- CTE pedidos para otimizar a consulta dos pedidos
	SELECT 
		ID_Cliente,
		sum(Qtd_Vendida) AS qtdeVendida,
		sum(Receita_Venda) AS faturamento
    FROM pedidos
    GROUP BY ID_Cliente
)
SELECT													-- Visualizando a consulta
	f.faixaEtaria,
	sum(pd.qtdeVendida) AS qtdeVendida,
    sum(pd.faturamento) AS faturamento
FROM faixaEtaria f 
JOIN pedidos pd
ON f.ID_Cliente = pd.ID_Cliente 
GROUP BY faixaEtaria
ORDER BY faturamento DESC;

# EDA - Exploratory Data Analysis (Análise Exploratória dos Dados)

-- Analisando a idade dos clientes. Etapa importante para verificar possíveis outliers
-- Resultado: Tudo OK
SELECT
	max(Idade) AS maximo,
    min(Idade) AS minimo,
    round(avg(Idade)) AS média
FROM clientes;

-- Verificação da distribuição dos valores de renda
SELECT
	round(min(Renda_Anual)) AS menor_Renda,
    round(avg(Renda_Anual)) AS media_Renda,
    round(max(Renda_Anual)) AS max_Renda
FROM clientes;