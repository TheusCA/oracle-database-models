------------------------------------------------------------------
-- BLOCO 1: CONCEITOS BÁSICOS (Variáveis, Atribuição e Saída)
------------------------------------------------------------------
DECLARE
    -- Declaração de variável numérica com até 3 dígitos (ex: 999)
    IDADE NUMBER(3);
    
    -- Declaração com inicialização: já começa valendo 1000. 
    -- (10,2) significa 10 dígitos totais, sendo 2 decimais.
    V_SALARIO NUMBER(10,2) := 1000;
    
    -- Variável de texto de tamanho variável (até 120 caracteres)
    V_NOME VARCHAR2(120);

BEGIN
    -- Atribuição de valor (Lembre-se: em PL/SQL usa-se := para atribuir)
    IDADE := 35;
    
    -- Operação aritmética simples
    IDADE := IDADE * 2;
    
    -- Atribuição de string (texto deve estar entre aspas simples)
    V_NOME := 'MARIA';
    
    -- Atribuição de valor de uma variável para outra
    V_SALARIO := IDADE;
    
    -- Imprime o resultado no console. O "||" serve para concatenar (juntar) texto e variável.
    DBMS_OUTPUT.PUT_LINE('A IDADE E:' || IDADE);

END;

------------------------------------------------------------------
------------------------------------------------------------------

------------------------------------------------------------------
-- BLOCO 2: SELECT INTO e ANCORAGEM DE TIPOS (%TYPE)
------------------------------------------------------------------
DECLARE 
    -- %TYPE: A variável assume automaticamente o mesmo tipo da coluna EMPLOYEE_ID da tabela EMPLOYEES.
    -- Isso evita erros se o tipo da coluna mudar no banco de dados.
    V_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;

BEGIN
    V_EMPLOYEE_ID := 105; -- Definindo qual funcionário queremos buscar
    
    -- SELECT ... INTO: Obrigatório em PL/SQL. O resultado da busca vai para a variável V_FIRST_NAME.
    -- Atenção: Esta consulta deve retornar exatamente UMA linha.
    SELECT FIRST_NAME INTO V_FIRST_NAME
        FROM EMPLOYEES
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID; -- Filtra pelo ID definido acima
    
    DBMS_OUTPUT.PUT_LINE('O NOME DO FUNCIONARIO E: ' || V_FIRST_NAME);

END;

--------------------------------------------------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-- BLOCO 3: SEPARAÇÃO SQL PURO vs PL/SQL (Exemplo Departamento)
--------------------------------------------------------------------

-- Exemplo de SQL puro apenas para testar o retorno antes de codificar
SELECT DEPARTMENT_NAME 
    FROM DEPARTMENTS 
WHERE DEPARTMENT_ID = 20;

-- Início do Bloco PL/SQL equivalente ao SQL acima
DECLARE
    -- Novamente usando %TYPE para garantir integridade com a tabela DEPARTMENTS
    V_DEPARTMENT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE;
    V_DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE;

BEGIN
    V_DEPARTMENT_ID := 20; -- "Hardcoding" o ID 20 na variável
    
    SELECT DEPARTMENT_NAME INTO V_DEPARTMENT_NAME
        FROM DEPARTMENTS
    WHERE DEPARTMENT_ID = V_DEPARTMENT_ID;  
    
    DBMS_OUTPUT.PUT_LINE('O NOME DO DEPARTAMENTO E: ' || V_DEPARTMENT_NAME);

END;

--------------------------------------------------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-- BLOCO 4: LÓGICA PROCEDURAL (Múltiplos Selects Passo-a-Passo)
--------------------------------------------------------------------
DECLARE 
    V_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
    V_DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE;
    V_DEPARTMENT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE; -- Variável auxiliar para guardar o ID do setor

BEGIN
    V_EMPLOYEE_ID := 174;
    
    -- Passo 1: Busca apenas o NOME do funcionário
    SELECT FIRST_NAME INTO V_FIRST_NAME
        FROM EMPLOYEES
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID;

    -- Passo 2: Busca o ID DO DEPARTAMENTO do funcionário (para usar no próximo select)
    SELECT DEPARTMENT_ID INTO V_DEPARTMENT_ID
        FROM EMPLOYEES
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID;   

    -- Passo 3: Com o ID do departamento em mãos, busca o NOME DO DEPARTAMENTO na outra tabela
    SELECT DEPARTMENT_NAME INTO V_DEPARTMENT_NAME
        FROM DEPARTMENTS
    WHERE DEPARTMENT_ID = V_DEPARTMENT_ID;    
    
    -- Exibe os resultados finais concatenados
    DBMS_OUTPUT.PUT_LINE('O NOME DO FUNCIONARIO E: ' || V_FIRST_NAME);
    DBMS_OUTPUT.PUT_LINE('E SEU DEPARTAMENTO É O: ' || V_DEPARTMENT_NAME);

