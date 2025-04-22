# Projeto Análise de dados com Linguagem SQL #

# Análise base Lojas:

# Resumo com as principais análises:
-- A loja de BH foi a que mais faturou, já Niterói foi a que menos faturou.
-- A loja de São Paulo teve mais vendas, já Niterói teve menos vendas. Niterói também foi a que menos vendeu o principal produto da empresa.
-- Todas as lojas venderam muito bem o Headphone que é o carro chefe.
-- Todas as lojas seguiram o mesmo conceito e direcionamento de perfil de clientes, a principal diferença entre elas é quem conseguiu vender mais o principal produto.
-- O que pode explicar a diferença de vendas entre as lojas é a demanda de cada região para o tipo de produto da empresa.

# Visão geral

-- Visualizando a tabela lojas
SELECT * FROM lojas;

-- Visualizando as lojas que mais venderam utilizando o JOIN
SELECT
	l.Loja,
    sum(p.Qtd_Vendida) AS qtdeVendida,
    sum(p.Receita_Venda) AS faturamento
FROM lojas l JOIN pedidos p 
ON l.ID_Loja = p.ID_Loja
GROUP BY l.Loja
ORDER BY faturamento DESC;

-- Visualizando as lojas que mais venderam o principal produto da empresa. 
SELECT
	l.Loja,
    sum(p.Qtd_Vendida) AS qtdeVendida,
    sum(p.Receita_Venda) AS faturamento
FROM lojas l JOIN pedidos p 
ON l.ID_Loja = p.ID_Loja
WHERE ID_Produto = @produtoMaisVendido
GROUP BY l.Loja 
ORDER BY faturamento DESC;

-- Visualizando os produtos vendidos nas lojas. Utilizando CTE para manter a ligibilidade do código
WITH lojas AS (
	SELECT 
		ID_Loja,
		Loja 
    FROM lojas
),
produtos AS (
	SELECT
		ID_Produto,
		Nome_Produto 	
	FROM produtos
),
pedidos AS (
	SELECT
		ID_Produto,
        ID_Loja,
		sum(Qtd_Vendida) AS qtdeVendida,
        sum(Receita_Venda) AS faturamentoTotal
    FROM pedidos
    GROUP BY ID_Produto, ID_Loja
)
SELECT
	l.Loja,
    p.Nome_Produto,
    pd.qtdeVendida,
    pd.faturamentoTotal
FROM lojas l
JOIN pedidos pd 
ON l.ID_Loja = pd.ID_Loja
JOIN produtos p
ON p.ID_Produto = pd.ID_Produto
ORDER BY l.Loja DESC;

-- Criando variável para armazenar o nome da loja com mais vendas. Esse passo é importante porque, em caso de mudança da loja com mais vendas, a consulta não será 
-- afetada e ficará automática.
SET @lojaMaisVendas = 
	(SELECT ID_Loja FROM (
		SELECT
			l.ID_Loja,
			sum(p.Qtd_Vendida) AS qtdeVendida
		FROM lojas l JOIN pedidos p 
		ON l.ID_Loja = p.ID_Loja
		GROUP BY l.ID_Loja 
		ORDER BY qtdeVendida DESC
		) AS LojaMaisVendas
    LIMIT 1);
    
-- Visualizando a loja com mais vendas a partir do uso da variável
SELECT Loja FROM lojas WHERE ID_Loja = @LojaMaisVendas;

-- Visualizando os produtos na loja com mais vendas. 
-- Essa etapa é importante para entender se essa loja fez algo diferente das outras e, assim, aplicar o mesmo conceito.
SELECT
	p.Nome_Produto,
    sum(pd.Qtd_Vendida) AS qtdeVendida
FROM produtos p JOIN pedidos pd 
ON p.ID_Produto = pd.ID_Produto
WHERE pd.ID_Loja = @lojaMaisVendas		# Utilizando a variável criada para deixar a consulta otimizada
GROUP BY p.Nome_Produto
ORDER BY qtdeVendida DESC;

-- Verificando a distribuição de vendas do produto mais vendido 
SELECT
    l.Loja,
    SUM(pd.Qtd_Vendida) AS qtdeVendida,
    concat(round((SUM(pd.Qtd_Vendida) / 
    (SELECT SUM(pd.Qtd_Vendida) 
     FROM pedidos pd
     WHERE pd.ID_Produto = @produtoMaisVendido) * 100)), '%') AS '% Total'
FROM lojas l 
JOIN pedidos pd ON l.ID_Loja = pd.ID_Loja
WHERE pd.ID_Produto = @produtoMaisVendido
GROUP BY l.Loja
ORDER BY qtdeVendida DESC;

-- Verificando se a loja que menos vendeu está seguindo corretamente os padrões encontrados na base clientes.
-- O entendimento é que as vendas dos produtos são focadas em perfis de clientes com a renda baixa.
-- A loja que menos vende (Niterói) segue esse entendimento, o que pode nos representar que o número baixo de vendas pode estar relacionado a demanda baixa na região.
SELECT 
	c.Escolaridade,
    sum(pd.Qtd_Vendida) AS qtdeVendida
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE pd.ID_Loja = (SELECT ID_Loja FROM lojas WHERE Loja = 'Niterói')
GROUP BY c.Escolaridade
ORDER BY qtdeVendida DESC;

-- Em São Paulo, a loja que mais vendeu, o entendimento é o mesmo. O foco dos produtos devem ser pessoas com renda anual menor.
SELECT 
	c.Escolaridade,
    sum(pd.Qtd_Vendida) AS qtdeVendida,
    sum(pd.Receita_Venda) AS faturamento
FROM clientes c JOIN pedidos pd
ON c.ID_Cliente = pd.ID_Cliente
WHERE pd.ID_Loja =  @lojaMaisVendas
GROUP BY c.Escolaridade
ORDER BY qtdeVendida DESC;