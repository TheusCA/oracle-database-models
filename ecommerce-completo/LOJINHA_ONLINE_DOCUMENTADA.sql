/********************************************************************************************
    SISTEMA DE VENDAS ONLINE – SCRIPT COMPLETO E DOCUMENTADO
    Foco: Explicação das CONSTRAINTS (PK, FK, UNIQUE, CHECK, etc.)
********************************************************************************************/

---------------------------------------------------------
-- DROPS (limpeza das tabelas antes de recriar)
---------------------------------------------------------

-- Remoção das tabelas de pagamento e relacionamento de pedidos/produtos, caso existam
DROP TABLE PAGAMENTO CASCADE CONSTRAINTS;
DROP TABLE PRODUTO_PEDIDO CASCADE CONSTRAINTS;
DROP TABLE PEDIDO CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA_PRODUTO CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA CASCADE CONSTRAINTS;
DROP TABLE PRODUTO CASCADE CONSTRAINTS;

-- Remoção das tabelas de cliente e endereço, caso existam
DROP TABLE PESSOA_JURIDICA CASCADE CONSTRAINTS;
DROP TABLE PESSOA_FISICA CASCADE CONSTRAINTS;
DROP TABLE TIPO_ENDERECO CASCADE CONSTRAINTS;
DROP TABLE ESTADO CASCADE CONSTRAINTS;
DROP TABLE CIDADES CASCADE CONSTRAINTS;
DROP TABLE ENDERECO CASCADE CONSTRAINTS;
DROP TABLE CLIENTE CASCADE CONSTRAINTS;


---------------------------------------------------------
-- TABELA: CLIENTE
-- Armazena dados básicos de todos os clientes (PF e PJ)
---------------------------------------------------------
CREATE TABLE CLIENTE(
    -- Chave primária da tabela (identifica unicamente o cliente)
    ID_CLIENTE NUMBER(9) PRIMARY KEY,

    EMAIL VARCHAR2(120) NOT NULL,
    SENHA VARCHAR2(512) NOT NULL,
    NOME VARCHAR2(120) NOT NULL,
    TIPO CHAR(1) NOT NULL,   -- 'F' = Pessoa Física, 'J' = Pessoa Jurídica
    TELEFONE VARCHAR2(20),

    -- Garante que nenhum outro cliente terá o mesmo e-mail (evita duplicidade)
    CONSTRAINT UQ_EMAIL_CLIENTE UNIQUE (EMAIL),

    -- Garante que o TIPO só pode ser 'J' ou 'F'
    CONSTRAINT CK_TIPO_CLIENTE CHECK (TIPO IN ('J', 'F')),

    -- Garante que o telefone não se repita entre clientes
    CONSTRAINT UQ_TEL_CLIENTE UNIQUE (TELEFONE)
);


---------------------------------------------------------
-- TABELA: TIPO_ENDERECO
-- Exemplo: Residencial, Comercial, etc.
---------------------------------------------------------
CREATE TABLE TIPO_ENDERECO(
    -- Chave primária do tipo de endereço
    ID_TIPO_ENDERECO NUMBER(1) PRIMARY KEY,
    NOME VARCHAR2(120) NOT NULL,
    
    -- Garante que não existirão dois tipos de endereço com o mesmo nome
    CONSTRAINT UQ_NOME UNIQUE (NOME)
);


---------------------------------------------------------
-- TABELA: ESTADO
-- Armazena as unidades federativas (UF)
---------------------------------------------------------
CREATE TABLE ESTADO(
    -- Usa a sigla (SP, RJ, etc.) como chave primária
    SIGLA_UF CHAR(2) PRIMARY KEY,
    NOME VARCHAR2(120) NOT NULL,

    -- Garante que o nome do estado não se repita
    CONSTRAINT UQ_NOME_ESTADO UNIQUE (NOME)
);


