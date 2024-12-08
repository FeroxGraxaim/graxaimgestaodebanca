DROP TRIGGER IF EXISTS "Atualiza Apostas";

CREATE TABLE IF NOT EXISTS "ConfigPrograma" (
	"ExibirTelaBoasVindas"	BOOLEAN DEFAULT 1,
	"GestaoVariavel"	BOOLEAN DEFAULT 0,
	"PreRelease"	BOOLEAN DEFAULT 0
);

INSERT INTO ConfigPrograma ("ExibirTelaBoasVindas", "GestaoVariavel", "PreRelease") SELECT 1, 0, 0 WHERE NOT EXISTS (SELECT 1 FROM ConfigPrograma);

CREATE TABLE NovaConfig (
	"ExibirTelaBoasVindas"	BOOLEAN DEFAULT 1,
	"GestaoVariavel"	BOOLEAN DEFAULT 0,
	"PreRelease"	BOOLEAN DEFAULT 0,
	"GestaoPcent" BOOLEAN DEFAULT 0
);

INSERT INTO NovaConfig ("ExibirTelaBoasVindas", "GestaoVariavel", "PreRelease") SELECT "ExibirTelaBoasVindas", "GestaoVariavel", "PreRelease" FROM ConfigPrograma;

DROP TABLE ConfigPrograma;

ALTER TABLE NovaConfig RENAME TO ConfigPrograma;


CREATE TABLE "NovaBanca" (
	"Mês"	INTEGER,
	"Ano"	INTEGER,
	"Valor_Inicial"	NUMERIC(9, 2) DEFAULT 0,
	"Aporte"	NUMERIC(9, 2) DEFAULT 0
);
INSERT INTO NovaBanca SELECT * FROM Banca;
DROP TABLE Banca;
ALTER TABLE NovaBanca RENAME TO Banca;

CREATE TABLE "NovaApostas" (
	"Cod_Aposta"	INTEGER,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Data"	DATE,
	"Múltipla"	BOOLEAN DEFAULT 0,
	"Odd"	NUMERIC(9, 2),
	"Valor_Aposta"	NUMERIC(9, 2),
	"Status"	VARCHAR DEFAULT 'Pré-live',
	"Tipo"	BOOLEAN DEFAULT 0,
	"Cashout"	BOOLEAN DEFAULT 0,
	"Retorno"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro"	NUMERIC(9, 2) DEFAULT 0,
	"Banca_Final"	NUMERIC(9, 2) DEFAULT 0,
	"Anotacoes"	VARCHAR,
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT)
);
INSERT INTO NovaApostas SELECT * FROM Apostas;
DROP TABLE Apostas;
ALTER TABLE NovaApostas RENAME TO Apostas;

CREATE TABLE "NovaMercados" (
	"Cod_Mercado"	INTEGER,
	"Cod_Jogo"	INTEGER,
	"Cod_Metodo"	INTEGER,
	"Cod_Linha"	INTEGER,
	"Odd"	NUMERIC(9, 2),
	"Status"	VARCHAR DEFAULT 'Pré-live',
	"Cod_Aposta"	INTEGER,
	PRIMARY KEY("Cod_Mercado" AUTOINCREMENT),
	CONSTRAINT "FK_Mercados_Apostas" FOREIGN KEY("Cod_Aposta") REFERENCES "Apostas"("Cod_Aposta"),
	CONSTRAINT "FK_Mercados_Jogo_2" FOREIGN KEY("Cod_Linha") REFERENCES "Linhas"("Cod_Linha"),
	CONSTRAINT "FK_Mercados_Linhas_3" FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo")
);

CREATE TABLE IF NOT EXISTS "BancaInicial" (
	"Banca"	NUMERIC(9, 2)
);

INSERT INTO NovaMercados SELECT * FROM Mercados;
DROP TABLE Mercados;
ALTER TABLE NovaMercados RENAME TO Mercados;

CREATE TRIGGER IF NOT EXISTS "Atualiza Apostas" 
AFTER UPDATE ON Mercados 
FOR EACH ROW 
BEGIN 
  UPDATE Apostas SET Status = 'Red' 
    WHERE Cod_Aposta = NEW.Cod_Aposta 
    AND Cashout = 0 
    AND EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Red');
  UPDATE Apostas SET Status = 'Meio Red'
    WHERE Cod_Aposta = NEW.Cod_Aposta 
	AND Cashout = 0  
	AND EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Meio Red');
				
  UPDATE Apostas SET Status = 'Green' 
    WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Red') 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Meio Red') 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Pré-live'); 
					
  UPDATE Apostas SET Status = 'Meio Green'
    WHERE Cod_Aposta = NEW.Cod_Aposta 
	AND Cashout = 0  
	AND EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Meio Green') 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Meio Red')
	AND NOT EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Red')
	AND NOT EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Pré-live'); 
				
  UPDATE Apostas SET Status = 'Green' 
    WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Red') 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Meio Red') 
	AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Pré-live');
  UPDATE Apostas SET Status = 'Pré-live' 
    WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
    AND NOT EXISTS (SELECT 1 FROM Mercados 
					WHERE Cod_Aposta = NEW.Cod_Aposta 
					AND Mercados.Status = 'Red') 
	AND EXISTS (SELECT 1 FROM Mercados 
				WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Pré-live'); 
  UPDATE Apostas SET Status = 'Anulada'
    WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
	AND NOT EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Green')
	AND NOT EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Red')
	AND NOT EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Meio Green')
	AND NOT EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Meio Red')
	AND NOT EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Pré-live')
	AND EXISTS (SELECT 1 FROM Mercados
					WHERE Cod_Aposta = NEW.Cod_Aposta
					AND Mercados.Status = 'Anulada');
END;

CREATE TRIGGER IF NOT EXISTS "Cashout" 
AFTER UPDATE ON Apostas 
FOR EACH ROW 
BEGIN 
  UPDATE Apostas 
  SET Lucro = Retorno - Valor_Aposta 
  WHERE Cod_Aposta = NEW.Cod_Aposta 
  AND Cashout = 1;
END;

UPDATE ControleVersao SET Versao = 25;
