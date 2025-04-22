# Projeto Análise de dados com Linguagem SQL #

# Análise base Produtos:

# Resumo com as principais análises:

-- O produto mais vendido foi o Headphone da Sony com 349 vendas, resultando também no maior faturamento (R$ 209.400,00). 
-- Porém a margem de lucro desse produto ficou abaixo da média (64.5%), pode ser feito um estudo para aumentar o valor do produto e, consequentemente, a margem e faturamento.
-- O produto com maior margem de lucro é a Webcam da Logitech com 80% e 6 quantidades vendidas. Porém, no ranking de produtos vendidos, ficou em último lugar.
-- Acredito que deva ser feito um estudo para análise das margens dos produtos e chegar em um número sustentável no qual equilibre as quantidades vendidas e lucro.
-- A SONY foi a marca que mais vendeu 
-- Na análise é possível observar que a relação de vendas x preço unitário é inversamente proporcional. Ou seja, se o preço é alto, as vendas tendem a serem baixas.
-- E, se o preço do produto é alto, significa que o custo também é alto. Portanto, se esses produtos estiverem em estoque é um problema para a empresa, já que
-- significa que foi pago valores altos em produtos que não corresponderam com vendas. 
-- Para se ter uma ideia, o produto com mais vendas é o quarto preço mais baixo.
-- Em resumo, uma possível análise é de que os clientes possuem uma preferência para comprar produtos mais baratos. Uma outra alternativa é que o marketing destes 
-- produtos estejam direcionados para perfis errados de clientes. Na análise da base de clientes, foi comentado o perfil ideal para direcionamento de marketing.
-- O produto mais vendido foi comprado na maioria das vezes por pessoas com escolaridade Parcial e Ensino Médio, que possuem a segunda e primeira menor renda anual,
-- respectivamente.
-- Portanto, deve ser feita a verificação do direcionamento das campanhas de marketing para os perfis corretos, já que, segundo estudos, as pessoas preferem produtos mais baratos.

# Visão geral dos produtos

-- Visualizando parte dos registros para verificar a disposição da tabela produtos 
SELECT * FROM produtos LIMIT 10;

-- Criação de VIEW para utilizar como um resumo da base produtos unindo informações importantes alguns KPIs, como margem de lucro.
-- A view, neste caso, será importante para que possa ser reutilizada como uma tabela resumo dos produtos em outras consultas.
CREATE VIEW vwprodutosanalise AS SELECT
	Nome_Produto,
    Marca_Produto,
    Custo_Unit,
    Preco_Unit,
    round((( (Preco_Unit - Custo_Unit) / Preco_Unit) * 100)) AS margem_Lucro			-- Criando coluna para mostrar a margem de lucro dos produtos
FROM produtos;

-- Utilizando o INNER JOIN para acrescentar as categorias e o ID_PRODUTO nesta view
-- A categoria irá permitir uma análise mais ampla dos produtos a partir das suas divisões.
-- O ID_PRODUTO será útil em prováveis JOINS que poderão ser feitos em futuras consultas.
ALTER VIEW vwprodutosanalise AS SELECT			-- Comando de ALTER VIEW para alterar uma view já criada
	p.ID_Produto,
	p.Nome_Produto,
    ctg.Categoria,
    p.Marca_Produto,
    p.Custo_Unit,
    p.Preco_Unit,
    concat( round(((( (Preco_Unit - Custo_Unit) / Preco_Unit) * 100))), '%') AS margem_Lucro		-- Concatenando para mostrar o símbolo de porcentagem
FROM produtos p 
JOIN categorias ctg 
ON p.ID_Categoria = ctg.ID_Categoria;

-- Visualizando os dados ordenando-os pela margem de lucro de forma decrescente
SELECT * FROM vwprodutosanalise ORDER BY margem_Lucro DESC;

# Análise e manipulação dos dados

-- Análise da Margem de Lucro dos produtos. Classificando as margens para entender quais produtos tem margens acima e abaixo da média geral.
SELECT 
	Nome_Produto,
    margem_Lucro,
	-- Classificação da Margem de Lucro
    CASE 
		WHEN margem_Lucro >= (SELECT AVG(margem_Lucro) FROM vwprodutosanalise)			-- Utilizando uma subquery para retornar o valor da margem de lucro média
        THEN 'Acima da Média'
        ELSE 'Abaixo da Média'
	END AS classificacaoMargem