---------------------------------------------------------
-- TABELA: CIDADES
-- Armazena cidades e liga com ESTADO
---------------------------------------------------------
CREATE TABLE CIDADES(
    -- Chave primária da cidade
    ID_CIDADE NUMBER(10) PRIMARY KEY,

    NOME VARCHAR2(120) NOT NULL,
    COD_IBGE NUMBER(5) NOT NULL,
    SIGLA_UF CHAR(2) NOT NULL,

    -- Garante que não existam duas cidades com o mesmo nome
    CONSTRAINT UQ_NOME_CIDADE UNIQUE (NOME),

    -- Garante que o código IBGE da cidade não se repita
    CONSTRAINT UQ_COD_IBGE_CIDADE UNIQUE (COD_IBGE),

    -- Faz a ligação da cidade com a tabela ESTADO (chave estrangeira)
    -- Ou seja: SIGLA_UF precisa existir na tabela ESTADO
    CONSTRAINT FK_ESTADO_CIDADES FOREIGN KEY (SIGLA_UF)
        REFERENCES ESTADO (SIGLA_UF)
);


---------------------------------------------------------
-- TABELA: ENDERECO
-- Armazena o(s) endereço(s) do cliente
---------------------------------------------------------
CREATE TABLE ENDERECO(
    ID_CLIENTE NUMBER(9),
    ID_TIPO_ENDERECO NUMBER(1),
    LOGRADOURO VARCHAR2(120) NOT NULL,
    BAIRRO VARCHAR2(120) NOT NULL,
    NUMERO VARCHAR2(50) NULL, 
    ID_CIDADE NUMBER(10) NOT NULL,
    COMPLEMENTO VARCHAR2(255) NULL,
    CEP VARCHAR2(10) NOT NULL,

    -- Chave primária composta: um cliente pode ter mais de um endereço,
    -- mas não pode repetir o mesmo tipo (ex: dois "Residencial")
    CONSTRAINT PK_ENDERECO PRIMARY KEY (ID_CLIENTE, ID_TIPO_ENDERECO),

    -- Garante que o ID_CLIENTE exista na tabela CLIENTE (referência)
    CONSTRAINT FK_CLIENTE_ENDERECO FOREIGN KEY (ID_CLIENTE)
        REFERENCES CLIENTE (ID_CLIENTE),

    -- Garante que a cidade informada exista na tabela CIDADES
    CONSTRAINT FK_ENDERECO_CIDADE FOREIGN KEY (ID_CIDADE)
        REFERENCES CIDADES (ID_CIDADE)
);


---------------------------------------------------------
-- TABELA: PESSOA_FISICA
-- Detalhes específicos para clientes do tipo 'F'
---------------------------------------------------------
CREATE TABLE PESSOA_FISICA(
    -- Usa o mesmo ID_CLIENTE da tabela CLIENTE como chave primária
    ID_CLIENTE NUMBER(9) PRIMARY KEY,

    CPF VARCHAR2(11) NOT NULL,
    NOME VARCHAR2(120) NOT NULL,
    GENERO CHAR(1) NOT NULL,
    DATA_NASCIMENTO DATE NOT NULL,

    -- Garante que o CPF não se repita (um CPF = uma pessoa)
    CONSTRAINT UQ_CPF_PF UNIQUE (CPF),

    -- Garante que o ID_CLIENTE exista na tabela CLIENTE
    -- e reforça o vínculo 1:1 (Cliente x Pessoa_Física)
    CONSTRAINT FK_CLIENTE_PF FOREIGN KEY (ID_CLIENTE)
        REFERENCES CLIENTE (ID_CLIENTE),

    -- Garante que o gênero seja apenas 'M' ou 'F'
    CONSTRAINT CK_GENERO_PF CHECK (GENERO IN ('M', 'F'))
);


---------------------------------------------------------
-- TABELA: PESSOA_JURIDICA
-- Detalhes específicos para clientes do tipo 'J'
---------------------------------------------------------
CREATE TABLE PESSOA_JURIDICA(
    -- Usa o mesmo ID_CLIENTE da tabela CLIENTE como chave primária
    ID_CLIENTE NUMBER(9) PRIMARY KEY,

    CNPJ VARCHAR2(15) NOT NULL,
    RAZAO_SOCIAL VARCHAR2(120) NOT NULL,
    NOME_FANTASIA VARCHAR2(120) NOT NULL,
    INSCRICAO_ESTADUAL CHAR(12) NULL,

    -- Garante que o CNPJ não se repita (uma empresa por CNPJ)
    CONSTRAINT UQ_CNPJ_PJ UNIQUE (CNPJ),

    -- Garante que o ID_CLIENTE exista na tabela CLIENTE
    -- e reforça o vínculo 1:1 (Cliente x Pessoa_Jurídica)
    CONSTRAINT FK_CLIENTE_PJ FOREIGN KEY (ID_CLIENTE)
        REFERENCES CLIENTE (ID_CLIENTE),

    -- Garante que a inscrição estadual (se informada) não se repita
    CONSTRAINT UQ_INSCRICAO_ESTADUAL UNIQUE (INSCRICAO_ESTADUAL)
);


