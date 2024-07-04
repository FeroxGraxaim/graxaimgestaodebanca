CREATE TABLE IF NOT EXISTS "ControleVersao" (
    "Versao"    INTEGER NOT NULL
);
INSERT INTO ControleVersao (rowid, Versao) VALUES (1, 2)
ON CONFLICT (rowid) DO UPDATE SET Versao = excluded.Versao;
DROP TRIGGER IF EXISTS "Calcula Banca Final Apostas (Insert)";
DROP TRIGGER IF EXISTS "Calcula Banca Final Apostas (Update)";
DROP TRIGGER IF EXISTS "Calcula Porcentagem Lucro";
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Update)"
AFTER UPDATE ON Times
BEGIN
    -- Atualiza o campo Mercados na tabela Países
    UPDATE Países
    SET Mercados = (Mercados - OLD.Mandante - OLD.Visitante) + NEW.Mandante + NEW.Visitante
    WHERE País = NEW.País;
END;
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Insert)"
AFTER INSERT ON Times
BEGIN
    -- Atualiza o campo Mercados na tabela Países
    UPDATE Países
    SET Mercados = Mercados + NEW.Mandante + NEW.Visitante
    WHERE País = NEW.País;
END;
CREATE TRIGGER IF NOT EXISTS after_insert_times
AFTER INSERT ON Times
FOR EACH ROW
BEGIN
    UPDATE Times
    SET Mandante = 0,
        Visitante = 0,
        Greens = 0,
        Reds = 0,
        "P/L" = 0
    WHERE "Time" = NEW."Time";
END;
CREATE TRIGGER IF NOT EXISTS "Corrige Valores"
AFTER UPDATE ON Banca
FOR EACH ROW
BEGIN
    UPDATE Banca
    SET Stake = ROUND(NEW.Stake, 2),
        Valor_Final = ROUND(NEW.Valor_Final, 2),
        "Lucro_R$" = ROUND(NEW."Lucro_R$", 2),
        "Lucro_%" = ROUND(NEW."Lucro_%", 2)
    WHERE "Mês" = NEW."Mês" AND "Ano" = NEW."Ano";
END;
CREATE TRIGGER IF NOT EXISTS "Recálculo Países (Delete)"
AFTER DELETE ON Times
BEGIN
    -- Atualiza o campo Mercados na tabela Países
    UPDATE Países
    SET Mercados = Mercados - OLD.Mandante - OLD.Visitante
    WHERE País = OLD.País;
END;
CREATE TRIGGER IF NOT EXISTS after_insert_apostas
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Times
    SET Mandante = Mandante + 1
    WHERE Time = NEW.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante + 1
    WHERE Time = NEW.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS after_delete_apostas
AFTER DELETE ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Times
    SET Mandante = Mandante - 1
    WHERE "Time" = OLD.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante - 1
    WHERE "Time" = OLD.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Update)"
AFTER UPDATE ON Apostas
BEGIN
    UPDATE Times
    SET Mandante = Mandante - 1
    WHERE "Time" = OLD.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante - 1
    WHERE "Time" = OLD.Visitante;
    
    UPDATE Times
    SET Mandante = Mandante + 1
    WHERE "Time" = NEW.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante + 1
    WHERE "Time" = NEW.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Delete)"
AFTER DELETE ON Apostas
BEGIN
    UPDATE Times
    SET Mandante = Mandante - 1
    WHERE "Time" = OLD.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante - 1
    WHERE "Time" = OLD.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Times (Insert)"
AFTER INSERT ON Apostas
BEGIN
    UPDATE Times
    SET Mandante = Mandante + 1
    WHERE "Time" = NEW.Mandante;
    
    UPDATE Times
    SET Visitante = Visitante + 1
    WHERE "Time" = NEW.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS after_update_apostas
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
    -- Se Mandante mudou
    UPDATE Times
    SET Mandante = Mandante - 1
    WHERE "Time" = OLD.Mandante;
    
    UPDATE Times
    SET Mandante = Mandante + 1
    WHERE "Time" = NEW.Mandante;

    -- Se Visitante mudou
    UPDATE Times
    SET Visitante = Visitante - 1
    WHERE "Time" = OLD.Visitante;
    
    UPDATE Times
    SET Visitante = Visitante + 1
    WHERE "Time" = NEW.Visitante;
