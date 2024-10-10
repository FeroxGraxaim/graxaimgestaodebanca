ALTER TABLE Mercados ADD Cod_Mercado INTEGER;

UPDATE Mercados
SET Cod_Mercado = (SELECT COUNT(*) FROM Mercados AS m WHERE m.ROWID <= Mercados.ROWID);

CREATE TABLE Nova_Mercados (
Cod_Mercado INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
Cod_Jogo INTEGER,
Cod_Metodo INTEGER,
Cod_Linha INTEGER,
Status VARCHAR,
Cod_Aposta INTEGER,
FOREIGN KEY (Cod_Jogo) REFERENCES Jogo(Cod_Jogo),
FOREIGN KEY (Cod_Metodo) REFERENCES Métodos(Cod_Metodo),
FOREIGN KEY (Cod_Linha) REFERENCES Linhas(Cod_Linha),
FOREIGN KEY (Cod_Aposta) REFERENCES Apostas(Cod_Aposta)
);

DELETE FROM Mercados WHERE Cod_Jogo NOT IN (SELECT Cod_Jogo FROM Jogo);
DELETE FROM Mercados WHERE Cod_Metodo NOT IN (SELECT Cod_Metodo FROM Métodos);
DELETE FROM Mercados WHERE Cod_Linha NOT IN (SELECT Cod_Linha FROM Linhas);
DELETE FROM Mercados WHERE Cod_Aposta NOT IN (SELECT Cod_Aposta FROM Apostas);

INSERT INTO Nova_Mercados (Cod_Jogo, Cod_Metodo, Cod_Linha, Status, Cod_Aposta)
SELECT Cod_Jogo, Cod_Metodo, Cod_Linha, Status, Cod_Aposta
FROM Mercados;

DROP TABLE Mercados;

ALTER TABLE Nova_Mercados RENAME TO Mercados;

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

UPDATE ControleVersao SET Versao = 14;
