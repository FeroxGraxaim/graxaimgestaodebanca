DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (Insert)";
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (Update)";
DROP TRIGGER IF EXISTS "Atualiza Status Aposta (Delete)";
DROP TRIGGER IF EXISTS "Atualiza Status Aposta (Update)";

CREATE TRIGGER IF NOT EXISTS "Atualiza Apostas" 
AFTER UPDATE ON Mercados 
FOR EACH ROW 
BEGIN 

UPDATE Apostas 
SET Status = 'Red' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 AND EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red');  

UPDATE Apostas
SET Status = 'Green'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Cashout = 0
AND NOT EXISTS
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red')
AND NOT EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Pré-live')
AND Apostas.Retorno > Apostas.Valor_Aposta;

UPDATE Apostas
SET Status = 'Pré-live' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red')
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Pré-live'); 

UPDATE Apostas
SET Retorno = Apostas.Odd * Apostas.Valor_Aposta
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Apostas.Status <> 'Red'
AND Apostas.Status <> 'Pré-live';

UPDATE Apostas
SET Lucro = IFNULL(CASE 
WHEN Apostas.Status = 'Green' THEN Apostas.Retorno - Apostas.Valor_Aposta
WHEN Apostas.Status = 'Red' THEN -Apostas.Valor_Aposta
WHEN Apostas.Status = 'Anulada' THEN Apostas.Valor_Aposta
WHEN Apostas.Status = 'Cashout' THEN Apostas.Retorno - Apostas.Valor_Aposta
END, 0)
WHERE Cod_Aposta = NEW.Cod_Aposta;

UPDATE Apostas
SET Status = 'Red'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND (Apostas.Lucro < 0
OR EXISTS (SELECT 1 FROM Mercados 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red'));
END;

CREATE TRIGGER IF NOT EXISTS "Atualiza Apostas" 
AFTER UPDATE ON Mercados 
FOR EACH ROW 
BEGIN 

UPDATE Apostas 
SET Status = 'Red' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0 AND EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red');  

UPDATE Apostas
SET Status = 'Green'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Cashout = 0
AND NOT EXISTS
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red')
AND NOT EXISTS 
(SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Pré-live')
AND Apostas.Retorno > Apostas.Valor_Aposta;

UPDATE Apostas
SET Status = 'Pré-live' 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Cashout = 0
AND NOT EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red')
AND EXISTS (SELECT 1 FROM Mercados WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Pré-live'); 

UPDATE Apostas
SET Retorno = Apostas.Odd * Apostas.Valor_Aposta
WHERE Cod_Aposta = NEW.Cod_Aposta
AND Apostas.Status <> 'Red'
AND Apostas.Status <> 'Pré-live';

UPDATE Apostas
SET Lucro = IFNULL(CASE 
WHEN Apostas.Status = 'Green' THEN Apostas.Retorno - Apostas.Valor_Aposta
WHEN Apostas.Status = 'Red' THEN -Apostas.Valor_Aposta
WHEN Apostas.Status = 'Anulada' THEN Apostas.Valor_Aposta
WHEN Apostas.Status = 'Cashout' THEN Apostas.Retorno - Apostas.Valor_Aposta
END, 0)
WHERE Cod_Aposta = NEW.Cod_Aposta;

UPDATE Apostas
SET Status = 'Red'
WHERE Cod_Aposta = NEW.Cod_Aposta
AND (Apostas.Lucro < 0
OR EXISTS (SELECT 1 FROM Mercados 
WHERE Cod_Aposta = NEW.Cod_Aposta AND Status = 'Red'));

END;

UPDATE ControleVersao SET Versao = 9;
