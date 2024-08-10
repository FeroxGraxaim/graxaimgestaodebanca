CREATE TEMPORARY TABLE TempPaises AS SELECT * FROM "Países"
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

INSERT INTO "Países" ("País") SELECT "País" FROM "TempPaises";

DROP TABLE IF EXISTS "TempPaises";

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

INSERT INTO Times (Time, País) SELECT Time, País FROM TempTimes;

DROP TABLE TempTimes;

DROP TABLE IF EXISTS "ControleVersao";
CREATE TABLE IF NOT EXISTS "ControleVersao" (
	"Versao"	INTEGER NOT NULL
);

CREATE TEMPORARY TABLE TempComp AS SELECT * FROM Competições;
DROP TABLE IF EXISTS "Competições";
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

INSERT INTO Competicoes (Cod_Comp, Competicao, País) SELECT Cod_Comp, Competição, País FROM TempComp;

DROP TABLE TempComp;

DROP TABLE IF EXISTS "Linhas";
CREATE TABLE IF NOT EXISTS "Linhas" (
	"Cod_Linha"	INTEGER NOT NULL,
	"Nome"	VARCHAR,
	"Cod_Metodo"	INTEGER,
	FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	PRIMARY KEY("Cod_Linha" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Métodos";
CREATE TABLE IF NOT EXISTS "Métodos" (
	"Cod_Metodo"	INTEGER,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Nome"	VARCHAR,
	PRIMARY KEY("Cod_Metodo" AUTOINCREMENT)
);

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

INSERT INTO Apostas (Data, Odd, Valor_Aposta, Status, Retorno, Lucro, Banca_Final) 
SELECT Data, Odd, Valor_Aposta, Status, Retorno, Lucro, Banca_Final FROM TempApostas;
DROP TABLE TempApostas;

INSERT INTO "ControleVersao" ("Versao") VALUES (8);

INSERT INTO "Métodos" ("Cod_Metodo","Selecao","Nome") VALUES (1,'False','Resultado Equipe'),
 (3,'False','Handicap Asiático'),
 (4,'False','Handicap Europeu'),
 (15,0,'Mais Gols'),
 (16,0,'Menos Gols'),
 (17,0,'Mais Escanteios'),
 (18,0,'Menos Escanteios'),
 (19,0,'Mais Cartões'),
 (20,0,'Menos Cartões');
 
INSERT INTO "Linhas" ("Cod_Linha","Nome","Cod_Metodo") VALUES (30,'Europeu -3',4),
 (31,'Europeu -2',4),
 (32,'Europeu -1',4),
 (33,'Europeu +1',4),
 (34,'Europeu +2',4),
 (35,'Europeu +3',4),
 (36,'Asiático +3,5',3),
 (37,'Asiático +3,25',3),
 (38,'Asiático +3',3),
 (39,'Asiático +2,75',3),
 (40,'Asiático +2,5',3),
 (41,'Asiático +2,25',3),
 (42,'Asiático +2',3),
 (43,'Asiático +1,75',3),
 (44,'Asiático +1,5',3),
 (45,'Asiático +1,25',3),
 (46,'Asiático +1',3),
 (47,'Asiático +0,75',3),
 (48,'Asiático +0,5',3),
 (49,'Asiático +0,25',3),
 (50,'Asiático 0',3),
 (51,'Asiático -0,25',3),
 (52,'Asiático -0,5',3),
 (53,'Asiático -0,75',3),
 (54,'Asiático -1',3),
 (55,'Asiático -1,25',3),
 (56,'Asiático -1,5',3),
 (57,'Asiático -1,75',3),
 (58,'Asiático -2',3),
 (82,'Casa Vence',1),
 (83,'Fora Vence',1),
 (84,'Empate',1),
 (85,'Casa ou Empate',1),
 (86,'Fora ou Empate',1),
 (87,'Empate Anula Casa',1),
 (88,'Empate Anula Fora',1),
 (89,'Casa ou Fora',1),
 (108,'+ 0,5 Cantos',17),
 (109,'+ 1,5 Cantos',17),
 (110,'+ 2,5 Cantos',17),
 (111,'+ 3,5 Cantos',17),
 (112,'+ 4,5 Cantos',17),
 (113,'+ 5,5 Cantos',17),
 (114,'+ 6,5 Cantos',17),
 (115,'+ 7,5 Cantos',17),
 (116,'+ 8,5 Cantos',17),
 (117,'- 15,5 Cantos',18),
 (118,'- 14,5 Cantos',18),
 (119,'- 13,5 Cantos',18),
 (120,'- 12,5 Cantos',18),
 (121,'- 11,5 Cantos',18),
 (122,'- 10,5 Cantos',18),
 (123,'- 9,5 Cantos',18),
 (124,'- 8,5 Cantos',18),
 (125,'- 7,5 Cantos',18),
 (126,'- 6,5 Cantos',18),
 (127,'+ 0,5 Cartões Casa',19),
 (128,'+ 0,5 Cartões Fora',19),
 (129,'+ 1,5 Cartões Casa',19),
 (130,'+ 1,5 Cartões Fora',19),
 (132,'Ambos 1 Cartão',19),
 (133,'Ambos + 1,5 Cartões',19),
 (134,'+ 0,5 Cartões',19),
 (135,'+ 1,5 Cartões',19),
 (136,'+ 2,5 Cartões',19),
 (137,'+ 3,5 Cartões',19),
 (138,'+ 4,5 Cartões',19),
 (139,'+ 5,5 Cartões',19),
 (140,'- 7,5 Cartões',20),
 (141,'- 6,5 Cartões',20),
 (142,'- 5,5 Cartões',20),
 (143,'- 4,5 Cartões',20),
 (144,'- 3,5 cartões',20),
 (145,'+ 0,5 Gols',15),
 (146,'+ 1,5 Gols',15),
 (147,'+ 2,5 Gols',15),
 (148,'+ 3,5 Gols',15),
 (149,'+ 4,5 Gols',15),
 (150,'+ 5,5 Gols',15),
 (151,'- 10,5 Gols',16),
 (152,'- 9,5 Gols',16),
 (153,'- 8,5 Gols',16),
 (154,'- 7,5 Gols',16),
 (155,'- 6,5 Gols',16),
 (156,'- 5,5 Gols',16),
 (157,'- 4,5 Gols',16),
 (158,'- 3,5 Gols',16),
 (159,'- 2,5 Gols',16),
 (160,'- 1,5 Gols',16),
 (161,'- 0,5 Gols',16);
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Delete)";
CREATE TRIGGER "Atualiza Banca Final (Delete)" AFTER DELETE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', OLD.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', OLD.Data))),0), 2) WHERE Banca.Mês = strftime('%m', OLD.Data) AND Banca.Ano = strftime('%Y', OLD.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Insert)";
CREATE TRIGGER "Atualiza Banca Final (Insert)" AFTER INSERT ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Update)";
CREATE TRIGGER "Atualiza Banca Final (Update)" AFTER UPDATE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (Insert)";
CREATE TRIGGER "Atualiza Banca Final Apostas (Insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Apostas
    SET Retorno = CASE 
        WHEN NEW.Status = 'Green' THEN IFNULL((NEW.Odd * NEW.Valor_Aposta), 0) 
        WHEN NEW.Status = 'Red' THEN 0 
        ELSE 0 
    END
    WHERE rowid = NEW.rowid;

    UPDATE Apostas
    SET Lucro = CASE 
        WHEN NEW.Status = 'Green' THEN IFNULL((NEW.Odd * NEW.Valor_Aposta - NEW.Valor_Aposta), 0)
        WHEN NEW.Status = 'Red' THEN -NEW.Valor_Aposta 
        ELSE 0 
    END
    WHERE rowid = NEW.rowid;

    UPDATE Apostas
    SET Banca_Final = (
        SELECT IFNULL(SUM(Lucro), 0)
        FROM Apostas
        WHERE Cod_Aposta <= NEW.Cod_Aposta) + 
		(SELECT IFNULL(Valor_Inicial, 0)
        FROM Banca
        WHERE Ano = strftime('%Y', NEW.Data) 
        AND Mês = strftime('%m', NEW.Data))
    WHERE rowid = NEW.rowid;
END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (Update)";
CREATE TRIGGER "Atualiza Banca Final Apostas (Update)"
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Apostas
    SET Retorno = CASE 
        WHEN NEW.Status = 'Green' THEN IFNULL((NEW.Odd * NEW.Valor_Aposta), 0) 
        WHEN NEW.Status = 'Red' THEN 0 
        ELSE 0 
    END
    WHERE rowid = NEW.rowid;

    UPDATE Apostas
    SET Lucro = CASE 
        WHEN NEW.Status = 'Green' THEN IFNULL((NEW.Odd * NEW.Valor_Aposta - NEW.Valor_Aposta), 0)
        WHEN NEW.Status = 'Red' THEN -NEW.Valor_Aposta 
        ELSE 0 
    END
    WHERE rowid = NEW.rowid;

    UPDATE Apostas
    SET Banca_Final = (
        SELECT IFNULL(SUM(Lucro), 0)
        FROM Apostas
        WHERE Cod_Aposta <= NEW.Cod_Aposta) + 
		(SELECT IFNULL(Valor_Inicial, 0)
        FROM Banca
        WHERE Ano = strftime('%Y', NEW.Data) 
        AND Mês = strftime('%m', NEW.Data))
    WHERE rowid = NEW.rowid;
END;