FROM vwprodutosanalise;

-- Tabela de Produtos vendidos
-- Foi utilizado o LEFT JOIN para verificar também quais produtos não tiveram vendas, sendo identificados como NULL no resultado da query
SELECT 
	p.Nome_Produto,
	p.Categoria,
	p.Marca_Produto,
	sum(pd.Qtd_Vendida) AS qtdeTotalVendida,
    p.Preco_Unit * (sum(pd.Qtd_Vendida)) AS faturamentoProduto,				-- Calculando o faturamento do produto de acordo com a multiplicação da quantidade vendida x preço unitário
	p.margem_Lucro
FROM vwprodutosanalise p 
LEFT JOIN pedidos pd 
ON p.ID_Produto = pd.ID_Produto
GROUP BY p.Nome_Produto, p.Categoria, p.Marca_Produto, p.Preco_Unit, p.margem_Lucro 
ORDER BY faturamentoProduto DESC;

-- Utilizando subqueries para otimizar consultas e verificar a quantidade de produtos que foram negociados na tabela pedidos
SELECT 
	COUNT(ID_Produto) AS qtdeProdutosNaoVendidos,
	(SELECT count(ID_Produto) FROM produtos) AS qtdeProdutosTotal		-- Criando uma coluna com o resultado da subquery para retornar o total de produtos disponíveis e não ser afetado pelo filtro WHERE
FROM produtos
WHERE ID_Produto NOT IN (SELECT ID_Produto FROM pedidos);				-- Subquery para retornar todos os IDs de produtos que foram vendidos. NOT IN foi utilizado para mostrar os produtos que não foram vendidos

-- Verificando a relação das vendas com o preço do produto unitário para fortalecer o nosso estudo de perfil de clientes
-- Foi verificado que os clientes compram mais os produtos que têm menor preço
SELECT 
	p.Nome_Produto,
    p.Custo_Unit,
    p.Preco_Unit,
	sum(pd.Qtd_Vendida) AS qtdeTotalVendida,
    p.Preco_Unit * (sum(pd.Qtd_Vendida)) AS faturamentoProduto,
	p.margem_Lucro
FROM vwprodutosanalise p 
LEFT JOIN pedidos pd 
ON p.ID_Produto = pd.ID_Produto
GROUP BY p.Nome_Produto, p.Custo_Unit, p.Preco_Unit, p.margem_Lucro 
ORDER BY Preco_Unit ASC;			-- Ordenando a coluna de preço unitário de forma ascendente

-- Criando variável para armazenar o ID do produto mais vendido
-- Essa etapa ajudará na reutilização da variável em outras queries no banco de dados, além de manter a legibilidade.
SET @produtoMaisVendido =
	(SELECT ID_Produto FROM (
		SELECT 
			p.ID_Produto,
			sum(pd.Qtd_Vendida) AS qtdeVendida
		FROM produtos p JOIN pedidos pd
		ON p.ID_Produto = pd.ID_Produto
		GROUP BY p.ID_Produto
		ORDER BY qtdeVendida DESC
	) AS produtoMaisVendido
    LIMIT 1);
    
-- Visualizando o produto mais vendido
SELECT 
	Nome_Produto
FROM produtos
WHERE ID_Produto = @produtoMaisVendido;

-- Visualizando qual escolaridade mais comprou esse produto. 
-- Observando essa consulta é possível perceber a relação entre a baixa renda e o produto mais vendido.
SELECT 
	c.Escolaridade,
    sum(pd.Qtd_Vendida) AS qtdeVendida
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE pd.ID_Produto = @produtoMaisVendido 
GROUP BY c.Escolaridade
ORDER BY qtdeVendida DESC;

-- O Segundo produto que mais vendeu segue a mesma relação de escolaridade e quantidade de vendas. 
-- Todos os que compraram possuem escolaridade Parcial ou Ensino Médio.
SELECT 
	c.Escolaridade,
    sum(pd.Qtd_Vendida) AS qtdeVendida
FROM clientes c 
JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE pd.ID_Produto = (SELECT ID_Produto FROM produtos WHERE Nome_Produto LIKE '%Wireless')			-- Cláusula LIKE para fazer fazer a comparação e retornar a(s) linha(s) que termina(m) com a palavra WIRELESS
GROUP BY c.Escolaridade
ORDER BY qtdeVendida DESC;