END;
CREATE TRIGGER "Calcular Retorno e P/L Aposta (Insert)"
AFTER INSERT ON Apostas
BEGIN
  UPDATE Apostas
  SET Retorno = CASE
      WHEN NEW.Status = 'Green' THEN Valor_Aposta * Odd
      WHEN NEW.Status = 'Red' THEN 0
      WHEN NEW.Status = 'Meio Green' THEN (Valor_Aposta * Odd) / 2
      WHEN NEW.Status = 'Meio Red' THEN 0
      WHEN NEW.Status = 'Anulada' THEN 0
      WHEN NEW.Status = 'Cashout' THEN Retorno
    END,
    Profit_L = CASE
      WHEN NEW.Status = 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta
      WHEN NEW.Status = 'Red' THEN -Valor_Aposta
      WHEN NEW.Status = 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2
      WHEN NEW.Status = 'Meio Red' THEN -Valor_Aposta / 2
      WHEN NEW.Status = 'Anulada' THEN 0
      WHEN NEW.Status = 'Cashout' THEN Profit_L 
    END
  WHERE Cod_Aposta = NEW.Cod_Aposta;
END;
CREATE TRIGGER "Calcular Retorno e P/L Aposta (Update)"
AFTER UPDATE ON Apostas
BEGIN
  UPDATE Apostas
  SET Retorno = CASE
      WHEN NEW.Status = 'Green' THEN Valor_Aposta * Odd
      WHEN NEW.Status = 'Red' THEN 0
      WHEN NEW.Status = 'Meio Green' THEN (Valor_Aposta * Odd) / 2
      WHEN NEW.Status = 'Meio Red' THEN 0
      WHEN NEW.Status = 'Anulada' THEN 0
      WHEN NEW.Status = 'Cashout' THEN Retorno
    END,
    Profit_L = CASE
      WHEN NEW.Status = 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta
      WHEN NEW.Status = 'Red' THEN -Valor_Aposta
      WHEN NEW.Status = 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2
      WHEN NEW.Status = 'Meio Red' THEN -Valor_Aposta / 2
      WHEN NEW.Status = 'Anulada' THEN 0
      WHEN NEW.Status = 'Cashout' THEN Profit_L 
    END
  WHERE Cod_Aposta = NEW.Cod_Aposta;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
    -- Atualiza Banca_Final na tabela Apostas com base nos dados da tabela Banca
    UPDATE Apostas
    SET Banca_Final = (
        SELECT Valor_Inicial + NEW.Profit_L
        FROM Banca
        WHERE Ano = strftime('%Y', NEW.Data)
          AND Mês = strftime('%m', NEW.Data)
    )
    WHERE rowid = NEW.rowid;

    -- Atualizações subsequentes: soma Profit_L ao valor atual de Banca_Final
    UPDATE Apostas
    SET Banca_Final = (
        SELECT Banca_Final + NEW.Profit_L
        FROM Apostas
        WHERE rowid = NEW.rowid - 1
    )
    WHERE rowid > NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Atualiza Banca Final Apostas (Update)"
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
    -- Atualiza Banca_Final na tabela Apostas com base nos dados da tabela Banca
    UPDATE Apostas
    SET Banca_Final = (
        SELECT Valor_Inicial + NEW.Profit_L
        FROM Banca
        WHERE Ano = strftime('%Y', NEW.Data)
          AND Mês = strftime('%m', NEW.Data)
    )
    WHERE rowid = NEW.rowid;

    -- Atualizações subsequentes: soma Profit_L ao valor atual de Banca_Final
    UPDATE Apostas
    SET Banca_Final = (
        SELECT Banca_Final + NEW.Profit_L
        FROM Apostas
        WHERE rowid = NEW.rowid - 1
    )
    WHERE rowid > NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Delete)"
AFTER DELETE ON Apostas
BEGIN
    UPDATE Competições
    SET Mercados = Mercados - 1
    WHERE "Competição" = OLD.Competição_AP;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Update)"
AFTER UPDATE ON Apostas
BEGIN
    UPDATE Competições
    SET Mercados = Mercados + 1
    WHERE "Competição" = NEW.Competição_AP;
	UPDATE Competições
    SET Mercados = Mercados - 1
    WHERE "Competição" = OLD.Competição_AP;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Contadores Mercados Competição (Insert)"
AFTER INSERT ON Apostas
BEGIN
    UPDATE Competições
    SET Mercados = Mercados + 1
    WHERE "Competição" = NEW.Competição_AP;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Insert)"
AFTER INSERT ON Apostas
BEGIN
    UPDATE Estratégias
    SET Mercados_Estr = Mercados_Estr + 1
    WHERE "Estratégia" = NEW.Estratégia_Escolhida;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Update)"
