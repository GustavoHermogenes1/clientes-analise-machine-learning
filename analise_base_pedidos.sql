# Projeto Análise de dados com Linguagem SQL #

# Análise base Pedidos:

-- No total, a quantidade de vendas do ano de 2019 chegou a 374, resultando em um faturamento de R$ 228.900,00
-- De fato, todos os clientes de nossa base Clientes fizeram pedidos? Resposta: Sim, todos os clientes da nossa base fizeram pedidos.

-- Visualizando se todos os clientes da base clientes fizeram pedidos.
-- Foi utilizado o LEFT JOIN para pegar todos os clientes da base clientes e comparar com os clientes da coluna ID_Cliente da base pedidos. Com essas colunas faremos a comparação.
-- Essa query retorna os IDs de clientes que não fizeram pedidos.
-- Neste caso, como todos fizeram, não retornará nada.
-- UPDATE: Após a criação da Procedure insereClientes e passado os valores de um novo cliente, aparecerá o valor 1 na consulta a seguir, que significa que o cliente de ID 101 não comprou
SELECT
	DISTINCT c.ID_Cliente,						-- DISTINCT usado para pegar os valores distintos de clientes, ou seja, sem repetição.
    isnull(pd.ID_Cliente) AS validacao 			-- O ISNULL verifica se o valor da coluna id_cliente é nulo na tabela pedidos. Se retornar 0 não é nulo. Se retornar 1, é nulo.
FROM clientes c LEFT JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
HAVING validacao <> 0;							-- HAVING é usado para filtrar valores. Neste caso, retorna os valores da coluna validacao diferente de 0. Ou seja, valores que seriam nulos.

# Periodicidade das vendas

-- Quantas vendas foram feitas por ano?
-- Observa-se que existem vendas apenas no ano de 2019. Portanto, é possível fazer apenas análises mês a mês deste ano.
SELECT
	year(Data_Venda) AS ano,
    sum(Qtd_Vendida) AS qtdeVendida,
    sum(Receita_Venda) AS faturamento
FROM pedidos
GROUP BY ano
ORDER BY faturamento DESC;

-- Criando variável para armazenar a média de receita por mês
SET @mediaReceita =
round((SELECT avg(receitaVendas) FROM(
	SELECT 
		month(Data_Venda) AS mês,
		sum(Receita_Venda) AS receitaVendas
	FROM pedidos
	GROUP BY mês
) AS media
));

SELECT @mediaReceita;

-- Números de vendas mês a mês e a classificação de acordo com a média dos números
SELECT
	month(Data_Venda) AS mês,
    sum(Qtd_Vendida) AS qtdeVendida,
    sum(Receita_Venda) AS receitaVendas,
    CASE
		WHEN sum(Receita_Venda) >= @mediaReceita
        THEN 'Acima da Média'
        ELSE 'Abaixo da média'
	END AS classificacaoReceita
FROM pedidos
GROUP BY mês
ORDER BY mês ASC;
-- Após essa query, é possível perceber que a média foi afetada pelo valor de janeiro ter sido muito acima. Portanto, esse não será o melhor indicador.

-- Mês que mais vendeu
SELECT
	month(Data_Venda) AS mês,
    sum(Qtd_Vendida) AS qtdeVendida,
    sum(Receita_Venda) AS receitaVendas
FROM pedidos
GROUP BY mês
ORDER BY receitaVendas DESC
LIMIT 1;

-- Mês que menos vendeu
SELECT
	month(Data_Venda) AS mês,
    sum(Qtd_Vendida) AS qtdeVendida,
    sum(Receita_Venda) AS receitaVendas
FROM pedidos
GROUP BY mês
ORDER BY receitaVendas ASC
LIMIT 1;