END;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- BLOCO 5: OTIMIZAÇÃO PARCIAL (Reduzindo Queries)
-----------------------------------------------------------------------
DECLARE 
    V_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
    V_DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE;
    V_DEPARTMENT_ID DEPARTMENTS.DEPARTMENT_ID%TYPE;

BEGIN
    V_EMPLOYEE_ID := 174;
    
    -- Otimização: Buscando duas colunas (Nome e ID Dept) no mesmo SELECT
    -- As variáveis no INTO devem seguir a mesma ordem das colunas no SELECT
    SELECT FIRST_NAME, DEPARTMENT_ID INTO V_FIRST_NAME, V_DEPARTMENT_ID
        FROM EMPLOYEES
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID; 

    -- Busca o nome do departamento usando o ID recuperado acima
    SELECT DEPARTMENT_NAME INTO V_DEPARTMENT_NAME
        FROM DEPARTMENTS
    WHERE DEPARTMENT_ID = V_DEPARTMENT_ID;    
    
    DBMS_OUTPUT.PUT_LINE('O NOME DO FUNCIONARIO E: ' || V_FIRST_NAME || ' E SEU DEPARTAMENTO É O: ' || V_DEPARTMENT_NAME);

END;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- BLOCO 6: SOLUÇÃO RELACIONAL (JOIN - Melhor Prática)
-----------------------------------------------------------------------

-- SQL puro para validação da lógica de JOIN
SELECT FIRST_NAME, DEPARTMENT_NAME
    FROM EMPLOYEES EMP
LEFT JOIN DEPARTMENTS DEP
ON EMP.DEPARTMENT_ID = DEP.DEPARTMENT_ID
WHERE EMPLOYEE_ID = 174;

-- Bloco PL/SQL implementando o JOIN
DECLARE 
    V_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
    V_DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE;
    -- Note que não precisamos mais da variável V_DEPARTMENT_ID aqui

BEGIN
    V_EMPLOYEE_ID := 174;
    
    -- Busca tudo em uma única query usando JOIN.
    -- LEFT JOIN garante que trará o funcionário mesmo se ele não tiver departamento.
    SELECT FIRST_NAME, DEPARTMENT_NAME INTO V_FIRST_NAME, V_DEPARTMENT_NAME
        FROM EMPLOYEES EMP
    LEFT JOIN DEPARTMENTS DEP
    ON EMP.DEPARTMENT_ID = DEP.DEPARTMENT_ID
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID;
    
    DBMS_OUTPUT.PUT_LINE('O NOME DO FUNCIONARIO É ' || V_FIRST_NAME || ' E SEU DEPARTAMENTO É O ' || V_DEPARTMENT_NAME);

END;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- BLOCO 7: ESTRUTURAS CONDICIONAIS (IF / ELSE)
-----------------------------------------------------------------------
DECLARE 
    V_EMPLOYEE_ID EMPLOYEES.EMPLOYEE_ID%TYPE;
    V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
    V_DEPARTMENT_NAME DEPARTMENTS.DEPARTMENT_NAME%TYPE;

BEGIN
    V_EMPLOYEE_ID := 103; -- Alterado ID para testar um caso que seja de 'IT'
    
    -- Recupera os dados (reutilizando a lógica do JOIN do Bloco 6)
    SELECT FIRST_NAME, DEPARTMENT_NAME INTO V_FIRST_NAME, V_DEPARTMENT_NAME
        FROM EMPLOYEES EMP
    LEFT JOIN DEPARTMENTS DEP
    ON EMP.DEPARTMENT_ID = DEP.DEPARTMENT_ID
    WHERE EMPLOYEE_ID = V_EMPLOYEE_ID;

    -- INÍCIO DA LÓGICA CONDICIONAL
    -- Verifica se o conteúdo da variável é exatamente igual a 'IT'
    IF V_DEPARTMENT_NAME = 'IT' THEN
        -- Se for VERDADEIRO, altera o valor da variável (traduz para português)
        V_DEPARTMENT_NAME := 'TECNOLOGIA';
        
    ELSE
        -- Se for FALSO (qualquer outro departamento), cai aqui.
        -- Mantém o valor original. (Corrigido de "=" para ":=")
        V_DEPARTMENT_NAME := V_DEPARTMENT_NAME;
    END IF;
    -- FIM DO IF
    
    DBMS_OUTPUT.PUT_LINE('DEPARTAMENTO (TRADUZIDO SE FOR IT): ' || V_DEPARTMENT_NAME);

END;