---------------------------------------------------------
-- TABELA: PRODUTO
-- Armazena os produtos vendidos no sistema
---------------------------------------------------------
CREATE TABLE PRODUTO(
    -- Chave primária do produto
    ID_PRODUTO NUMBER(10) PRIMARY KEY,

    NOME VARCHAR2(120) NOT NULL,
    PRECO NUMBER(10,2) NOT NULL,
    ESTOQUE NUMBER(5) NOT NULL,
    DESCRICAO VARCHAR2(2000) NULL,
    DESCONTO NUMBER(10,2) DEFAULT 0 NOT NULL,
    ATIVO CHAR(1) NOT NULL,

    -- Garante que o campo ATIVO seja apenas 'S' (sim) ou 'N' (não)
    CONSTRAINT CK_ATIVO_PRODUTO CHECK (ATIVO IN ('S', 'N')),

    -- Garante que o nome do produto não se repita
    CONSTRAINT UQ_NOME_PRODUTO UNIQUE (NOME)
);


---------------------------------------------------------
-- TABELA: CATEGORIA
-- Agrupa produtos em categorias (ex: Eletrônicos, Casa, etc.)
---------------------------------------------------------
CREATE TABLE CATEGORIA(
    -- Chave primária da categoria
    ID_CATEGORIA NUMBER(10) PRIMARY KEY,
    NOME VARCHAR2(120) NOT NULL,

    -- Garante que o nome da categoria não se repita
    CONSTRAINT UQ_NOME_CATEGORIA UNIQUE (NOME)
);


---------------------------------------------------------
-- TABELA: CATEGORIA_PRODUTO
-- Tabela de relacionamento N:N entre PRODUTO e CATEGORIA
---------------------------------------------------------
CREATE TABLE CATEGORIA_PRODUTO(
    ID_CATEGORIA NUMBER(10) NOT NULL,
    ID_PRODUTO NUMBER(10) NOT NULL,

    -- Chave primária composta:
    -- Garante que a combinação (ID_CATEGORIA, ID_PRODUTO) não se repita
    CONSTRAINT PK_PROD_CATEG PRIMARY KEY (ID_CATEGORIA, ID_PRODUTO),

    -- Garante que a categoria exista na tabela CATEGORIA
    CONSTRAINT FK_CATEGORIAPRODUTO_CATEGORIA FOREIGN KEY (ID_CATEGORIA)
        REFERENCES CATEGORIA (ID_CATEGORIA),

    -- Garante que o produto exista na tabela PRODUTO
    CONSTRAINT FK_CATEGORIAPRODUTO_PRODUTO FOREIGN KEY (ID_PRODUTO)
        REFERENCES PRODUTO (ID_PRODUTO)
);


---------------------------------------------------------
-- TABELA: PEDIDO
-- Representa uma compra realizada por um cliente
---------------------------------------------------------
CREATE TABLE PEDIDO(
    -- Chave primária do pedido
    ID_PEDIDO NUMBER(10) PRIMARY KEY,

    ID_CLIENTE NUMBER(10) NOT NULL,
    DATA_PEDIDO DATE DEFAULT SYSDATE NOT NULL,
    VALOR_TOTAL NUMBER(16,2) NOT NULL,

    -- Garante que o cliente do pedido exista na tabela CLIENTE
    CONSTRAINT FK_ID_CLIENTE_PEDIDO FOREIGN KEY (ID_CLIENTE)
        REFERENCES CLIENTE (ID_CLIENTE)
);


