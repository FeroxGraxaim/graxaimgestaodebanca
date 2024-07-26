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
CREATE TABLE IF NOT EXISTS "Métodos" (
	"Cod_Metodo"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Nome"	VARCHAR,
	PRIMARY KEY("Cod_Metodo" AUTOINCREMENT)
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
CREATE TABLE IF NOT EXISTS "Apostas" (
	"Cod_Aposta"	INTEGER,
	"Selec."	BOOLEAN DEFAULT 0,
	"Data"	DATE,
	"Múltipla"	BOOLEAN DEFAULT 0,
	"Odd"	NUMERIC(9, 2),
	"Valor_Aposta"	NUMERIC(9, 2),
	"Status"	VARCHAR,
	"Cod_Jogo"	INTEGER,
	"Tipo"	BOOLEAN DEFAULT 0,
	"Cashout"	BOOLEAN DEFAULT 0,
	"Retorno"	NUMERIC(9, 2) DEFAULT 0,
	"Lucro"	NUMERIC(9, 2) DEFAULT 0,
	"Banca_Final"	NUMERIC(9, 2) DEFAULT 0,
	PRIMARY KEY("Cod_Aposta" AUTOINCREMENT)
);
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
INSERT INTO "Banca" ("Mês","Ano","Valor_Inicial","Lucro_R$","Lucro_%","Valor_Final","Stake") VALUES (7,2024,222.6,16.7,7.5,0,3.18);
INSERT INTO "Status_Aposta" ("Cod_Status","Status") VALUES (1,'Green'),
 (2,'Red'),
 (3,'Anulada'),
 (4,'Cashout'),
 (5,'Pré-live'),
 (6,'Meio Green'),
 (7,'Meio Red');
INSERT INTO "Países" ("Selec.","País","Mercados","Greens","Reds","P/L") VALUES (0,'Brasil',36,0,0,0),
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
INSERT INTO "Times" ("Selec.","Time","País","Mandante","Visitante","Greens","P/L","Reds") VALUES (0,'Criciúma','Brasil',2,1,2,0,1),
 (0,'Próspera','Brasil',0,0,0,0,0),
 (0,'Palmeiras','Brasil',2,0,2,3.49800000000001,0),
 (0,'Cruzeiro','Brasil',2,1,2,1.59,1),
 (0,'Atlético GO','Brasil',1,1,2,4.51559999999995,0),
 (0,'São Paulo','Brasil',0,1,1,2.6076,0),
 (0,'Fortaleza','Brasil',1,1,1,-0.5406,1),
 (0,'Grêmio','Brasil',0,1,1,2.067,0),
 (0,'Juventude','Brasil',2,0,2,4.6746,0),
 (0,'Vasco da Gama','Brasil',0,0,0,0,0),
 (0,'Internacional','Brasil',0,1,1,2.6076,0),
 (0,'Corinthians','Brasil',0,2,1,-1.90800000000001,1),
 (0,'Fluminense','Brasil',0,2,0,-6.36,2),
 (0,'Botafogo','Brasil',0,2,2,3.8796,0),
 (0,'Athletico PR','Brasil',1,1,1,2.2896,0),
 (0,'Cuiabá','Brasil',1,1,1,-1.113,1),
 (0,'Coritiba','Brasil',0,0,0,0,0),
 (0,'América MG','Brasil',0,1,1,1.8126,0),
 (0,'Eslováquia','Eslováquia',0,0,0,0,0),
 (0,'Ucrânia','Ucrânia',0,0,0,0,0),
 (0,'Holanda','Holanda',0,0,0,0,0),
 (0,'França','França',1,0,1,2.703,0),
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
 (0,'Ceará','Brasil',0,1,1,1.113,0),
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
 (0,'Bélgica','Bélgica',0,1,1,2.703,0),
 (0,'Austria Wien','Áustria',0,0,0,0,0),
 (0,'Paris Saint-Germain','França',0,0,0,0,0),
 (0,'Sérvia','Sérvia',0,0,0,0,0),
 (0,'Rússia','Rússia',0,0,0,0,0),
 (0,'Ponte Preta','Brasil',1,0,0,-3.18,1),
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
 (0,'Bahia','Brasil',1,0,0,-3.18,1),
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
 (0,'Bragantino','Brasil',0,1,1,2.226,0),
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
 (0,'Flamengo','Brasil',1,0,1,2,0);
INSERT INTO "ControleVersao" ("Versao") VALUES (6);
INSERT INTO "Competições" ("Cod_Comp","Selec.","Competição","País","Mercados","Green","Red","P/L","Total") VALUES (1,0,'Brasileirão Série A','Brasil',32,0,0,0,0),
 (2,0,'Brasileirão Série B','Brasil',5,0,0,0,0),
 (3,0,'Eurocopa','Europa',2,0,0,0,0),
 (4,0,'Bundesliga 1','Alemanha',0,0,0,0,0),
 (5,0,'Bundesliga 2','Alemanha',0,0,0,0,0),
 (6,0,'DFB Pokal','Alemanha',0,0,0,0,0),
 (7,0,'Supercopa da Alemanha','Alemanha',0,0,0,0,0),
 (8,0,'Supercopa Intern. Argentina','Argentina',0,0,0,0,0),
 (9,0,'Campeonato Argentino','Argentina',0,0,0,0,0),
 (10,0,'Copa Argentina','Argentina',0,0,0,0,0),
 (11,0,'Copa do Brasil','Brasil',2,0,0,0,0),
 (12,0,'Estaduais','Brasil',0,0,0,0,0),
 (13,0,'La Liga','Espanha',0,0,0,0,0),
 (14,0,'La Liga 2','Espanha',0,0,0,0,0),
 (15,0,'Copa do Rei','Espanha',0,0,0,0,0),
 (16,0,'Supercopa da Espanha','Espanha',0,0,0,0,0),
 (17,0,'MLS','Estados Unidos',0,0,0,0,0),
 (18,0,'Ligue 1','França',0,0,0,0,0),
 (19,0,'Ligue 2','França',0,0,0,0,0),
 (20,0,'Copa da França','França',0,0,0,0,0),
 (21,0,'Supercopa da França','França',0,0,0,0,0),
 (22,0,'Eredivisie','Holanda',0,0,0,0,0),
 (23,0,'Premier League','Inglaterra',0,0,0,0,0),
 (24,0,'Championship','Inglaterra',0,0,0,0,0),
 (25,0,'FA Cup','Inglaterra',0,0,0,0,0),
 (26,0,'Copa da Liga','Inglaterra',0,0,0,0,0),
 (27,0,'Serie A','Itália',0,0,0,0,0),
 (28,0,'Copa da Itália','Itália',0,0,0,0,0),
 (29,0,'Supercopa da Itália','Itália',0,0,0,0,0),
 (30,0,'Primeira Liga','Portugal',0,0,0,0,0),
 (31,0,'Copa de Portugal','Portugal',0,0,0,0,0),
 (32,0,'Eliteserien','Noruega',0,0,0,0,0),
 (33,0,'Allsvenskan','Suécia',0,0,0,0,0),
 (34,0,'Super Lig','Turquia',0,0,0,0,0),
 (35,0,'Copa Sulamericana','América do Sul',0,0,0,0,0),
 (36,0,'Copa Libertadores','América do Sul',0,0,0,0,0),
 (37,0,'Recopa','América do Sul',0,0,0,0,0),
 (38,0,'Eliminatórias América Do Sul','América do Sul',0,0,0,0,0),
 (39,0,'Copa América','América do Sul',0,0,0,0,0),
 (40,0,'Champions League','Europa',0,0,0,0,0),
 (41,0,'Europa League','Europa',0,0,0,0,0),
 (42,0,'Nations','Internacional',0,0,0,0,0),
 (43,0,'Eliminatórias Europa','Europa',0,0,0,0,0),
 (44,0,'Mundial Interclubes','Internacional',0,0,0,0,0),
 (45,0,'Copa do Mundo','Internacional',0,0,0,0,0),
 (46,0,'Copa das Confederações','Internacional',0,0,0,0,0),
 (47,0,'Amistosos','Internacional',0,0,0,0,0),
 (48,0,'AFC Champions League','Ásia',0,0,0,0,0),
 (49,0,'Arábia Saudita','Ásia',0,0,0,0,0),
 (50,0,'Bahrein','Ásia',0,0,0,0,0),
 (51,0,'Emirados Árabes','Ásia',0,0,0,0,0),
 (52,0,'Irã','Ásia',0,0,0,0,0),
 (53,0,'Iraque','Ásia',0,0,0,0,0),
 (54,0,'Kuwait','Ásia',0,0,0,0,0),
 (55,0,'Catar','Ásia',0,0,0,0,0),
 (56,0,'China','Ásia',0,0,0,0,0),
 (57,0,'K League','Coreia do Sul',0,0,0,0,0),
 (58,0,'J League','Japão',0,0,0,0,0),
 (59,0,'Indonésia','Ásia',0,0,0,0,0),
 (60,0,'Tailândia','Ásia',0,0,0,0,0),
 (61,0,'Australiano','Austrália',0,0,0,0,0),
 (62,0,'Tajiquistão','Ásia',0,0,0,0,0),
 (63,0,'Bielorussia','Europa',0,0,0,0,0),
 (64,0,'Austriaco','Áustria',0,0,0,0,0),
 (65,0,'Suiço','Suíça',0,0,0,0,0),
 (66,0,'Dinamarques','Dinamarca',0,0,0,0,0),
 (67,0,'Islandês','Islândia',0,0,0,0,0);
INSERT INTO "Linhas" ("Cod_Linha","Nome","Cod_Metodo") VALUES (1,'+ 0,5 Gols Casa',7),
 (2,'+ 0,5 Gols Fora',7),
 (3,'+ 0,5 Gols',7),
 (4,'+ 1,5 Gols',7),
 (5,'+ 2,5 Gols',7),
 (6,'+ 3,5 Gols',7),
 (7,'- 3,5 Gols',6),
 (8,'- 2,5 Gols',6),
 (9,'- 1,5 Gols',6),
 (10,'- 0,5 Gols',6),
 (11,'+ 0,5 Casa',5),
 (12,'+ 0,5 Fora',5),
 (13,'+ 0,5',5),
 (14,'+ 1,5',5),
 (15,'+ 2,5',5),
 (16,'+ 3,5',5),
 (17,'- 0,5',5),
 (18,'- 1,5',5),
 (19,'- 2,5',5),
 (20,'- 3,5',5),
 (21,'- 4,5',5),
 (22,'- 5,5',5),
 (23,'- 6,5',5),
 (24,'- 7,5',5),
 (25,'- 8,5',5),
 (26,'- 9,5',5),
 (27,'- 10,5',5),
 (28,'- 11,5',5),
 (29,'- 12,5',5),
 (30,'Europeu -3',4),
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
 (59,'+ 0,5 Cantos',8),
 (60,'+ 1,5 Cantos',8),
 (61,'+ 2,5 Cantos',8),
 (62,'+ 3,5 Cantos',8),
 (63,'+ 4,5 Cantos',8),
 (64,'+ 5,5 Cantos',8),
 (65,'+ 6,5 Cantos',8),
 (66,'+ 7,5 Cantos',8),
 (67,'+ 8,5 Cantos',8),
 (68,'-14,5 Cantos',0),
 (69,'- 13,5 Cantos',0),
 (70,'- 12,5 Cantos',0),
 (71,'- 11,5 Cantos',0),
 (72,'- 10,5 Cantos',0),
 (73,'- 9,5 Cantos',0),
 (74,'- 8,5 Cantos',0),
 (75,'- 7,5 Cantos',0),
 (76,'- 6,5 Cantos',0),
 (77,'- 5,5 Cantos',0),
 (78,'- 4,5 Cantos',0),
 (79,'- 3,5 Cantos',0),
 (80,'- 2,5 Cantos',0),
 (81,'- 1,5 Cantos',0),
 (82,'Casa Vence',1),
 (83,'Fora Vence',1),
 (84,'Empate',1),
 (85,'Casa ou Empate',1),
 (86,'Fora ou Empate',1),
 (87,'Empate Anula Casa',1),
 (88,'Empate Anula Fora',1),
 (89,'Casa ou Fora',1);
INSERT INTO "Métodos" ("Cod_Metodo","Selec.","Nome") VALUES (0,0,'Under Escanteios'),
 (1,0,'Resultado Equipe'),
 (3,0,'Handicap Asiático'),
 (4,0,'Handicap Europeu'),
 (5,0,'Cartões'),
 (6,0,'Under Gols'),
 (7,0,'Over Gols'),
 (8,0,'Over Escanteios');
CREATE TRIGGER "Atualiza Status Aposta (Update)"
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
CREATE TRIGGER "Atualiza Status Aposta (Delete)"
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
CREATE TRIGGER "Atualiza Banca Final Apostas (insert)" 
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
CREATE TRIGGER "Atualiza Banca Final Apostas (Update)" 
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
CREATE TRIGGER "Atualiza Odd Apostas (Update)"
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
CREATE TRIGGER "Atualiza Odd Apostas (Delete)"
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
CREATE TRIGGER "Atualiza Banca Final (Delete)"
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
CREATE TRIGGER "Atualiza Banca Final (Insert)"
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
CREATE TRIGGER "Atualiza Banca Final (Update)"
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
