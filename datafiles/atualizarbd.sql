DROP TRIGGER IF EXISTS "Atualiza Banca Final (Delete)";
CREATE TRIGGER "Atualiza Banca Final (Delete)" AFTER DELETE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', OLD.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', OLD.Data))),0), 2) WHERE Banca.Mês = strftime('%m', OLD.Data) AND Banca.Ano = strftime('%Y', OLD.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Insert)";
CREATE TRIGGER "Atualiza Banca Final (Insert)" AFTER INSERT ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final (Update)";
CREATE TRIGGER "Atualiza Banca Final (Update)" AFTER UPDATE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET Valor_Final = ROUND(COALESCE( (SELECT Banca_Final FROM Apostas WHERE Cod_Aposta = ( SELECT MAX(Cod_Aposta) FROM Apostas WHERE strftime('%m', Apostas.Data) = strftime('%m', NEW.Data) AND strftime('%Y', Apostas.Data) = strftime('%Y', NEW.Data))),0), 2) WHERE Banca.Mês = strftime('%m', NEW.Data) AND Banca.Ano = strftime('%Y', NEW.Data); END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas";
CREATE TRIGGER "Atualiza Banca Final Apostas"
AFTER UPDATE ON Apostas
FOR EACH ROW 
BEGIN

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
DROP TRIGGER IF EXISTS "Atualiza Apostas";
CREATE TRIGGER "Atualiza Apostas" 
AFTER UPDATE ON Mercados 
FOR EACH ROW 
BEGIN 

UPDATE Apostas 
SET Status = 'Red' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 AND EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red');  

UPDATE Apostas
SET Status = 'Green'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Cashout = 0
AND NOT EXISTS
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red')
AND NOT EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live');

UPDATE Apostas
SET Status = 'Pré-live' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red')
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live'); 

/*UPDATE Apostas
SET Retorno = IFNULL((Apostas.Odd * Apostas.Valor_Aposta), 0)
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Apostas.Status <> 'Red'
AND Apostas.Status <> 'Pré-live'; */

UPDATE Apostas 
SET Retorno = 0
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live');

UPDATE Apostas 
SET Lucro = 0
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live');

/*UPDATE Apostas
SET Lucro = IFNULL(CASE 
WHEN Apostas.Status = 'Green' THEN Apostas.Retorno - Apostas.Valor_Aposta
WHEN Apostas.Status = 'Red' THEN -Apostas.Valor_Aposta
WHEN Apostas.Status = 'Anulada' THEN Apostas.Valor_Aposta
WHEN Apostas.Status = 'Cashout' THEN Apostas.Retorno - Apostas.Valor_Aposta
END, 0)
WHERE Cod_Aposta = NEW.Cod_Aposta; */

UPDATE Apostas
SET Status = 'Red'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Apostas.Lucro < 0;
--OR EXISTS (SELECT 1 FROM Mercados 
--WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red'));

UPDATE Apostas
SET Status = 'Green'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Cashout = 0
AND Apostas.Retorno > Apostas.Valor_Aposta;

UPDATE Apostas
SET Status = 'Pré-live' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Red')
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Mercados.Status = 'Pré-live'); 

END;

UPDATE ControleVersao SET Versao = 10;
UPDATE Mercados SET Status = Status;
