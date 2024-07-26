CREATE TABLE IF NOT EXISTS "Unidades" (
	"Unidade"	VARCHAR
);
CREATE TABLE IF NOT EXISTS "Perfis" (
	"Perfil"	VARCHAR,
	PRIMARY KEY("Perfil")
);
CREATE TABLE IF NOT EXISTS "Selecionar Perfil" (
	"Perfil Selecionado"	VARCHAR NOT NULL DEFAULT 'Conservador'
);
CREATE TABLE IF NOT EXISTS "Selecionar Mês e Ano" (
	"Mês"	INTEGER,
	"Ano"	INTEGER
);
CREATE TABLE IF NOT EXISTS "Banca" (
	"Mês"	INTEGER,
	"Ano"	INTEGER,
	"Valor_Inicial"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro_R$"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro_%"	NUMERIC(9, 2) DEFAULT 0,
	"Valor_Final"	NUMERIC(9, 2) DEFAULT 0,
	"Stake"	NUMERIC(9, 2) DEFAULT 0
);
CREATE TABLE IF NOT EXISTS "Status_Aposta" (
	"Cod_Status"	INTEGER,
	"Status"	VARCHAR,
	PRIMARY KEY("Cod_Status" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Países" (
	"Selec."	BOOLEAN DEFAULT 0,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	"P/L"	INTEGER DEFAULT 0,
	PRIMARY KEY("País")
);
CREATE TABLE IF NOT EXISTS "Times" (
	"Selec."	BOOLEAN DEFAULT 0,
	"Time"	VARCHAR NOT NULL,
	"País"	VARCHAR NOT NULL,
	"Mandante"	INTEGER DEFAULT 0,
	"Visitante"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	PRIMARY KEY("Time")
);
CREATE TABLE IF NOT EXISTS "ControleVersao" (
	"Versao"	INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "Estratégias" (
	"Cod_Estratégia"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Estratégia"	VARCHAR,
	"Mercados_Estr"	INTEGER DEFAULT 0,
	"Profit_Estr"	REAL DEFAULT 0.00,
	PRIMARY KEY("Cod_Estratégia" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Competições" (
	"Cod_Comp"	INTEGER NOT NULL,
	"Selec."	BOOLEAN DEFAULT 0,
	"Competição"	VARCHAR,
	"País"	VARCHAR,
	"Mercados"	INTEGER DEFAULT 0,
	"Green"	INTEGER DEFAULT 0,
	"Red"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Total"	NUMERIC DEFAULT 0,
	PRIMARY KEY("Cod_Comp" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Linhas" (
	"Cod_Linha"	INTEGER NOT NULL,
	"Nome"	VARCHAR,
	"Cod_Metodo"	INTEGER,
	FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	PRIMARY KEY("Cod_Linha" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "Métodos" (
	"Cod_Metodo"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Nome"	VARCHAR,
	PRIMARY KEY("Cod_Metodo" AUTOINCREMENT)
);

CREATE TEMPORARY TABLE TempApostas AS SELECT * FROM Apostas;
CREATE TEMPORARY TABLE TempMercados AS SELECT * FROM Mercados;
CREATE TEMPORARY TABLE TempJogo AS SELECT * FROM Jogo;

DROP TABLE Jogo;
DROP TABLE Mercados;
DROP TABLE Apostas;

CREATE TABLE Apostas (
    Cod_Aposta INTEGER PRIMARY KEY AUTOINCREMENT,
    "Selec." BOOLEAN DEFAULT 0,
    Data DATE,
    Múltipla BOOLEAN DEFAULT 0,
    Odd NUMERIC(9, 2),
    Valor_Aposta NUMERIC(9, 2),
    Status VARCHAR,
    Cod_Jogo INTEGER,
    Tipo BOOLEAN DEFAULT 0,
    Cashout BOOLEAN DEFAULT 0,
    Retorno NUMERIC(9, 2) DEFAULT 0,
    Lucro NUMERIC(9, 2) DEFAULT 0,
    Banca_Final NUMERIC(9, 2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "Mercados" (
	"Cod_Jogo"	INTEGER,
	"Cod_Metodo"	INTEGER,
	"Cod_Linha"	INTEGER,
	"Odd"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Cod_Aposta"	INTEGER,
	CONSTRAINT "FK_Mercados_Jogo_2" FOREIGN KEY("Cod_Linha") REFERENCES "Linhas"("Cod_Linha"),
	CONSTRAINT "FK_Mercados_Linhas_3" FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	CONSTRAINT "FK_Mercados_Apostas" FOREIGN KEY("Cod_Aposta") REFERENCES "Apostas"("Cod_Aposta")
);

CREATE TABLE IF NOT EXISTS "Jogo" (
	"Cod_Jogo"	INTEGER NOT NULL,
	"Cod_Comp"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	"Cod_Aposta"	INTEGER,
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time"),
	PRIMARY KEY("Cod_Jogo" AUTOINCREMENT),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Cod_Comp") REFERENCES "Competições"("Cod_Comp")
);

INSERT INTO Jogo SELECT * FROM TempJogo;
INSERT INTO Mercados SELECT * FROM TempMercados;
INSERT INTO Apostas SELECT * FROM TempApostas;

DROP TABLE TempJogo;
DROP TABLE TempMercados;
DROP TABLE TempApostas;

CREATE TRIGGER IF NOT EXISTS "Atualiza Status Aposta (Update)"
AFTER UPDATE ON Mercados
FOR EACH ROW 
BEGIN 
    UPDATE Apostas
    SET Status = 'Red'
    WHERE Cod_Aposta = NEW.Cod_Aposta
    AND Cashout = 0
    AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red');

    UPDATE Apostas
    SET Status = 'Green'
    WHERE Cod_Aposta = NEW.Cod_Aposta
    AND Cashout = 0
    AND (SELECT COUNT(*) FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta) = 
        (SELECT COUNT(*) FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Green');
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Status Aposta (Delete)"
AFTER DELETE ON Mercados
FOR EACH ROW 
BEGIN 
    UPDATE Apostas
    SET Status = 'Red'
    WHERE Cod_Aposta = OLD.Cod_Aposta
    AND Cashout = 0
    AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = OLD.Cod_Aposta AND Status = 'Red');

    UPDATE Apostas
    SET Status = 'Green'
    WHERE Cod_Aposta = OLD.Cod_Aposta
    AND Cashout = 0
    AND (SELECT COUNT(*) FROM Mercados WHERE Cod_Aposta = OLD.Cod_Aposta) = 
        (SELECT COUNT(*) FROM Mercados WHERE Cod_Aposta = OLD.Cod_Aposta AND Status = 'Green');
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (insert)" 
AFTER INSERT ON Apostas
FOR EACH ROW 
BEGIN
    -- Atualiza o Retorno
    UPDATE Apostas
    SET Retorno = CASE 
        WHEN Status = 'Green' THEN Odd * Valor_Aposta
        WHEN Status = 'Red' THEN 0 
        ELSE 0
    END
    WHERE rowid = NEW.rowid;

    -- Atualiza o Lucro
    UPDATE Apostas
    SET Lucro = CASE 
        WHEN Status = 'Green' THEN Retorno - Valor_Aposta
        WHEN Status = 'Red' THEN -Valor_Aposta
        ELSE 0
    END
    WHERE rowid = NEW.rowid;

    -- Atualiza a Banca_Final
    UPDATE Apostas
    SET Banca_Final = (
        SELECT IFNULL(
            (SELECT SUM(Lucro) 
             FROM Apostas 
             WHERE Cod_Aposta <= NEW.Cod_Aposta), 0
        ) + (SELECT Valor_Inicial 
             FROM Banca 
             WHERE Ano = strftime('%Y', NEW.Data) 
               AND Mês = strftime('%m', NEW.Data))
    )
    WHERE rowid = NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (Update)" 
AFTER UPDATE ON Apostas
FOR EACH ROW 
BEGIN
    -- Atualiza o Retorno
    UPDATE Apostas
    SET Retorno = CASE 
        WHEN Status = 'Green' THEN Odd * Valor_Aposta
        WHEN Status = 'Red' THEN 0 
        ELSE 0
    END
    WHERE rowid = NEW.rowid;

    -- Atualiza o Lucro
    UPDATE Apostas
    SET Lucro = CASE 
        WHEN Status = 'Green' THEN Retorno - Valor_Aposta
        WHEN Status = 'Red' THEN -Valor_Aposta
        ELSE 0
    END
    WHERE rowid = NEW.rowid;

    -- Atualiza a Banca_Final
    UPDATE Apostas
    SET Banca_Final = (
        SELECT IFNULL(
            (SELECT SUM(Lucro) 
             FROM Apostas 
             WHERE Cod_Aposta <= NEW.Cod_Aposta), 0
        ) + (SELECT Valor_Inicial 
             FROM Banca 
             WHERE Ano = strftime('%Y', NEW.Data) 
               AND Mês = strftime('%m', NEW.Data))
    )
    WHERE rowid = NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Odd Apostas (Update)"
AFTER UPDATE ON Mercados
FOR EACH ROW
BEGIN
  UPDATE Apostas
    SET Odd = ROUND((
        SELECT EXP(SUM(LN(COALESCE(Odd, 1))))
        FROM Mercados
        WHERE Cod_Aposta = NEW.Cod_Aposta), 2)
    WHERE Cod_Aposta = NEW.Cod_Aposta;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Odd Apostas (Delete)"
AFTER DELETE ON Mercados
FOR EACH ROW
BEGIN
  UPDATE Apostas
    SET Odd = ROUND((
        SELECT EXP(SUM(LN(COALESCE(Odd, 1))))
        FROM Mercados
        WHERE Cod_Aposta = OLD.Cod_Aposta), 2)
    WHERE Cod_Aposta = OLD.Cod_Aposta;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final (Delete)"
AFTER DELETE ON Apostas
FOR EACH ROW
BEGIN
  UPDATE Banca
  SET Valor_Final = ROUND(COALESCE(
    (SELECT Banca_Final
     FROM Apostas
     WHERE Cod_Aposta = (
       SELECT MAX(Cod_Aposta)
       FROM Apostas
       WHERE strftime('%m', Apostas.Data) = strftime('%m', OLD.Data)
         AND strftime('%Y', Apostas.Data) = strftime('%Y', OLD.Data))),0), 2)
  WHERE Banca.Mês = strftime('%m', OLD.Data)
    AND Banca.Ano = strftime('%Y', OLD.Data);
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final (Insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
  UPDATE Banca
  SET Valor_Final = ROUND(COALESCE(
    (SELECT Banca_Final
     FROM Apostas
     WHERE Cod_Aposta = (
       SELECT MAX(Cod_Aposta)
       FROM Apostas
       WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data)
         AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2)
  WHERE Banca.Mês = strftime('%m', NEW.Data)
    AND Banca.Ano = strftime('%Y', NEW.Data);
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final (Update)"
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
  UPDATE Banca
  SET Valor_Final = ROUND(COALESCE(
    (SELECT Banca_Final
     FROM Apostas
     WHERE Cod_Aposta = (
       SELECT MAX(Cod_Aposta)
       FROM Apostas
       WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data)
         AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2)
  WHERE Banca.Mês = strftime('%m', NEW.Data)
    AND Banca.Ano = strftime('%Y', NEW.Data);
END;
