BEGIN TRANSACTION;
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
DROP TABLE IF EXISTS "Apostas";
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
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT),
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time")
);
DROP TABLE IF EXISTS "Unidades";
CREATE TABLE IF NOT EXISTS "Unidades" (
	"Unidade"	VARCHAR
);
DROP TABLE IF EXISTS "Perfis";
CREATE TABLE IF NOT EXISTS "Perfis" (
	"Perfil"	VARCHAR,
	PRIMARY KEY("Perfil")
);
DROP TABLE IF EXISTS "Selecionar Perfil";
CREATE TABLE IF NOT EXISTS "Selecionar Perfil" (
	"Perfil Selecionado"	VARCHAR NOT NULL DEFAULT 'Conservador'
);
DROP TABLE IF EXISTS "Selecionar Mês e Ano";
CREATE TABLE IF NOT EXISTS "Selecionar Mês e Ano" (
	"Mês"	INTEGER,
	"Ano"	INTEGER
);
DROP TABLE IF EXISTS "Status_Aposta";
CREATE TABLE IF NOT EXISTS "Status_Aposta" (
	"Cod_Status"	INTEGER,
	"Status"	VARCHAR,
	PRIMARY KEY("Cod_Status" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Estratégias";
CREATE TABLE IF NOT EXISTS "Estratégias" (
	"Cod_Estratégia"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Estratégia"	VARCHAR,
	"Mercados_Estr"	INTEGER DEFAULT 0,
	"Profit_Estr"	REAL DEFAULT 0.00,
	PRIMARY KEY("Cod_Estratégia" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Países";
CREATE TABLE IF NOT EXISTS "Países" (
	"Selec."	BOOLEAN DEFAULT 0,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	"P/L"	INTEGER DEFAULT 0,
	PRIMARY KEY("País")
);
DROP TABLE IF EXISTS "Times";
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
DROP TABLE IF EXISTS "ControleVersao";
CREATE TABLE IF NOT EXISTS "ControleVersao" (
	"Versao"	INTEGER NOT NULL
);
DROP TABLE IF EXISTS "Jogo";
CREATE TABLE IF NOT EXISTS "Jogo" (
	"Cod_Jogo"	INTEGER NOT NULL,
	"Competição"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	"Estratégia"	VARCHAR,
	"Odd"	NUMERIC(9, 2),
	"Situação"	INTEGER,
	PRIMARY KEY("Cod_Jogo" AUTOINCREMENT),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time"),
	FOREIGN KEY("Competição") REFERENCES "Competições"("Competição"),
	FOREIGN KEY("Estratégia") REFERENCES "Estratégias"("Estratégia")
);
DROP TABLE IF EXISTS "Aposta Múltipla";
CREATE TABLE IF NOT EXISTS "Aposta Múltipla" (
	"Cod_Aposta"	INTEGER NOT NULL,
	"Cod_Jogo"	INTEGER,
	"Status"	INTEGER,
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT),
	FOREIGN KEY("Cod_Jogo") REFERENCES "Jogo"("Cod_Jogo")
);
DROP TABLE IF EXISTS "Competições";
CREATE TABLE IF NOT EXISTS "Competições" (
	"Selec."	BOOLEAN DEFAULT 0,
	"Competição"	VARCHAR NOT NULL,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Green"	INTEGER DEFAULT 0,
	"Red"	INTEGER DEFAULT 0,
	"P/L"	NUMERIC DEFAULT 0,
	"Total"	NUMERIC DEFAULT 0,
	PRIMARY KEY("Competição")
);
INSERT INTO "Banca" ("Mês","Ano","Valor_Inicial","Lucro_R$","Lucro_%","Valor_Final","Stake") VALUES (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2),
 (7,2024,200,0,0,200,2);
INSERT INTO "Unidades" ("Unidade") VALUES ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor');
INSERT INTO "Perfis" ("Perfil") VALUES ('Conservador'),
 ('Moderado'),
 ('Agressivo');
INSERT INTO "Selecionar Perfil" ("Perfil Selecionado") VALUES ('Moderado');
INSERT INTO "Selecionar Mês e Ano" ("Mês","Ano") VALUES (7,2024);
INSERT INTO "Status_Aposta" ("Cod_Status","Status") VALUES (1,'Green'),
 (2,'Red'),
 (3,'Anulada'),
 (4,'Cashout'),
 (5,'Pré-live'),
 (6,'Meio Green'),
 (7,'Meio Red');
INSERT INTO "Estratégias" ("Cod_Estratégia","Selec.","Estratégia","Mercados_Estr","Profit_Estr") VALUES (4,0,'Back Favorito',1,0.0),
 (5,0,'Zebra Favorito',0,0.0),
 (6,0,'Cantos',0,0.0),
 (7,0,'Handicap Asiático',0,0.0),
 (8,0,'Handicap Europeu',0,0.0),
 (9,0,'Cartões',0,0.0),
 (10,0,'Under Gols',0,0.0),
 (11,0,'Over Gols',0,0.0),
 (12,0,'Over Gols Equipe',0,0.0),
 (14,0,'Empate Anula',0,0.0),
 (15,0,'Chance Dupla',0,0.0),
 (16,0,'Aposta Múltipla',8,0.0),
 (17,0,'Outros',6,0.0);
INSERT INTO "Países" ("Selec.","País","Mercados","Greens","Reds","P/L") VALUES (0,'Brasil',9,0,0,0),
 (0,'Eslováquia',0,0,0,0),
 (0,'Ucrânia',0,0,0,0),
 (0,'Holanda',1,0,0,0),
 (0,'França',1,0,0,0),
 (0,'Polônia',0,0,0,0),
 (0,'Áustria',0,0,0,0),
 (0,'Turquia',0,0,0,0),
 (0,'Alemanha',0,0,0,0),
 (0,'Argentina',0,0,0,0),
 (0,'Espanha',0,0,0,0),
 (0,'EUA',0,0,0,0),
 (0,'Inglaterra',0,0,0,0),
 (0,'Itália',1,0,0,0),
 (0,'Portugal',1,0,0,0),
 (0,'Noruega',0,0,0,0),
 (0,'Suécia',0,0,0,0),
 (0,'Sudamérica',0,0,0,0),
 (0,'Europa',0,0,0,0),
 (0,'Mundo',0,0,0,0),
 (0,'Médio Oriente',0,0,0,0),
 (0,'Extremo Oriente',0,0,0,0),
 (0,'Sudeste Asiático',0,0,0,0),
 (0,'Oceania',0,0,0,0),
 (0,'Bielorussia',0,0,0,0),
 (0,'Austria',0,0,0,0),
 (0,'Suíça',0,0,0,0),
 (0,'Dinamarca',0,0,0,0),
 (0,'Islândia',0,0,0,0),
 (0,'1',0,0,0,0),
 (0,'Hungria',0,0,0,0),
 (0,'Malta',0,0,0,0),
 (0,'Luxemburgo',0,0,0,0),
 (0,'Ilhas Faroe',0,0,0,0),
 (0,'Monaco',0,0,0,0),
 (0,'Montenegro',0,0,0,0),
 (0,'Chipre',0,0,0,0),
 (0,'Letônia',0,0,0,0),
 (0,'Bósnia e Herzegovina',0,0,0,0),
 (0,'Estônia',0,0,0,0),
 (0,'Sérvia',1,0,0,0),
 (0,'Eslovênia',0,0,0,0),
 (0,'Geórgia',0,0,0,0),
 (0,'Moldávia',0,0,0,0),
 (0,'Armênia',0,0,0,0),
 (0,'Azerbaijão',0,0,0,0),
 (0,'Kosovo',0,0,0,0),
 (0,'Andorra',0,0,0,0),
 (0,'San Marino',0,0,0,0),
 (0,'Gibraltar',0,0,0,0),
 (0,'Liechtenstein',0,0,0,0),
 (0,'Mônaco',0,0,0,0),
 (0,'Vaticano',0,0,0,0),
 (0,'Bielorrússia',0,0,0,0),
 (0,'Cazaquistão',0,0,0,0),
 (0,'Macedônia do Norte',0,0,0,0),
 (0,'São Marino',0,0,0,0),
 (0,'Curaçao',0,0,0,0),
 (0,'Paraguai',0,0,0,0),
 (0,'Irlanda',0,0,0,0),
 (0,'Bolívia',0,0,0,0),
 (0,'Chile',0,0,0,0),
 (0,'Escócia',0,0,0,0),
 (0,'República Tcheca',0,0,0,0),
 (0,'Bélgica',1,0,0,0),
 (0,'Rússia',0,0,0,0),
 (0,'Romênia',0,0,0,0),
 (0,'Japão',0,0,0,0),
 (0,'Israel',0,0,0,0),
 (0,'Finlândia',0,0,0,0),
 (0,'Croácia',0,0,0,0),
 (0,'Bulgária',0,0,0,0),
 (0,'Equador',0,0,0,0);
INSERT INTO "Times" ("Selec.","Time","País","Mandante","Visitante","Greens","P/L","Reds") VALUES (0,'Criciúma','Brasil',1,0,1,1.996,0),
 (0,'Próspera','Brasil',0,0,0,0,0),
 (0,'Palmeiras','Brasil',1,0,1,0.64,0),
 (0,'Cruzeiro','Brasil',0,1,1,2.54,0),
 (0,'Atlético GO','Brasil',0,0,0,0,0),
 (0,'São Paulo','Brasil',0,0,0,0,0),
 (0,'Fortaleza','Brasil',0,0,0,0,0),
 (0,'Grêmio','Brasil',0,0,0,0,0),
 (0,'Juventude','Brasil',0,0,0,0,0),
 (0,'Vasco da Gama','Brasil',0,0,0,0,0),
 (0,'Internacional','Brasil',0,0,0,0,0),
 (0,'Corinthians','Brasil',0,1,1,0.64,0),
 (0,'Fluminense','Brasil',0,0,0,0,0),
 (0,'Botafogo','Brasil',0,1,1,2.07,0),
 (0,'Athletico PR','Brasil',0,0,0,0,0),
 (0,'Cuiabá','Brasil',1,0,1,2.07,0),
 (0,'Coritiba','Brasil',0,0,0,0,0),
 (0,'América MG','Brasil',0,0,0,0,0),
 (0,'Eslováquia','Eslováquia',0,0,0,0,0),
 (0,'Ucrânia','Ucrânia',0,0,0,0,0),
 (0,'Holanda','Holanda',0,0,0,0,0),
 (0,'França','França',1,0,1,2.7,0),
 (0,'Polônia','Polônia',0,0,0,0,0),
 (0,'Áustria','Áustria',0,0,0,0,0),
 (0,'Turquia','Turquia',0,0,0,0,0),
 (0,'AC Milan','Itália',0,1,0,0,0),
 (0,'Tondela','Portugal',0,0,0,0,0),
 (0,'Ajax','Holanda',1,0,0,0,0),
 (0,'Alavés','Espanha',0,0,0,0,0),
 (0,'Portland Timbers','EUA',0,0,0,0,0),
 (0,'Crystal Palace','Inglaterra',0,0,0,0,0),
 (0,'Goiás','Brasil',0,0,0,0,0),
 (0,'Chapecoense','Brasil',0,1,0,-3.18,1),
 (0,'Fulham','Inglaterra',0,0,0,0,0),
 (0,'Portugal','Portugal',1,0,0,-3.18,1),
 (0,'Lille','França',0,0,0,0,0),
 (0,'Ceará','Brasil',0,0,0,0,0),
 (0,'Fortuna','Alemanha',0,0,0,0,0),
 (0,'Frankfurt','Alemanha',0,0,0,0,0),
 (0,'Náutico','Brasil',0,0,0,0,0),
 (0,'Operário','Brasil',0,0,0,0,0),
 (0,'Qarabağ','Azerbaijão',0,0,0,0,0),
 (0,'Genoa','Itália',0,0,0,0,0),
 (0,'Boca Juniors','Argentina',0,0,0,0,0),
 (0,'Libertad','Paraguai',0,0,0,0,0),
 (0,'Getafe','Espanha',0,0,0,0,0),
 (0,'Granada','Espanha',0,0,0,0,0),
 (0,'Espanha','Espanha',0,0,0,0,0),
 (0,'Alemanha','Alemanha',0,0,0,0,0),
 (0,'Hamburger SV','Alemanha',0,0,0,0,0),
 (0,'Hoffenheim','Alemanha',0,0,0,0,0),
 (0,'Inter Milan','Itália',0,0,0,0,0),
 (0,'København','Dinamarca',0,0,0,0,0),
 (0,'Shamrock Rovers','Irlanda',0,0,0,0,0),
 (0,'Itália','Itália',0,0,0,0,0),
 (0,'Juventus','Itália',0,0,0,0,0),
 (0,'Rayo Vallecano','Espanha',0,0,0,0,0),
 (0,'Always Ready','Bolívia',0,0,0,0,0),
 (0,'Lazio','Itália',0,0,0,0,0),
 (0,'Leicester City','Inglaterra',0,0,0,0,0),
 (0,'Minnesota United','EUA',0,0,0,0,0),
 (0,'Athletico Paranaense','Brasil',0,0,0,0,0),
 (0,'Levante','Espanha',0,0,0,0,0),
 (0,'Bayer Leverkusen','Alemanha',0,0,0,0,0),
 (0,'Universidad Católica','Chile',0,0,0,0,0),
 (0,'Liverpool','Inglaterra',0,0,0,0,0),
 (0,'Salernitana','Itália',0,0,0,0,0),
 (0,'Hungria','Hungria',0,0,0,0,0),
 (0,'Middlesbrough','Inglaterra',0,0,0,0,0),
 (0,'Lyon','França',0,0,0,0,0),
 (0,'Atlético Goianiense','Brasil',0,0,0,0,0),
 (0,'Escócia','Escócia',0,0,0,0,0),
 (0,'Mainz','Alemanha',0,0,0,0,0),
 (0,'Malmö FF','Suécia',0,0,0,0,0),
 (0,'Manchester City','Inglaterra',0,0,0,0,0),
 (0,'Manchester United','Inglaterra',0,0,0,0,0),
 (0,'Strasbourg','França',0,0,0,0,0),
 (0,'República Tcheca','República Tcheca',0,0,0,0,0),
 (0,'Napoli','Itália',0,0,0,0,0),
 (0,'Newcastle United','Inglaterra',0,0,0,0,0),
 (0,'Nice','França',0,0,0,0,0),
 (0,'Norwich City','Inglaterra',0,0,0,0,0),
 (0,'Nürnberg','Alemanha',0,0,0,0,0),
 (0,'Ingolstadt','Alemanha',0,0,0,0,0),
 (0,'Paderborn','Alemanha',0,0,0,0,0),
 (0,'Bélgica','Bélgica',0,1,1,2.7,0),
 (0,'Austria Wien','Áustria',0,0,0,0,0),
 (0,'Paris Saint-Germain','França',0,0,0,0,0),
 (0,'Sérvia','Sérvia',0,0,0,0,0),
 (0,'Rússia','Rússia',0,0,0,0,0),
 (0,'Ponte Preta','Brasil',0,0,0,0,0),
 (0,'Porto','Portugal',0,0,0,0,0),
 (0,'Portimonense','Portugal',0,0,0,0,0),
 (0,'PSV Eindhoven','Holanda',0,0,0,0,0),
 (0,'Rangers','Escócia',0,0,0,0,0),
 (0,'Bordeaux','França',0,0,0,0,0),
 (0,'RB Leipzig','Alemanha',0,0,0,0,0),
 (0,'Real Madrid','Espanha',0,0,0,0,0),
 (0,'Real Sociedad','Espanha',0,0,0,0,0),
 (0,'Romênia','Romênia',0,0,0,0,0),
 (0,'Roma','Itália',0,0,0,0,0),
 (0,'Eintracht Braunschweig','Alemanha',0,0,0,0,0),
 (0,'Hatayspor','Turquia',0,0,0,0,0),
 (0,'Kawasaki Frontale','Japão',0,0,0,0,0),
 (0,'RB Salzburg','Áustria',0,0,0,0,0),
 (0,'Sampdoria','Itália',0,0,0,0,0),
 (0,'San Marino','San Marino',0,0,0,0,0),
 (0,'Santos','Brasil',1,0,0,-3.18,1),
 (0,'Sassuolo','Itália',0,0,0,0,0),
 (0,'Schalke 04','Alemanha',0,0,0,0,0),
 (0,'Sevilla','Espanha',0,0,0,0,0),
 (0,'Shakhtar Donetsk','Ucrânia',0,0,0,0,0),
 (0,'St Gilloise','Bélgica',0,0,0,0,0),
 (0,'Yokohama Marinos','Japão',0,0,0,0,0),
 (0,'Arsenal','Inglaterra',0,0,0,0,0),
 (0,'Aston Villa','Inglaterra',0,0,0,0,0),
 (0,'Atalanta','Itália',0,0,0,0,0),
 (0,'Athletic Bilbao','Espanha',0,0,0,0,0),
 (0,'Atlético Madrid','Espanha',0,0,0,0,0),
 (0,'Los Angeles FC','EUA',0,0,0,0,0),
 (0,'Atlético Mineiro','Brasil',0,0,0,0,0),
 (0,'Los Angeles Galaxy','EUA',0,0,0,0,0),
 (0,'Watford','Inglaterra',0,0,0,0,0),
 (0,'Augsburg','Alemanha',0,0,0,0,0),
 (0,'Lillestrøm','Noruega',0,0,0,0,0),
 (0,'Fenerbahçe','Turquia',0,0,0,0,0),
 (0,'Bodø/Glimt','Noruega',0,0,0,0,0),
 (0,'Brøndby','Dinamarca',0,0,0,0,0),
 (0,'Bahia','Brasil',0,0,0,0,0),
 (0,'Barcelona','Espanha',0,0,0,0,0),
 (0,'FC Zürich','Suíça',0,0,0,0,0),
 (0,'Başakşehir','Turquia',0,0,0,0,0),
 (0,'Basel','Suíça',0,0,0,0,0),
 (0,'BATE Borisov','Bielorrússia',0,0,0,0,0),
 (0,'Bayern Munich','Alemanha',0,0,0,0,0),
 (0,'América Mineiro','Brasil',0,0,0,0,0),
 (0,'Benfica','Portugal',0,0,0,0,0),
 (0,'Beşiktaş','Turquia',0,0,0,0,0),
 (0,'Real Betis','Espanha',0,0,0,0,0),
 (0,'Maccabi Haifa','Israel',0,0,0,0,0),
 (0,'Bologna','Itália',0,0,0,0,0),
 (0,'Bournemouth','Inglaterra',0,0,0,0,0),
 (0,'Braga','Portugal',0,0,0,0,0),
 (0,'Bragantino','Brasil',0,0,0,0,0),
 (0,'Slavia Praga','República Tcheca',0,0,0,0,0),
 (0,'Brescia','Itália',0,0,0,0,0),
 (0,'Brighton','Inglaterra',0,0,0,0,0),
 (0,'Trabzonspor','Turquia',0,0,0,0,0),
 (0,'Cagliari','Itália',0,0,0,0,0),
 (0,'Konyaspor','Turquia',0,0,0,0,0),
 (0,'Celta Vigo','Espanha',0,0,0,0,0),
 (0,'West Ham','Inglaterra',0,0,0,0,0),
 (0,'Chelsea','Inglaterra',0,0,0,0,0),
 (0,'Partizan','Sérvia',0,0,0,0,0),
 (0,'Crvena Zvezda','Sérvia',0,0,0,0,0),
 (0,'Molde','Noruega',0,0,0,0,0),
 (0,'St. Gallen','Suíça',0,0,0,0,0),
 (0,'Osasuna','Espanha',0,0,0,0,0),
 (0,'Metz','França',0,0,0,0,0),
 (0,'Figueirense','Brasil',0,0,0,0,0),
 (0,'HJK','Finlândia',0,0,0,0,0),
 (0,'Vålerenga','Noruega',0,0,0,0,0),
 (0,'Real Salt Lake','EUA',0,0,0,0,0),
 (0,'Borussia Dortmund','Alemanha',0,0,0,0,0),
 (0,'Croácia','Croácia',0,0,0,0,0),
 (0,'Ludogorets','Bulgária',0,0,0,0,0),
 (0,'Dynamo Dresden','Alemanha',0,0,0,0,0),
 (0,'Cluj','Romênia',0,0,0,0,0),
 (0,'FC Sion','Suíça',0,0,0,0,0),
 (0,'St. Pauli','Alemanha',0,0,0,0,0),
 (0,'Espanyol','Espanha',0,0,0,0,0),
 (0,'Everton','Inglaterra',0,0,0,0,0),
 (0,'Liechtenstein','Liechtenstein',0,0,0,0,0),
 (0,'FC Heidenheim','Alemanha',0,0,0,0,0),
 (0,'FC Köln','Alemanha',0,0,0,0,0),
 (0,'Lokomotiv Plovdiv','Bulgária',0,0,0,0,0),
 (0,'Saint-Étienne','França',0,0,0,0,0),
 (0,'Ind. del Valle','Equador',0,0,0,0,0),
 (0,'Flamengo','Brasil',0,0,0,0,0);
INSERT INTO "ControleVersao" ("Versao") VALUES (4);
INSERT INTO "Competições" ("Selec.","Competição","País","Mercados","Green","Red","P/L","Total") VALUES (0,'Brasileirão Série A','Brasil',12,0,0,0,0),
 (0,'Brasileirão Série B','Brasil',1,0,0,0,0),
 (0,'Eurocopa','Europa',2,0,0,0,0),
 (0,'Bundesliga 1','Alemanha',0,0,0,0,0),
 (0,'Bundesliga 2','Alemanha',0,0,0,0,0),
 (0,'DFB Pokal','Alemanha',0,0,0,0,0),
 (0,'Supercopa da Alemanha','Alemanha',0,0,0,0,0),
 (0,'Supercopa Intern. Argentina','Argentina',0,0,0,0,0),
 (0,'Campeonato Argentino','Argentina',0,0,0,0,0),
 (0,'Copa Argentina','Argentina',0,0,0,0,0),
 (0,'Copa do Brasil','Brasil',0,0,0,0,0),
 (0,'Estaduais','Brasil',0,0,0,0,0),
 (0,'La Liga','Espanha',0,0,0,0,0),
 (0,'La Liga 2','Espanha',0,0,0,0,0),
 (0,'Copa do Rei','Espanha',0,0,0,0,0),
 (0,'Supercopa da Espanha','Espanha',0,0,0,0,0),
 (0,'MLS','Estados Unidos',0,0,0,0,0),
 (0,'Ligue 1','França',0,0,0,0,0),
 (0,'Ligue 2','França',0,0,0,0,0),
 (0,'Copa da França','França',0,0,0,0,0),
 (0,'Supercopa da França','França',0,0,0,0,0),
 (0,'Eredivisie','Holanda',0,0,0,0,0),
 (0,'Premier League','Inglaterra',0,0,0,0,0),
 (0,'Championship','Inglaterra',0,0,0,0,0),
 (0,'FA Cup','Inglaterra',0,0,0,0,0),
 (0,'Copa da Liga','Inglaterra',0,0,0,0,0),
 (0,'Serie A','Itália',0,0,0,0,0),
 (0,'Copa da Itália','Itália',0,0,0,0,0),
 (0,'Supercopa da Itália','Itália',0,0,0,0,0),
 (0,'Primeira Liga','Portugal',0,0,0,0,0),
 (0,'Copa de Portugal','Portugal',0,0,0,0,0),
 (0,'Eliteserien','Noruega',0,0,0,0,0),
 (0,'Allsvenskan','Suécia',0,0,0,0,0),
 (0,'Super Lig','Turquia',0,0,0,0,0),
 (0,'Copa Sulamericana','América do Sul',0,0,0,0,0),
 (0,'Copa Libertadores','América do Sul',0,0,0,0,0),
 (0,'Recopa','América do Sul',0,0,0,0,0),
 (0,'Eliminatórias América Do Sul','América do Sul',0,0,0,0,0),
 (0,'Copa América','América do Sul',0,0,0,0,0),
 (0,'Champions League','Europa',0,0,0,0,0),
 (0,'Europa League','Europa',0,0,0,0,0),
 (0,'Nations','Internacional',0,0,0,0,0),
 (0,'Eliminatórias Europa','Europa',0,0,0,0,0),
 (0,'Mundial Interclubes','Internacional',0,0,0,0,0),
 (0,'Copa do Mundo','Internacional',0,0,0,0,0),
 (0,'Copa das Confederações','Internacional',0,0,0,0,0),
 (0,'Amistosos','Internacional',0,0,0,0,0),
 (0,'AFC Champions League','Ásia',0,0,0,0,0),
 (0,'Arábia Saudita','Ásia',0,0,0,0,0),
 (0,'Bahrein','Ásia',0,0,0,0,0),
 (0,'Emirados Árabes','Ásia',0,0,0,0,0),
 (0,'Irã','Ásia',0,0,0,0,0),
 (0,'Iraque','Ásia',0,0,0,0,0),
 (0,'Kuwait','Ásia',0,0,0,0,0),
 (0,'Catar','Ásia',0,0,0,0,0),
 (0,'China','Ásia',0,0,0,0,0),
 (0,'K League','Coreia do Sul',0,0,0,0,0),
 (0,'J League','Japão',0,0,0,0,0),
 (0,'Indonésia','Ásia',0,0,0,0,0),
 (0,'Tailândia','Ásia',0,0,0,0,0),
 (0,'Australiano','Austrália',0,0,0,0,0),
 (0,'Tajiquistão','Ásia',0,0,0,0,0),
 (0,'Bielorussia','Europa',0,0,0,0,0),
 (0,'Austriaco','Áustria',0,0,0,0,0),
 (0,'Suiço','Suíça',0,0,0,0,0),
 (0,'Dinamarques','Dinamarca',0,0,0,0,0),
 (0,'Islandês','Islândia',0,0,0,0,0);
DROP TRIGGER IF EXISTS "Recálculo Países (Update)";
CREATE TRIGGER "Recálculo Países (Update)" AFTER UPDATE ON Times BEGIN UPDATE Países SET Mercados = (Mercados - OLD.Mandante - OLD.Visitante) + NEW.Mandante + NEW.Visitante WHERE País = NEW.País; END;
DROP TRIGGER IF EXISTS "Recálculo Países (Insert)";
CREATE TRIGGER "Recálculo Países (Insert)" AFTER INSERT ON Times BEGIN UPDATE Países SET Mercados = Mercados + NEW.Mandante + NEW.Visitante WHERE País = NEW.País; END;
DROP TRIGGER IF EXISTS "after_insert_times";
CREATE TRIGGER after_insert_times AFTER INSERT ON Times FOR EACH ROW BEGIN UPDATE Times SET Mandante = 0, Visitante = 0, Greens = 0, Reds = 0, "P/L" = 0 WHERE "Time" = NEW."Time"; END;
DROP TRIGGER IF EXISTS "Recálculo Países (Delete)";
CREATE TRIGGER "Recálculo Países (Delete)" AFTER DELETE ON Times BEGIN UPDATE Países SET Mercados = Mercados - OLD.Mandante - OLD.Visitante WHERE País = OLD.País; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Times (Update)";
CREATE TRIGGER "Atualizar Contadores Times (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Times SET Mandante = Mandante - 1 WHERE "Time" = OLD.Mandante; UPDATE Times SET Visitante = Visitante - 1 WHERE "Time" = OLD.Visitante; UPDATE Times SET Mandante = Mandante + 1 WHERE "Time" = NEW.Mandante; UPDATE Times SET Visitante = Visitante + 1 WHERE "Time" = NEW.Visitante; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Times (Delete)";
CREATE TRIGGER "Atualizar Contadores Times (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Times SET Mandante = Mandante - 1 WHERE "Time" = OLD.Mandante; UPDATE Times SET Visitante = Visitante - 1 WHERE "Time" = OLD.Visitante; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Times (Insert)";
CREATE TRIGGER "Atualizar Contadores Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Times SET Mandante = Mandante + 1 WHERE "Time" = NEW.Mandante; UPDATE Times SET Visitante = Visitante + 1 WHERE "Time" = NEW.Visitante; END;
DROP TRIGGER IF EXISTS "Calcular Retorno e P/L Aposta (Insert)";
CREATE TRIGGER "Calcular Retorno e P/L Aposta (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Apostas SET Retorno = CASE NEW.Status WHEN 'Green' THEN Valor_Aposta * Odd WHEN 'Red' THEN 0 WHEN 'Meio Green' THEN (Valor_Aposta * Odd) / 2 WHEN 'Meio Red' THEN 0 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Retorno END, Profit_L = CASE NEW.Status WHEN 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta WHEN 'Red' THEN -Valor_Aposta WHEN 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2 WHEN 'Meio Red' THEN -Valor_Aposta / 2 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Profit_L END WHERE Cod_Aposta = NEW.Cod_Aposta; END;
DROP TRIGGER IF EXISTS "Calcular Retorno e P/L Aposta (UPDATE)";
CREATE TRIGGER "Calcular Retorno e P/L Aposta (UPDATE)" AFTER UPDATE ON Apostas BEGIN UPDATE Apostas SET Retorno = CASE NEW.Status WHEN 'Green' THEN Valor_Aposta * Odd WHEN 'Red' THEN 0 WHEN 'Meio Green' THEN (Valor_Aposta * Odd) / 2 WHEN 'Meio Red' THEN 0 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Retorno END, Profit_L = CASE NEW.Status WHEN 'Green' THEN (Valor_Aposta * Odd) - Valor_Aposta WHEN 'Red' THEN -Valor_Aposta WHEN 'Meio Green' THEN ((Valor_Aposta * Odd) - Valor_Aposta) / 2 WHEN 'Meio Red' THEN -Valor_Aposta / 2 WHEN 'Anulada' THEN 0 WHEN 'Cashout' THEN Profit_L END WHERE Cod_Aposta = NEW.Cod_Aposta; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Mercados Competição (Delete)";
CREATE TRIGGER "Atualizar Contadores Mercados Competição (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados - 1 WHERE "Competição" = OLD.Competição_AP; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Mercados Competição (Update)";
CREATE TRIGGER "Atualizar Contadores Mercados Competição (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados + 1 WHERE "Competição" = NEW.Competição_AP; UPDATE Competições SET Mercados = Mercados - 1 WHERE "Competição" = OLD.Competição_AP; END;
DROP TRIGGER IF EXISTS "Atualizar Contadores Mercados Competição (Insert)";
CREATE TRIGGER "Atualizar Contadores Mercados Competição (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Competições SET Mercados = Mercados + 1 WHERE "Competição" = NEW.Competição_AP; END;
DROP TRIGGER IF EXISTS "Atualizar Estratégias Times (Insert)";
CREATE TRIGGER "Atualizar Estratégias Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr + 1 WHERE "Estratégia" = NEW.Estratégia_Escolhida; END;
DROP TRIGGER IF EXISTS "Atualizar Estratégias Times (Update)";
CREATE TRIGGER "Atualizar Estratégias Times (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr + 1 WHERE "Estratégia" = NEW.Estratégia_Escolhida; UPDATE Estratégias SET Mercados_Estr = Mercados_Estr - 1 WHERE "Estratégia" = OLD.Estratégia_Escolhida; END;
DROP TRIGGER IF EXISTS "Atualizar Estratégias Times (Delete)";
CREATE TRIGGER "Atualizar Estratégias Times (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Estratégias SET Mercados_Estr = Mercados_Estr - 1 WHERE "Estratégia" = OLD.Estratégia_Escolhida; END;
DROP TRIGGER IF EXISTS "Atualizar Greens e Reds P/L Times (Insert)";
CREATE TRIGGER "Atualizar Greens e Reds P/L Times (Insert)" AFTER INSERT ON Apostas BEGIN UPDATE Times SET Greens = Greens + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END WHERE "Time" = NEW.Mandante OR "Time" = NEW.Visitante; END;
DROP TRIGGER IF EXISTS "Atualizar Greens Reds P/L Time (Update)";
CREATE TRIGGER "Atualizar Greens Reds P/L Time (Update)" AFTER UPDATE ON Apostas BEGIN UPDATE Times SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END + CASE WHEN NEW.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END + CASE WHEN NEW.Profit_L <> 0 THEN NEW.Profit_L ELSE 0 END WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante; END;
DROP TRIGGER IF EXISTS "Atualizar Greens Reds P/L Time (Delete)";
CREATE TRIGGER "Atualizar Greens Reds P/L Time (Delete)" AFTER DELETE ON Apostas BEGIN UPDATE Times SET Greens = Greens - CASE WHEN OLD.Status = 'Green' THEN 1 ELSE 0 END, Reds = Reds - CASE WHEN OLD.Status = 'Red' THEN 1 ELSE 0 END, "P/L" = "P/L" - CASE WHEN OLD.Profit_L <> 0 THEN OLD.Profit_L ELSE 0 END WHERE "Time" = OLD.Mandante OR "Time" = OLD.Visitante; END;
DROP TRIGGER IF EXISTS "Calcular Lucro Banca (Delete Apostas)";
CREATE TRIGGER "Calcular Lucro Banca (Delete Apostas)" AFTER DELETE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', OLD.Data) = strftime('%Y', Apostas.Data) AND strftime('%m', OLD.Data) = strftime('%m', Apostas.Data) ) WHERE Ano = strftime('%Y', OLD.Data) AND Mês = strftime('%m', OLD.Data); END;
DROP TRIGGER IF EXISTS "Calcular Lucro Banca (Insert Apostas)";
CREATE TRIGGER "Calcular Lucro Banca (Insert Apostas)" AFTER INSERT ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', NEW.Data) = Ano AND strftime('%m', NEW.Data) = Mês ) WHERE Ano = strftime('%Y', NEW.Data) AND Mês = strftime('%m', NEW.Data); END;
DROP TRIGGER IF EXISTS "Calcular Lucro Banca (Update Apostas)";
CREATE TRIGGER "Calcular Lucro Banca (Update Apostas)" AFTER UPDATE ON Apostas FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_R$" = ( SELECT IFNULL(SUM(Profit_L), 0) FROM Apostas WHERE strftime('%Y', NEW.Data) = Ano AND strftime('%m', NEW.Data) = Mês ) WHERE Ano = strftime('%Y', NEW.Data) AND Mês = strftime('%m', NEW.Data); END;
DROP TRIGGER IF EXISTS "Calcular Lucro % e Valor Final Banca (Update)";
CREATE TRIGGER "Calcular Lucro % e Valor Final Banca (Update)" AFTER UPDATE ON Banca FOR EACH ROW BEGIN UPDATE Banca SET "Lucro_%" = CASE WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE (NEW.Valor_Final - NEW.Valor_Inicial) / NEW.Valor_Inicial * 100 END WHERE rowid = NEW.rowid; UPDATE Banca SET Valor_Final = NEW.Valor_Inicial + "Lucro_R$" WHERE rowid = NEW.rowid; END;
DROP TRIGGER IF EXISTS "Calcular Lucro % e Valor Final Banca (Insert)";
CREATE TRIGGER "Calcular Lucro % e Valor Final Banca (Insert)" after insert on Banca for each row begin UPDATE Banca SET "Lucro_%" = CASE WHEN NEW.Valor_Final = NEW.Valor_Inicial OR NEW.Valor_Final = 0 THEN 0 ELSE CASE WHEN NEW."Valor_Inicial" != 0 THEN (NEW."Valor_Final" - NEW."Valor_Inicial") / NEW."Valor_Inicial" * 100 END END WHERE rowid = NEW.rowid; update Banca set Valor_Final = Valor_Inicial + Lucro_R$ where rowid = NEW.ROWID; END;
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (insert)";
CREATE TRIGGER "Atualiza Banca Final Apostas (insert)" 
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
DROP TRIGGER IF EXISTS "Atualiza Banca Final Apostas (Update)";
CREATE TRIGGER "Atualiza Banca Final Apostas (Update)" 
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
DROP TRIGGER IF EXISTS "Corrige Valores Banca";
CREATE TRIGGER "Corrige Valores Banca" 
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
DROP TRIGGER IF EXISTS "Corrige Valores Apostas(Insert)";
CREATE TRIGGER "Corrige Valores Apostas(Insert)"
AFTER INSERT ON Apostas
FOR EACH ROW
BEGIN
UPDATE Apostas
SET Retorno = ROUND(NEW.Retorno, 2),
Profit_L = ROUND (NEW.Profit_L, 2),
Banca_Final = ROUND (NEW.Banca_Final, 2)
WHERE ROWID = NEW.ROWID;
END;
DROP TRIGGER IF EXISTS "Corrige Valores Apostas(Update)";
CREATE TRIGGER "Corrige Valores Apostas(Update)"
AFTER UPDATE ON Apostas
FOR EACH ROW
BEGIN
UPDATE Apostas
SET Retorno = ROUND(NEW.Retorno, 2),
Profit_L = ROUND (NEW.Profit_L, 2),
Banca_Final = ROUND (NEW.Banca_Final, 2)
WHERE ROWID = NEW.ROWID;
END;
COMMIT;