---------------------------------------------------------
-- TABELA: PRODUTO_PEDIDO
-- Itens do pedido (quais produtos foram comprados, quantos, etc.)
---------------------------------------------------------
CREATE TABLE PRODUTO_PEDIDO(
    ID_PEDIDO NUMBER(10),
    ID_PRODUTO NUMBER(10),
    SEQ_PRODUTO NUMBER(3) NOT NULL,        -- Sequência do item no pedido
    QUANTIDADE NUMBER(4) NOT NULL,
    PRECO_UNITARIO NUMBER(10,2) NOT NULL,
    SUB_TOTAL NUMBER(16,2) NOT NULL,

    -- Chave primária composta:
    -- Garante que o mesmo produto não seja repetido duas vezes no mesmo pedido
    CONSTRAINT PK_PRODUTO_PEDIDO PRIMARY KEY (ID_PEDIDO, ID_PRODUTO),

    -- Garante que o pedido exista na tabela PEDIDO
    CONSTRAINT FK_PEDIDO_PRODUTO_PEDIDO FOREIGN KEY (ID_PEDIDO)
        REFERENCES PEDIDO (ID_PEDIDO),

    -- Garante que o produto exista na tabela PRODUTO
    CONSTRAINT FK_PRODUTO_PRODUTO_PEDIDO FOREIGN KEY (ID_PRODUTO)
        REFERENCES PRODUTO (ID_PRODUTO)
);


---------------------------------------------------------
-- TABELA: PAGAMENTO
-- Registra a forma como o pedido foi pago
---------------------------------------------------------
CREATE TABLE PAGAMENTO(
    ID_PEDIDO NUMBER(10),
    ID_PAGAMENTO NUMBER(10),
    FORMA_PAGAMENTO CHAR(3) NOT NULL,      -- DEB, CRE, DIN, PIX
    VALOR_PAGO NUMBER(16,2) NOT NULL,
    DATA_PAGAMENTO DATE NOT NULL,

    -- Chave primária composta:
    -- Permite, por exemplo, mais de um registro se você quiser parcelar
    CONSTRAINT PK_PAGAMENTO PRIMARY KEY (ID_PEDIDO, ID_PAGAMENTO),

    -- Garante que a forma de pagamento seja um dos valores permitidos
    CONSTRAINT CK_FORMA_PAGAMENTO_PAGAMENTO CHECK (FORMA_PAGAMENTO IN ('DEB', 'CRE', 'DIN', 'PIX')),

    -- Garante que o pedido informado exista na tabela PEDIDO
    CONSTRAINT FK_PAGAMENTO_PEDIDO FOREIGN KEY (ID_PEDIDO)
        REFERENCES PEDIDO (ID_PEDIDO)
);


---------------------------------------------------------
-- INSERTS
-- Povoamento inicial do banco com dados de exemplo
---------------------------------------------------------

---------------------------------------------------------
-- ESTADOS
---------------------------------------------------------
INSERT INTO ESTADO (SIGLA_UF, NOME) VALUES ('SP', 'São Paulo');
INSERT INTO ESTADO (SIGLA_UF, NOME) VALUES ('RJ', 'Rio de Janeiro');
INSERT INTO ESTADO (SIGLA_UF, NOME) VALUES ('MG', 'Minas Gerais');
INSERT INTO ESTADO (SIGLA_UF, NOME) VALUES ('BA', 'Bahia');

---------------------------------------------------------
-- CIDADES (COD_IBGE agora tem apenas 5 dígitos)
---------------------------------------------------------
INSERT INTO CIDADES (ID_CIDADE, NOME, COD_IBGE, SIGLA_UF)
VALUES (1, 'São Paulo', 10001, 'SP');

INSERT INTO CIDADES (ID_CIDADE, NOME, COD_IBGE, SIGLA_UF)
VALUES (2, 'Rio de Janeiro', 10002, 'RJ');

INSERT INTO CIDADES (ID_CIDADE, NOME, COD_IBGE, SIGLA_UF)
VALUES (3, 'Belo Horizonte', 10003, 'MG');

INSERT INTO CIDADES (ID_CIDADE, NOME, COD_IBGE, SIGLA_UF)
VALUES (4, 'Salvador', 10004, 'BA');

---------------------------------------------------------
-- TIPO DE ENDEREÇO
---------------------------------------------------------
INSERT INTO TIPO_ENDERECO (ID_TIPO_ENDERECO, NOME) VALUES (1, 'Residencial');
INSERT INTO TIPO_ENDERECO (ID_TIPO_ENDERECO, NOME) VALUES (2, 'Comercial');

