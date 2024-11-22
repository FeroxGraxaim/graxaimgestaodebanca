CREATE TABLE IF NOT EXISTS "ConfigPrograma" (
	"ExibirTelaBoasVindas"	BOOLEAN DEFAULT 1
);
CREATE TABLE "NovaMercados" (
	"Cod_Mercado"	INTEGER,
	"Cod_Jogo"	INTEGER,
	"Cod_Metodo"	INTEGER,
	"Cod_Linha"	INTEGER,
	"Odd"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Cod_Aposta"	INTEGER,
	PRIMARY KEY("Cod_Mercado" AUTOINCREMENT),
	CONSTRAINT "FK_Mercados_Apostas" FOREIGN KEY("Cod_Aposta") REFERENCES "Apostas"("Cod_Aposta"),
	CONSTRAINT "FK_Mercados_Jogo_2" FOREIGN KEY("Cod_Linha") REFERENCES "Linhas"("Cod_Linha"),
	CONSTRAINT "FK_Mercados_Linhas_3" FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo")
);
INSERT INTO NovaMercados SELECT * FROM Mercados;
DROP TABLE Mercados;
ALTER TABLE NovaMercados RENAME TO Mercados;

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

ALTER TABLE Banca ADD Aporte DEFAULT 0;

UPDATE ControleVersao SET Versao = 19;
