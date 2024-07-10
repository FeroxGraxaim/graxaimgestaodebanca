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
CREATE TABLE IF NOT EXISTS "Apostas" (
	"Cod_Aposta"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Data"	DATE,
	"Competição_AP"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	"Estratégia_Escolhida"	VARCHAR,
	"Odd"	NUMERIC(9, 2),
	"Unidade"	VARCHAR,
	"Valor_Aposta"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Retorno"	NUMERIC(9, 2) DEFAULT 0,
	"Profit_L"	NUMERIC(9, 2) DEFAULT 0,
	"Banca_Final"	NUMERIC DEFAULT 0,
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Competições" (
	"Selec."	BOOLEAN DEFAULT 0,
	"Competição"	VARCHAR NOT NULL,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Green"	INTEGER DEFAULT 0,
	"Red"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Total"	NUMERIC DEFAULT 0
);
CREATE TABLE IF NOT EXISTS "Estratégias" (
	"Cod_Estratégia"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Estratégia"	VARCHAR,
	"Mercados_Estr"	INTEGER DEFAULT 0,
	"Profit_Estr"	REAL DEFAULT 0.00,
	PRIMARY KEY("Cod_Estratégia" AUTOINCREMENT)
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
CREATE TABLE IF NOT EXISTS "Jogo" (
	"Cod_Logo"	INTEGER NOT NULL,
	"Competição"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	"Estratégia"	VARCHAR,
	"Odd"	NUMERIC(9, 2),
	"Situação"	INTEGER,
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Estratégia") REFERENCES "Estratégias"("Estratégia"),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Competição") REFERENCES "Competições"("Competição"),
	PRIMARY KEY("Cod_Logo" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Aposta Múltipla" (
	"Cod_Aposta"	INTEGER NOT NULL,
	"Cod_Jogo"	INTEGER,
	"Status"	INTEGER,
	FOREIGN KEY("Cod_Jogo") REFERENCES "Jogo"("Cod_Logo"),
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT)
);
DROP TRIGGER IF EXISTS "Corrige Valores";
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Update)" AFTER UPDATE ON Times BEGIN UPDATE Países SET Mercados = (Mercados - OLD.Mandante - OLD.Visitante) + NEW.Mandante + NEW.Visitante WHERE País = NEW.País; END;
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Insert)" AFTER INSERT ON Times BEGIN UPDATE Países SET Mercados = Mercados + NEW.Mandante + NEW.Visitante WHERE País = NEW.País; END;
CREATE TRIGGER IF NOT EXISTS after_insert_times AFTER INSERT ON Times FOR EACH ROW BEGIN UPDATE Times SET Mandante = 0, Visitante = 0, Greens = 0, Reds = 0, "P/L" = 0 WHERE "Time" = NEW."Time"; END;
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Delete)" AFTER DELETE ON Times BEGIN UPDATE Países SET Mercados = Mercados - OLD.Mandante - OLD.Visitante WHERE País = OLD.País; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Times SET Mandante = Mandante - 1 WHERE "Time" = OLD.Mandante; UPDATE Times SET Visitante = Visitante - 1 WHERE "Time" = OLD.Visitante; UPDATE Times SET Mandante = Mandante + 1 WHERE "Time" = NEW.Mandante; UPDATE Times SET Visitante = Visitante + 1 WHERE "Time" = NEW.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Times SET Mandante = Mandante - 1 WHERE "Time" = OLD.Mandante; UPDATE Times SET Visitante = Visitante - 1 WHERE "Time" = OLD.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Times SET Mandante = Mandante + 1 WHERE "Time" = NEW.Mandante; UPDATE Times SET Visitante = Visitante + 1 WHERE "Time" = NEW.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Calcular Retorno e P/L Aposta (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Apostas SET Retorno = CASE NEW.Status WHEN 'Green' THEN Valor_Aposta * Odd WHEN 'Red' THEN 0 WHEN 'Meio Green' THEN (Valor_Aposta * Odd) / 2 WHEN 'Meio Red' THEN 0 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Retorno END, Profit_L = CASE NEW.Status WHEN 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta WHEN 'Red' THEN -Valor_Aposta WHEN 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2 WHEN 'Meio Red' THEN -Valor_Aposta / 2 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Profit_L END WHERE Cod_Aposta = NEW.Cod_Aposta; END;
CREATE TRIGGER IF NOT EXISTS "Calcular Retorno e P/L Aposta (UPDATE)" AFTER UPDATE ON Apostas BEGIN UPDATE Apostas SET Retorno = CASE NEW.Status WHEN 'Green' THEN Valor_Aposta * Odd WHEN 'Red' THEN 0 WHEN 'Meio Green' THEN (Valor_Aposta * Odd) / 2 WHEN 'Meio Red' THEN 0 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Retorno END, Profit_L = CASE NEW.Status WHEN 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta WHEN 'Red' THEN -Valor_Aposta WHEN 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2 WHEN 'Meio Red' THEN -Valor_Aposta / 2 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Profit_L END WHERE Cod_Aposta = NEW.Cod_Aposta; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados - 1 WHERE "Competição" = OLD.Competição_AP; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados + 1 WHERE "Competição" = NEW.Competição_AP; UPDATE Competições SET Mercados = Mercados - 1 WHERE "Competição" = OLD.Competição_AP; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados + 1 WHERE "Competição" = NEW.Competição_AP; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr + 1 WHERE "Estratégia" = NEW.Estratégia_Escolhida; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr + 1 WHERE "Estratégia" = NEW.Estratégia_Escolhida; UPDATE Estratégias SET Mercados_Estr = Mercados_Estr - 1 WHERE "Estratégia" = OLD.Estratégia_Escolhida; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr - 1 WHERE "Estratégia" = OLD.Estratégia_Escolhida; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens e Reds P/L Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Times SET Greens = Greens + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END WHERE "Time" = NEW.Mandante OR "Time" = NEW.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens Reds P/L Time (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Times SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens Reds P/L Time (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Times SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante; END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro Banca (Delete Apostas)" AFTER DELETE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', OLD.Data) = strftime('%Y', Apostas.Data) AND strftime('%m', OLD.Data) = strftime('%m', Apostas.Data) ) WHERE Ano = strftime('%Y', OLD.Data) AND Mês = strftime('%m', OLD.Data); END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro Banca (Insert Apostas)" AFTER INSERT ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', NEW.Data) = Ano AND strftime('%m', NEW.Data) = Mês ) WHERE Ano = strftime('%Y', NEW.Data) AND Mês = strftime('%m', NEW.Data); END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro Banca (Update Apostas)" AFTER UPDATE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', NEW.Data) = Ano AND strftime('%m', NEW.Data) = Mês ) WHERE Ano = strftime('%Y', NEW.Data) AND Mês = strftime('%m', NEW.Data); END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro % e Valor Final Banca (Update)" AFTER UPDATE ON Banca FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_%" = CASE WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE (NEW.Valor_Final - NEW.Valor_Inicial) / NEW.Valor_Inicial * 100 END WHERE rowid = NEW.rowid; UPDATE Banca SET Valor_Final = NEW.Valor_Inicial + "Lucro_R$" WHERE rowid = NEW.rowid; END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro % e Valor Final Banca (Insert)" after insert on Banca for each row begin UPDATE Banca SET "Lucro_%" = CASE WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE CASE WHEN NEW."Valor_Inicial" != 0 THEN (NEW."Valor_Final" - NEW."Valor_Inicial") / NEW."Valor_Inicial" * 100 END END WHERE rowid = NEW.rowid; update Banca set Valor_Final = Valor_Inicial + Lucro_R$ where rowid = NEW.ROWID; END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (insert)" 
AFTER INSERT ON Apostas 
FOR EACH ROW 
BEGIN 
    UPDATE Apostas 
    SET Banca_Final = (
        SELECT IFNULL((
            SELECT SUM(Profit_L) 
            FROM Apostas 
            WHERE Cod_Aposta <= NEW.Cod_Aposta
        ) + Valor_Inicial, 0)
        FROM Banca 
        WHERE Ano = strftime('%Y', NEW.Data) 
          AND Mês = strftime('%m', NEW.Data)
    ) 
    WHERE rowid = NEW.rowid; 

    UPDATE Apostas 
    SET Banca_Final = (
        SELECT IFNULL((
            SELECT Banca_Final + Profit_L 
            FROM Apostas 
            WHERE rowid = Apostas.rowid - 1
        ), 0)
    ) 
    WHERE rowid > NEW.rowid; 
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (Update)" 
AFTER UPDATE ON Apostas 
FOR EACH ROW 
BEGIN 
    UPDATE Apostas 
    SET Banca_Final = (
        SELECT IFNULL((
            SELECT SUM(Profit_L) 
            FROM Apostas 
            WHERE Cod_Aposta <= NEW.Cod_Aposta
        ) + Valor_Inicial, 0)
        FROM Banca 
        WHERE Ano = strftime('%Y', NEW.Data) 
          AND Mês = strftime('%m', NEW.Data)
    ) 
    WHERE rowid = NEW.rowid; 

    UPDATE Apostas 
    SET Banca_Final = (
        SELECT IFNULL((
            SELECT Banca_Final + Profit_L 
            FROM Apostas 
            WHERE rowid = Apostas.rowid - 1
        ), 0)
    ) 
    WHERE rowid > NEW.rowid; 
