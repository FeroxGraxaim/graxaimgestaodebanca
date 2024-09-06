CREATE TEMPORARY TABLE "TempBanca" AS SELECT * FROM Banca;
DROP TABLE IF EXISTS "Banca";
CREATE TABLE IF NOT EXISTS "Banca" (
	"Mês"	INTEGER,
	"Ano"	INTEGER,
	"Valor_Inicial"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro_R$"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro_%"	NUMERIC(9, 2) DEFAULT 0,
	"Valor_Final"	NUMERIC(9, 2) DEFAULT 0,
	"Stake"	NUMERIC(9, 2) DEFAULT 0
);

INSERT INTO "Banca" SELECT * FROM TempBanca;

DROP TABLE TempBanca;

CREATE TEMPORARY TABLE TempPaises AS SELECT * FROM Países;

DROP TABLE IF EXISTS "Países";
CREATE TABLE IF NOT EXISTS "Países" (
	"Selecao"	BOOLEAN DEFAULT 0,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	"P/L"	INTEGER DEFAULT 0,
	PRIMARY KEY("País")
);

INSERT INTO Países SELECT * FROM TempPaises;

CREATE TEMPORARY TABLE TempTimes AS SELECT * FROM Times;

DROP TABLE IF EXISTS "Times";
CREATE TABLE IF NOT EXISTS "Times" (
	"Selecao"	BOOLEAN DEFAULT 0,
	"Time"	VARCHAR NOT NULL,
	"País"	VARCHAR NOT NULL,
	"Mandante"	INTEGER DEFAULT 0,
	"Visitante"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	PRIMARY KEY("Time")
);

INSERT INTO Times SELECT * FROM TempTimes;

DROP TABLE TempTimes;

CREATE TEMPORARY TABLE TempComp AS SELECT * FROM Competicoes;

DROP TABLE IF EXISTS "Competicoes";
CREATE TABLE IF NOT EXISTS "Competicoes" (
	"Cod_Comp"	INTEGER NOT NULL,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Competicao"	VARCHAR,
	"País"	VARCHAR,
	"Mercados"	INTEGER DEFAULT 0,
	"Green"	INTEGER DEFAULT 0,
	"Red"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Total"	NUMERIC DEFAULT 0,
	PRIMARY KEY("Cod_Comp" AUTOINCREMENT)
);

INSERT INTO Competicoes SELECT * FROM TempComp;

DROP TABLE TempComp; 

CREATE TEMPORARY TABLE TempMetodos AS SELECT * FROM Métodos;

DROP TABLE IF EXISTS "Métodos";
CREATE TABLE IF NOT EXISTS "Métodos" (
	"Cod_Metodo"	INTEGER,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Nome"	VARCHAR,
	PRIMARY KEY("Cod_Metodo" AUTOINCREMENT)
);

INSERT INTO Métodos SELECT * FROM TempMetodos;
DROP TABLE TempMetodos;

CREATE TEMPORARY TABLE TempLinhas AS SELECT * FROM Linhas;

DROP TABLE IF EXISTS "Linhas";
CREATE TABLE IF NOT EXISTS "Linhas" (
	"Cod_Linha"	INTEGER NOT NULL,
	"Nome"	VARCHAR,
	"Cod_Metodo"	INTEGER,
	FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	PRIMARY KEY("Cod_Linha" AUTOINCREMENT)
);

INSERT INTO Linhas SELECT * FROM TempLinhas;

DROP TABLE TempLinhas;

CREATE TEMPORARY TABLE TempMercados AS SELECT * FROM Mercados;
DROP TABLE IF EXISTS "Mercados";
CREATE TABLE IF NOT EXISTS "Mercados" (
	"Cod_Jogo"	INTEGER,
	"Cod_Metodo"	INTEGER,
	"Cod_Linha"	INTEGER,
	"Odd"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Cod_Aposta"	INTEGER,
	CONSTRAINT "FK_Mercados_Linhas_3" FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	CONSTRAINT "FK_Mercados_Apostas" FOREIGN KEY("Cod_Aposta") REFERENCES "Apostas"("Cod_Aposta"),
	CONSTRAINT "FK_Mercados_Jogo_2" FOREIGN KEY("Cod_Linha") REFERENCES "Linhas"("Cod_Linha")
);

INSERT INTO Mercados SELECT * FROM TempMercados;
DROP TABLE TempMercados;

CREATE TEMPORARY TABLE TempApostas AS SELECT * FROM Apostas;
DROP TABLE IF EXISTS "Apostas";
CREATE TABLE IF NOT EXISTS "Apostas" (
	"Cod_Aposta"	INTEGER,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Data"	DATE,
	"Múltipla"	BOOLEAN DEFAULT 0,
	"Odd"	NUMERIC(9, 2),
	"Valor_Aposta"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Tipo"	BOOLEAN DEFAULT 0,
	"Cashout"	BOOLEAN DEFAULT 0,
	"Retorno"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro"	NUMERIC(9, 2) DEFAULT 0,
	"Banca_Final"	NUMERIC(9, 2) DEFAULT 0,
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT)
);

INSERT INTO Apostas SELECT * FROM TempApostas;
DROP TABLE TempApostas;

CREATE TEMPORARY TABLE TempJogo AS SELECT * FROM Jogo;

DROP TABLE IF EXISTS "Jogo";
CREATE TABLE IF NOT EXISTS "Jogo" (
	"Cod_Jogo"	INTEGER NOT NULL,
	"Cod_Comp"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	FOREIGN KEY("Cod_Comp") REFERENCES "Competicoes"("Cod_Comp"),
	PRIMARY KEY("Cod_Jogo" AUTOINCREMENT),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time")
);

INSERT INTO Jogo SELECT * FROM TempJogo;

DROP TABLE TempJogo;

DROP TRIGGER IF EXISTS "Atualiza Banca Final (Delete)";
CREATE TRIGGER "Atualiza Banca Final (Delete)" AFTER DELETE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', OLD.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', OLD.Data))),0), 2) WHERE Banca.Mês = strftime('%m', OLD.Data) AND Banca.Ano = strftime('%Y', OLD.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Insert)";
CREATE TRIGGER "Atualiza Banca Final (Insert)" AFTER INSERT ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Update)";
CREATE TRIGGER "Atualiza Banca Final (Update)" AFTER UPDATE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Cashout";
CREATE TRIGGER "Cashout"
AFTER UPDATE ON Apostas 
FOR EACH ROW 
BEGIN
UPDATE Apostas 
SET Lucro = Retorno - Valor_Aposta
WHERE Cod_Aposta = NEW.Cod_Aposta 
AND Cashout = 1;
END;
DROP TRIGGER IF EXISTS "Atualiza Apostas";
CREATE TRIGGER "Atualiza Apostas" 
AFTER UPDATE ON Mercados 
FOR EACH ROW 
BEGIN 
UPDATE Apostas SET Status = 'Red' 
WHERE Cod_Aposta = NEW.Cod_Aposta 
AND Cashout = 0 
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red'); 

UPDATE Apostas SET Status = 'Green' WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red') 
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live'); 

UPDATE Apostas SET Status = 'Pré-live' WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red') 
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live'); 

END;

UPDATE ControleVersao SET Versao = 13;
UPDATE Mercados SET Status = Status;
UPDATE Apostas SET Status = Status;