---------------------------------------------------------
-- CLIENTES (5 clientes)
---------------------------------------------------------
-- Pessoa Física
INSERT INTO CLIENTE VALUES (1, 'joao@dominio.com', 'senha123', 'João Silva', 'F', '11987654321');
INSERT INTO CLIENTE VALUES (2, 'maria@dominio.com', 'senha456', 'Maria Oliveira', 'F', '21987654321');

-- Pessoa Jurídica
INSERT INTO CLIENTE VALUES (3, 'empresa@dominio.com', 'senha789', 'Empresa X Ltda', 'J', '31387654321');
INSERT INTO CLIENTE VALUES (4, 'companhia@dominio.com', 'senha101', 'Companhia Y S.A', 'J', '41987654321');
INSERT INTO CLIENTE VALUES (5, 'startup@dominio.com', 'senha202', 'Startup Z', 'J', '51987654321');

---------------------------------------------------------
-- PESSOA FÍSICA
---------------------------------------------------------
INSERT INTO PESSOA_FISICA VALUES
(1, '12345678901', 'João Silva', 'M', TO_DATE('1990-05-15','YYYY-MM-DD'));

INSERT INTO PESSOA_FISICA VALUES
(2, '10987654321', 'Maria Oliveira', 'F', TO_DATE('1985-08-22','YYYY-MM-DD'));

---------------------------------------------------------
-- PESSOA JURÍDICA
---------------------------------------------------------
INSERT INTO PESSOA_JURIDICA VALUES
(3, '12345678000195', 'Empresa X Ltda', 'Empresa X', '123456789012');

INSERT INTO PESSOA_JURIDICA VALUES
(4, '98765432000170', 'Companhia Y S.A', 'Companhia Y', '987654321012');

INSERT INTO PESSOA_JURIDICA VALUES
(5, '19283746000150', 'Startup Z', 'Startup Z', NULL);

---------------------------------------------------------
-- ENDEREÇOS
---------------------------------------------------------
INSERT INTO ENDERECO VALUES
(1, 1, 'Rua 1', 'Bairro A', '123', 1, 'Apto 101', '01010100');

INSERT INTO ENDERECO VALUES
(2, 1, 'Avenida 2', 'Bairro B', '456', 2, 'Casa', '20202020');

INSERT INTO ENDERECO VALUES
(3, 2, 'Rua 3', 'Centro', '789', 3, 'Sala 202', '30303030');

---------------------------------------------------------
-- PRODUTOS
---------------------------------------------------------
INSERT INTO PRODUTO VALUES
(1, 'Produto A', 100.00, 10, 'Descrição do Produto A', 10.00, 'S');

INSERT INTO PRODUTO VALUES
(2, 'Produto B', 200.00, 20, 'Descrição do Produto B', 20.00, 'S');

INSERT INTO PRODUTO VALUES
(3, 'Produto C', 300.00, 30, 'Descrição do Produto C', 0.00, 'S');

---------------------------------------------------------
-- PEDIDOS
---------------------------------------------------------
INSERT INTO PEDIDO (ID_PEDIDO, ID_CLIENTE, VALOR_TOTAL)
VALUES (1, 1, 150.00);

INSERT INTO PEDIDO (ID_PEDIDO, ID_CLIENTE, VALOR_TOTAL)
VALUES (2, 2, 300.00);

---------------------------------------------------------
-- PRODUTOS DO PEDIDO
---------------------------------------------------------
-- Pedido 1
INSERT INTO PRODUTO_PEDIDO VALUES
(1, 1, 1, 1, 100.00, 100.00);

INSERT INTO PRODUTO_PEDIDO VALUES
(1, 2, 2, 1, 50.00, 50.00);

-- Pedido 2
INSERT INTO PRODUTO_PEDIDO VALUES
(2, 3, 1, 1, 300.00, 300.00);

---------------------------------------------------------
-- PAGAMENTOS
---------------------------------------------------------
INSERT INTO PAGAMENTO VALUES
(1, 1, 'PIX', 150.00, TO_DATE('2025-11-17','YYYY-MM-DD'));