AFTER UPDATE ON Apostas
BEGIN
    UPDATE Estratégias
    SET Mercados_Estr = Mercados_Estr + 1
    WHERE "Estratégia" = NEW.Estratégia_Escolhida;
    UPDATE Estratégias
    SET Mercados_Estr = Mercados_Estr - 1
    WHERE "Estratégia" = OLD.Estratégia_Escolhida;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Estratégias Times (Delete)"
AFTER DELETE ON Apostas
BEGIN
    UPDATE Estratégias
    SET Mercados_Estr = Mercados_Estr - 1
    WHERE "Estratégia" = OLD.Estratégia_Escolhida;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens e Reds P/L Times (Insert)"
AFTER INSERT ON Apostas
BEGIN
    UPDATE Times
    SET Greens = Greens + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END,
        Reds = Reds + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END,
        "P/L" = "P/L" + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END 
    WHERE "Time" = NEW.Mandante OR "Time" = NEW.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens Reds P/L Time (Update)"
AFTER UPDATE ON Apostas
BEGIN
    UPDATE Times
    SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END,
        Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END,
		"P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END
    WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Atualizar Greens Reds P/L Time (Delete)"
AFTER DELETE ON Apostas
BEGIN
    UPDATE Times
    SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END,
        Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END,
		"P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END
    WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante;
END;
CREATE TRIGGER IF NOT EXISTS "Calcular Porcentagem Lucro"
after update on Banca 
for each row 
begin 
UPDATE Banca
    SET "Lucro_%" = CASE
						WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE CASE
                        WHEN NEW."Valor_Inicial" != 0 THEN
                            (NEW."Valor_Final" - NEW."Valor_Inicial") / NEW."Valor_Inicial" * 100
                            
                    END END
    WHERE rowid = NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Calcular Porcentagem Lucro (Insert)"
after insert on Banca 
for each row 
begin 
UPDATE Banca
    SET "Lucro_%" = CASE
						WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE CASE
                        WHEN NEW."Valor_Inicial" != 0 THEN
                            (NEW."Valor_Final" - NEW."Valor_Inicial") / NEW."Valor_Inicial" * 100
                            
                    END END
    WHERE rowid = NEW.rowid;
END;
CREATE TRIGGER IF NOT EXISTS "Calcula Banca Final (Insert)"
after insert on Banca 
begin
update Banca
set Valor_Final = Valor_Inicial + Lucro_R$
where rowid = NEW.ROWID;
end;
CREATE TRIGGER IF NOT EXISTS "Calcula Banca Final (Update)"
after update on Banca 
begin
update Banca
set Valor_Final = Valor_Inicial + Lucro_R$
where rowid = NEW.ROWID;
end;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro (Delete)"
AFTER DELETE ON Banca
FOR EACH ROW
BEGIN
    UPDATE Banca
    SET "Lucro_R$" = (
        SELECT IFNULL(SUM(Profit_L), 0)
        FROM Apostas
        WHERE strftime('%Y', Apostas.Data) = Ano
          AND strftime('%m', Apostas.Data) = Mês
    )
    WHERE Ano = strftime('%Y', NEW.Data) 
      AND Mês = strftime('%m', NEW.Data);
END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro (Update)"
AFTER Update ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Banca
    SET "Lucro_R$" = (
        SELECT IFNULL(SUM(Profit_L), 0)
        FROM Apostas
        WHERE strftime('%Y', NEW.Data) = Ano
          AND strftime('%m', NEW.Data) = Mês
    )
    WHERE Ano = strftime('%Y', NEW.Data) 
      AND Mês = strftime('%m', NEW.Data);
END;
CREATE TRIGGER IF NOT EXISTS "Calcular Lucro (Insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
    UPDATE Banca
    SET "Lucro_R$" = (
        SELECT IFNULL(SUM(Profit_L), 0)
        FROM Apostas
        WHERE strftime('%Y', NEW.Data) = Ano
          AND strftime('%m', NEW.Data) = Mês
    )
    WHERE Ano = strftime('%Y', NEW.Data) 
      AND Mês = strftime('%m', NEW.Data);
END;
alter table Apostas add "Selec." boolean default 0;
alter table competições add "Selec." boolean default 0;
alter table Estratégias add "Selec." boolean default 0;
alter table Países add "Selec." boolean default 0;
alter table Times add "Selec." boolean default 0;