END;
CREATE TRIGGER IF NOT EXISTS "Corrige Valores Banca" 
AFTER UPDATE ON Banca 
FOR EACH ROW 
BEGIN 
UPDATE Banca 
SET Stake = ROUND(NEW.Stake, 2), 
Valor_Final = ROUND(NEW.Valor_Final, 2), 
"Lucro_R$" = ROUND(NEW."Lucro_R$", 2), 
"Lucro_%" = ROUND(NEW."Lucro_%", 2) 
WHERE ROWID = NEW.ROWID; 
END;
CREATE TRIGGER IF NOT EXISTS "Corrige Valores Apostas(Insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
UPDATE Apostas
SET Retorno = ROUND(NEW.Retorno, 2),
Profit_L = ROUND (NEW.Profit_L, 2),
Banca_Final = ROUND (NEW.Banca_Final, 2)
WHERE ROWID = NEW.ROWID;
END;
CREATE TRIGGER IF NOT EXISTS "Corrige Valores Apostas(Update)"
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
UPDATE Apostas
SET Retorno = ROUND(NEW.Retorno, 2),
Profit_L = ROUND (NEW.Profit_L, 2),
Banca_Final = ROUND (NEW.Banca_Final, 2)
WHERE ROWID = NEW.ROWID;
END;