INSERT INTO PAGAMENTO VALUES
(2, 1, 'DEB', 300.00, TO_DATE('2025-11-17','YYYY-MM-DD'));


---------------------------------------------------------
-- SELECTS DE CONSULTA DE CLIENTES PF E PJ
---------------------------------------------------------

-- Consulta apenas clientes pessoa física
SELECT * FROM CLIENTE C
INNER JOIN PESSOA_FISICA PF
  ON C.ID_CLIENTE = PF.ID_CLIENTE
WHERE C.TIPO = 'F'
ORDER BY PF.CPF ASC;

-- Consulta apenas clientes pessoa jurídica
SELECT * FROM CLIENTE C
INNER JOIN PESSOA_JURIDICA PJ
  ON C.ID_CLIENTE = PJ.ID_CLIENTE
WHERE C.TIPO = 'J'
ORDER BY PJ.CNPJ ASC;

-- Consulta unificada de PF e PJ, retornando CPF/CNPJ em uma mesma coluna DOCUMENTO
SELECT C.ID_CLIENTE,
       C.NOME,
       TIPO,
       PF.NOME RAZAO_SOCIAL,
       CPF AS DOCUMENTO,
       '' NOME_FANTASIA,
       GENERO
FROM CLIENTE C
INNER JOIN PESSOA_FISICA PF
    ON C.ID_CLIENTE = PF.ID_CLIENTE
WHERE TIPO = 'F'
UNION
SELECT C.ID_CLIENTE,
       NOME,
       TIPO,
       RAZAO_SOCIAL,
       CNPJ AS DOCUMENTO,
       NOME_FANTASIA,
       'X' GENERO
FROM CLIENTE C
INNER JOIN PESSOA_JURIDICA PJ
    ON C.ID_CLIENTE = PJ.ID_CLIENTE
WHERE TIPO = 'J';


---------------------------------------------------------
-- SELECT FILTRANDO SOMENTE OS REGISTROS DA PARTE JURÍDICA
-- (A partir da união anterior)
---------------------------------------------------------
SELECT * FROM (
    SELECT C.ID_CLIENTE,
           C.NOME,
           TIPO,
           PF.NOME RAZAO_SOCIAL,
           CPF AS DOCUMENTO,
           '' NOME_FANTASIA,
           GENERO
    FROM CLIENTE C
    INNER JOIN PESSOA_FISICA PF
        ON C.ID_CLIENTE = PF.ID_CLIENTE
    WHERE TIPO = 'F'
    UNION
    SELECT C.ID_CLIENTE,
           NOME,
           TIPO,
           RAZAO_SOCIAL,
           CNPJ AS DOCUMENTO,
           NOME_FANTASIA,
           'X' GENERO
    FROM CLIENTE C
    INNER JOIN PESSOA_JURIDICA PJ
        ON C.ID_CLIENTE = PJ.ID_CLIENTE
    WHERE TIPO = 'J'
) CLIENTES_UNION
WHERE CLIENTES_UNION.GENERO = 'X';


---------------------------------------------------------
-- VIEW: VIEW_CLIENTE
-- Cria uma visão que unifica PF e PJ numa mesma estrutura
---------------------------------------------------------
CREATE VIEW VIEW_CLIENTE AS (
    SELECT * FROM (
        SELECT C.ID_CLIENTE,
               C.NOME,
               TIPO,
               PF.NOME RAZAO_SOCIAL,
               CPF AS DOCUMENTO,
               '' NOME_FANTASIA,
               GENERO
        FROM CLIENTE C
        INNER JOIN PESSOA_FISICA PF
            ON C.ID_CLIENTE = PF.ID_CLIENTE
        WHERE TIPO = 'F'
        UNION
        SELECT C.ID_CLIENTE,
               NOME,
               TIPO,
               RAZAO_SOCIAL,
               CNPJ AS DOCUMENTO,
               NOME_FANTASIA,
               'X' GENERO
        FROM CLIENTE C
        INNER JOIN PESSOA_JURIDICA PJ
            ON C.ID_CLIENTE = PJ.ID_CLIENTE
        WHERE TIPO = 'J'
    ) CLIENTES_UNION
    WHERE CLIENTES_UNION.GENERO = 'X'
);

-- Consulta a view criada
SELECT * FROM VIEW_CLIENTE;
