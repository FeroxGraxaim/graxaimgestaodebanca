CREATE TABLE IF NOT EXISTS "Unidades" (
	"Unidade"	VARCHAR
);
CREATE TABLE IF NOT EXISTS "Perfis" (
	"Perfil"	VARCHAR,
	PRIMARY KEY("Perfil")
);
CREATE TABLE "Selecionar Perfil" (
	"Perfil Selecionado"	VARCHAR NOT NULL DEFAULT 'Conservador',
	"GestaoPcent"	BOOLEAN DEFAULT (0)
);
CREATE TABLE IF NOT EXISTS "Selecionar Mês e Ano" (
	"Mês"	INTEGER,
	"Ano"	INTEGER
);
CREATE TABLE IF NOT EXISTS "Banca" (
	"Mês"	INTEGER,
	"Ano"	INTEGER,
	"Valor_Inicial"	NUMERIC(9, 2) DEFAULT 0,
	"Aporte"	NUMERIC(9, 2) DEFAULT 0
);
CREATE TABLE IF NOT EXISTS "BancaInicial" (
	"Banca"	NUMERIC(9, 2)
);
CREATE TABLE IF NOT EXISTS "Status_Aposta" (
	"Cod_Status"	INTEGER,
	"Status"	VARCHAR,
	PRIMARY KEY("Cod_Status" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Países" (
	"Selecao"	BOOLEAN DEFAULT 0,
	"País"	VARCHAR NOT NULL,
	"Mercados"	INTEGER DEFAULT 0,
	"Greens"	INTEGER DEFAULT 0,
	"Reds"	INTEGER DEFAULT 0,
	"P/L"	INTEGER DEFAULT 0,
	PRIMARY KEY("País")
);
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
CREATE TABLE IF NOT EXISTS "ControleVersao" (
	"Versao"	INTEGER NOT NULL
);
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
CREATE TABLE IF NOT EXISTS "Métodos" (
	"Cod_Metodo"	INTEGER,
	"Selecao"	BOOLEAN DEFAULT 0,
	"Nome"	VARCHAR,
	PRIMARY KEY("Cod_Metodo" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Linhas" (
	"Cod_Linha"	INTEGER NOT NULL,
	"Nome"	VARCHAR,
	"Cod_Metodo"	INTEGER,
	FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	PRIMARY KEY("Cod_Linha" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Apostas" (
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
CREATE TABLE IF NOT EXISTS "Mercados" (
	"Cod_Mercado" INTEGER PRIMARY KEY AUTOINCREMENT,
	"Cod_Jogo"	INTEGER,
	"Cod_Metodo"	INTEGER,
	"Cod_Linha"	INTEGER,
	"Odd"	NUMERIC(9, 2),
	"Status"	VARCHAR DEFAULT 'Pré-live',
	"Cod_Aposta"	INTEGER,
	CONSTRAINT "FK_Mercados_Jogo_2" FOREIGN KEY("Cod_Linha") REFERENCES "Linhas"("Cod_Linha"),
	CONSTRAINT "FK_Mercados_Linhas_3" FOREIGN KEY("Cod_Metodo") REFERENCES "Métodos"("Cod_Metodo"),
	CONSTRAINT "FK_Mercados_Apostas" FOREIGN KEY("Cod_Aposta") REFERENCES "Apostas"("Cod_Aposta")
);
CREATE TABLE IF NOT EXISTS "Jogo" (
	"Cod_Jogo"	INTEGER NOT NULL,
	"Cod_Comp"	VARCHAR,
	"Mandante"	VARCHAR,
	"Visitante"	VARCHAR,
	FOREIGN KEY("Cod_Comp") REFERENCES "Competicoes"("Cod_Comp"),
	FOREIGN KEY("Mandante") REFERENCES "Times"("Time"),
	PRIMARY KEY("Cod_Jogo" AUTOINCREMENT),
	FOREIGN KEY("Visitante") REFERENCES "Times"("Time")
);
CREATE TABLE IF NOT EXISTS "Selecaoionar Mês e Ano" (
	"Mês"	INTEGER,
	"Ano"	INTEGER
);
CREATE TABLE IF NOT EXISTS "ConfigPrograma" (
	"ExibirTelaBoasVindas"	BOOLEAN DEFAULT 1,
	"GestaoVariavel"	BOOLEAN DEFAULT 0,
	"PreRelease"	BOOLEAN DEFAULT 0,
	"GestaoPcent" BOOLEAN DEFAULT 0
);
INSERT INTO "Unidades" ("Unidade") VALUES ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
 ('0,5 Un'),
 ('0,75 Un'),
 ('1 Un'),
 ('1,25 Un'),
 ('1,5 Un'),
 ('1,75 Un'),
 ('2 Un'),
 ('Outro Valor'),
 ('0,25 Un'),
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
INSERT INTO "Selecionar Perfil" ("Perfil Selecionado") VALUES ('Conservador');
INSERT INTO "Selecionar Mês e Ano" ("Mês","Ano") VALUES (8,2024);
INSERT INTO "Status_Aposta" ("Cod_Status","Status") VALUES (1,'Green'),
 (2,'Red'),
 (3,'Anulada'),
 (4,'Cashout'),
 (5,'Pré-live'),
 (6,'Meio Green'),
 (7,'Meio Red');
INSERT INTO "Países" ("Selecao","País","Mercados","Greens","Reds","P/L") VALUES ('False','Brasil',36,0,0,0),
 ('False','Eslováquia',0,0,0,0),
 ('False','Ucrânia',0,0,0,0),
 ('False','Holanda',1,0,0,0),
 ('False','França',1,0,0,0),
 ('False','Polônia',0,0,0,0),
 ('False','Áustria',0,0,0,0),
 ('False','Turquia',0,0,0,0),
 ('False','Alemanha',0,0,0,0),
 ('False','Argentina',0,0,0,0),
 ('False','Espanha',0,0,0,0),
 ('False','EUA',0,0,0,0),
 ('False','Inglaterra',0,0,0,0),
 ('False','Itália',1,0,0,0),
 ('False','Portugal',1,0,0,0),
 ('False','Noruega',0,0,0,0),
 ('False','Suécia',0,0,0,0),
 ('False','Sudamérica',0,0,0,0),
 ('False','Europa',0,0,0,0),
 ('False','Mundo',0,0,0,0),
 ('False','Médio Oriente',0,0,0,0),
 ('False','Extremo Oriente',0,0,0,0),
 ('False','Sudeste Asiático',0,0,0,0),
 ('False','Oceania',0,0,0,0),
 ('False','Bielorussia',0,0,0,0),
 ('False','Austria',0,0,0,0),
 ('False','Suíça',0,0,0,0),
 ('False','Dinamarca',0,0,0,0),
 ('False','Islândia',0,0,0,0),
 ('False','Hungria',0,0,0,0),
 ('False','Malta',0,0,0,0),
 ('False','Luxemburgo',0,0,0,0),
 ('False','Ilhas Faroe',0,0,0,0),
 ('False','Monaco',0,0,0,0),
 ('False','Montenegro',0,0,0,0),
 ('False','Chipre',0,0,0,0),
 ('False','Letônia',0,0,0,0),
 ('False','Bósnia e Herzegovina',0,0,0,0),
 ('False','Estônia',0,0,0,0),
 ('False','Sérvia',1,0,0,0),
 ('False','Eslovênia',0,0,0,0),
 ('False','Geórgia',0,0,0,0),
 ('False','Moldávia',0,0,0,0),
 ('False','Armênia',0,0,0,0),
 ('False','Azerbaijão',0,0,0,0),
 ('False','Kosovo',0,0,0,0),
 ('False','Andorra',0,0,0,0),
 ('False','San Marino',0,0,0,0),
 ('False','Gibraltar',0,0,0,0),
 ('False','Liechtenstein',0,0,0,0),
 ('False','Mônaco',0,0,0,0),
 ('False','Vaticano',0,0,0,0),
 ('False','Bielorrússia',0,0,0,0),
 ('False','Cazaquistão',0,0,0,0),
 ('False','Macedônia do Norte',0,0,0,0),
 ('False','São Marino',0,0,0,0),
 ('False','Curaçao',0,0,0,0),
 ('False','Paraguai',0,0,0,0),
 ('False','Irlanda',0,0,0,0),
 ('False','Bolívia',0,0,0,0),
 ('False','Chile',0,0,0,0),
 ('False','Escócia',0,0,0,0),
 ('False','República Tcheca',0,0,0,0),
 ('False','Bélgica',1,0,0,0),
 ('False','Rússia',0,0,0,0),
 ('False','Romênia',0,0,0,0),
 ('False','Japão',0,0,0,0),
 ('False','Israel',0,0,0,0),
 ('False','Finlândia',0,0,0,0),
 ('False','Croácia',0,0,0,0),
 ('False','Bulgária',0,0,0,0),
 ('False','Equador',0,0,0,0),
 (0,'América',0,0,0,0),
 (0,'Uruguai',0,0,0,0);
INSERT INTO "Times" ("Selecao","Time","País","Mandante","Visitante","Greens","P/L","Reds") VALUES ('False','Criciúma','Brasil',2,1,2,0,1),
 ('False','Próspera','Brasil',0,0,0,0,0),
 ('False','Palmeiras','Brasil',2,0,2,3,0),
 ('False','Cruzeiro','Brasil',2,1,2,1,1),
 ('False','Atlético GO','Brasil',1,1,2,4,0),
 ('False','São Paulo','Brasil',0,1,1,2,0),
 ('False','Fortaleza','Brasil',1,1,1,0,1),
 ('False','Grêmio','Brasil',0,1,1,2,0),
 ('False','Juventude','Brasil',2,0,2,4,0),
 ('False','Vasco da Gama','Brasil',0,0,0,0,0),
 ('False','Internacional','Brasil',0,1,1,2,0),
 ('False','Corinthians','Brasil',0,2,1,-1,1),
 ('False','Fluminense','Brasil',0,2,0,-6,2),
 ('False','Botafogo','Brasil',0,2,2,3,0),
 ('False','Athletico PR','Brasil',1,1,1,2,0),
 ('False','Cuiabá','Brasil',1,1,1,-1,1),
 ('False','Coritiba','Brasil',0,0,0,0,0),
 ('False','América MG','Brasil',0,1,1,1,0),
 ('False','Eslováquia','Eslováquia',0,0,0,0,0),
 ('False','Ucrânia','Ucrânia',0,0,0,0,0),
 ('False','Holanda','Holanda',0,0,0,0,0),
 ('False','França','França',1,0,1,2,0),
 ('False','Polônia','Polônia',0,0,0,0,0),
 ('False','Áustria','Áustria',0,0,0,0,0),
 ('False','Turquia','Turquia',0,0,0,0,0),
 ('False','AC Milan','Itália',0,1,0,0,0),
 ('False','Tondela','Portugal',0,0,0,0,0),
 ('False','Ajax','Holanda',1,0,0,0,0),
 ('False','Alavés','Espanha',0,0,0,0,0),
 ('False','Portland Timbers','EUA',0,0,0,0,0),
 ('False','Crystal Palace','Inglaterra',0,0,0,0,0),
 ('False','Goiás','Brasil',0,0,0,0,0),
 ('False','Chapecoense','Brasil',0,1,0,-3,1),
 ('False','Fulham','Inglaterra',0,0,0,0,0),
 ('False','Portugal','Portugal',1,0,0,-3,1),
 ('False','Lille','França',0,0,0,0,0),
 ('False','Ceará','Brasil',0,1,1,1,0),
 ('False','Fortuna','Alemanha',0,0,0,0,0),
 ('False','Frankfurt','Alemanha',0,0,0,0,0),
 ('False','Náutico','Brasil',0,0,0,0,0),
 ('False','Operário','Brasil',0,0,0,0,0),
 ('False','Qarabağ','Azerbaijão',0,0,0,0,0),
 ('False','Genoa','Itália',0,0,0,0,0),
 ('False','Boca Juniors','Argentina',0,0,0,0,0),
 ('False','Libertad','Paraguai',0,0,0,0,0),
 ('False','Getafe','Espanha',0,0,0,0,0),
 ('False','Granada','Espanha',0,0,0,0,0),
 ('False','Espanha','Espanha',0,0,0,0,0),
 ('False','Alemanha','Alemanha',0,0,0,0,0),
 ('False','Hamburger SV','Alemanha',0,0,0,0,0),
 ('False','Hoffenheim','Alemanha',0,0,0,0,0),
 ('False','Inter Milan','Itália',0,0,0,0,0),
 ('False','København','Dinamarca',0,0,0,0,0),
 ('False','Shamrock Rovers','Irlanda',0,0,0,0,0),
 ('False','Itália','Itália',0,0,0,0,0),
 ('False','Juventus','Itália',0,0,0,0,0),
 ('False','Rayo Vallecano','Espanha',0,0,0,0,0),
 ('False','Always Ready','Bolívia',0,0,0,0,0),
 ('False','Lazio','Itália',0,0,0,0,0),
 ('False','Leicester City','Inglaterra',0,0,0,0,0),
 ('False','Minnesota United','EUA',0,0,0,0,0),
 ('False','Athletico Paranaense','Brasil',0,0,0,0,0),
 ('False','Levante','Espanha',0,0,0,0,0),
 ('False','Bayer Leverkusen','Alemanha',0,0,0,0,0),
 ('False','Universidad Católica','Chile',0,0,0,0,0),
 ('False','Liverpool','Inglaterra',0,0,0,0,0),
 ('False','Salernitana','Itália',0,0,0,0,0),
 ('False','Hungria','Hungria',0,0,0,0,0),
 ('False','Middlesbrough','Inglaterra',0,0,0,0,0),
 ('False','Lyon','França',0,0,0,0,0),
 ('False','Atlético Goianiense','Brasil',0,0,0,0,0),
 ('False','Escócia','Escócia',0,0,0,0,0),
 ('False','Mainz','Alemanha',0,0,0,0,0),
 ('False','Malmö FF','Suécia',0,0,0,0,0),
 ('False','Manchester City','Inglaterra',0,0,0,0,0),
 ('False','Manchester United','Inglaterra',0,0,0,0,0),
 ('False','Strasbourg','França',0,0,0,0,0),
 ('False','República Tcheca','República Tcheca',0,0,0,0,0),
 ('False','Napoli','Itália',0,0,0,0,0),
 ('False','Newcastle United','Inglaterra',0,0,0,0,0),
 ('False','Nice','França',0,0,0,0,0),
 ('False','Norwich City','Inglaterra',0,0,0,0,0),
 ('False','Nürnberg','Alemanha',0,0,0,0,0),
 ('False','Ingolstadt','Alemanha',0,0,0,0,0),
 ('False','Paderborn','Alemanha',0,0,0,0,0),
 ('False','Bélgica','Bélgica',0,1,1,2,0),
 ('False','Austria Wien','Áustria',0,0,0,0,0),
 ('False','Paris Saint-Germain','França',0,0,0,0,0),
 ('False','Sérvia','Sérvia',0,0,0,0,0),
 ('False','Rússia','Rússia',0,0,0,0,0),
 ('False','Ponte Preta','Brasil',1,0,0,-3,1),
 ('False','Porto','Portugal',0,0,0,0,0),
 ('False','Portimonense','Portugal',0,0,0,0,0),
 ('False','PSV Eindhoven','Holanda',0,0,0,0,0),
 ('False','Rangers','Escócia',0,0,0,0,0),
 ('False','Bordeaux','França',0,0,0,0,0),
 ('False','RB Leipzig','Alemanha',0,0,0,0,0),
 ('False','Real Madrid','Espanha',0,0,0,0,0),
 ('False','Real Sociedad','Espanha',0,0,0,0,0),
 ('False','Romênia','Romênia',0,0,0,0,0),
 ('False','Roma','Itália',0,0,0,0,0),
 ('False','Eintracht Braunschweig','Alemanha',0,0,0,0,0),
 ('False','Hatayspor','Turquia',0,0,0,0,0),
 ('False','Kawasaki Frontale','Japão',0,0,0,0,0),
 ('False','RB Salzburg','Áustria',0,0,0,0,0),
 ('False','Sampdoria','Itália',0,0,0,0,0),
 ('False','San Marino','San Marino',0,0,0,0,0),
 ('False','Santos','Brasil',1,0,0,-3,1),
 ('False','Sassuolo','Itália',0,0,0,0,0),
 ('False','Schalke 04','Alemanha',0,0,0,0,0),
 ('False','Sevilla','Espanha',0,0,0,0,0),
 ('False','Shakhtar Donetsk','Ucrânia',0,0,0,0,0),
 ('False','St Gilloise','Bélgica',0,0,0,0,0),
 ('False','Yokohama Marinos','Japão',0,0,0,0,0),
 ('False','Arsenal','Inglaterra',0,0,0,0,0),
 ('False','Aston Villa','Inglaterra',0,0,0,0,0),
 ('False','Atalanta','Itália',0,0,0,0,0),
 ('False','Athletic Bilbao','Espanha',0,0,0,0,0),
 ('False','Atlético Madrid','Espanha',0,0,0,0,0),
 ('False','Los Angeles FC','EUA',0,0,0,0,0),
 ('False','Atlético Mineiro','Brasil',0,0,0,0,0),
 ('False','Los Angeles Galaxy','EUA',0,0,0,0,0),
 ('False','Watford','Inglaterra',0,0,0,0,0),
 ('False','Augsburg','Alemanha',0,0,0,0,0),
 ('False','Lillestrøm','Noruega',0,0,0,0,0),
 ('False','Fenerbahçe','Turquia',0,0,0,0,0),
 ('False','Bodø/Glimt','Noruega',0,0,0,0,0),
 ('False','Brøndby','Dinamarca',0,0,0,0,0),
 ('False','Bahia','Brasil',1,0,0,-3,1),
 ('False','Barcelona','Espanha',0,0,0,0,0),
 ('False','FC Zürich','Suíça',0,0,0,0,0),
 ('False','Başakşehir','Turquia',0,0,0,0,0),
 ('False','Basel','Suíça',0,0,0,0,0),
 ('False','BATE Borisov','Bielorrússia',0,0,0,0,0),
 ('False','Bayern Munich','Alemanha',0,0,0,0,0),
 ('False','América Mineiro','Brasil',0,0,0,0,0),
 ('False','Benfica','Portugal',0,0,0,0,0),
 ('False','Beşiktaş','Turquia',0,0,0,0,0),
 ('False','Real Betis','Espanha',0,0,0,0,0),
 ('False','Maccabi Haifa','Israel',0,0,0,0,0),
 ('False','Bologna','Itália',0,0,0,0,0),
 ('False','Bournemouth','Inglaterra',0,0,0,0,0),
 ('False','Braga','Portugal',0,0,0,0,0),
 ('False','Bragantino','Brasil',0,1,1,2,0),
 ('False','Slavia Praga','República Tcheca',0,0,0,0,0),
 ('False','Brescia','Itália',0,0,0,0,0),
 ('False','Brighton','Inglaterra',0,0,0,0,0),
 ('False','Trabzonspor','Turquia',0,0,0,0,0),
 ('False','Cagliari','Itália',0,0,0,0,0),
 ('False','Konyaspor','Turquia',0,0,0,0,0),
 ('False','Celta Vigo','Espanha',0,0,0,0,0),
 ('False','West Ham','Inglaterra',0,0,0,0,0),
 ('False','Chelsea','Inglaterra',0,0,0,0,0),
 ('False','Partizan','Sérvia',0,0,0,0,0),
 ('False','Crvena Zvezda','Sérvia',0,0,0,0,0),
 ('False','Molde','Noruega',0,0,0,0,0),
 ('False','St. Gallen','Suíça',0,0,0,0,0),
 ('False','Osasuna','Espanha',0,0,0,0,0),
 ('False','Metz','França',0,0,0,0,0),
 ('False','Figueirense','Brasil',0,0,0,0,0),
 ('False','HJK','Finlândia',0,0,0,0,0),
 ('False','Vålerenga','Noruega',0,0,0,0,0),
 ('False','Real Salt Lake','EUA',0,0,0,0,0),
 ('False','Borussia Dortmund','Alemanha',0,0,0,0,0),
 ('False','Croácia','Croácia',0,0,0,0,0),
 ('False','Ludogorets','Bulgária',0,0,0,0,0),
 ('False','Dynamo Dresden','Alemanha',0,0,0,0,0),
 ('False','Cluj','Romênia',0,0,0,0,0),
 ('False','FC Sion','Suíça',0,0,0,0,0),
 ('False','St. Pauli','Alemanha',0,0,0,0,0),
 ('False','Espanyol','Espanha',0,0,0,0,0),
 ('False','Everton','Inglaterra',0,0,0,0,0),
 ('False','Liechtenstein','Liechtenstein',0,0,0,0,0),
 ('False','FC Heidenheim','Alemanha',0,0,0,0,0),
 ('False','FC Köln','Alemanha',0,0,0,0,0),
 ('False','Lokomotiv Plovdiv','Bulgária',0,0,0,0,0),
 ('False','Saint-Étienne','França',0,0,0,0,0),
 ('False','Ind. del Valle','Equador',0,0,0,0,0),
 ('False','Flamengo','Brasil',1,0,1,2,0),
 (0,'Maccabi Petah Tikva','Europa',0,0,0,0,0),
 (0,'Vojvodina','Europa',0,0,0,0,0),
 (0,'Brusque','Brasil',0,0,0,0,0),
 (0,'Newells Old Boys','Argentina',0,0,0,0,0),
 (0,'Estudiantes de La Plata','Argentina',0,0,0,0,0),
 (0,'Sport Recife','Brasil',0,0,0,0,0),
 (0,'Velez Sarsfield','Argentina',0,0,0,0,0),
 (0,'Defensia y Justicia','Argentina',0,0,0,0,0),
 (0,'Vitória','Brasil',0,0,0,0,0),
 (0,'Talleres Cordoba','Argentina',0,0,0,0,0),
 (0,'Instituto AC Cordoba','Argentina',0,0,0,0,0),
 (0,'Independiente','Argentina',0,0,0,0,0),
 (0,'San Lorenzo','Argentina',0,0,0,0,0),
 (0,'Huracan','Argentina',0,0,0,0,0),
 (0,'Racing Club','Argentina',0,0,0,0,0),
 (0,'Union de Santa Fe','Argentina',0,0,0,0,0),
 (0,'River Plate','Argentina',0,0,0,0,0),
 (0,'Barracas Central','Argentina',0,0,0,0,0),
 (0,'Novorizontino','Brasil',0,0,0,0,0),
 (0,'Lanús','Argentina',0,0,0,0,0),
 (0,'Tigre','Argentina',0,0,0,0,0),
 (0,'Deportivo Riestra','Argentina',0,0,0,0,0),
 (0,'Central Cordoba','Argentina',0,0,0,0,0),
 (0,'Mirassol','Brasil',0,0,0,0,0),
 (0,'Platense','Argentina',0,0,0,0,0),
 (0,'BAnfield','Argentina',0,0,0,0,0),
 (0,'Banfield','Argentina',0,0,0,0,0),
 (0,'Vila Nova','Brasil',0,0,0,0,0),
 (0,'Paysandu','Brasil',0,0,0,0,0),
 (0,'Malmo FF','Europa',0,0,0,0,0),
 (0,'PAOK','Europa',0,0,0,0,0),
 (0,'Dinamo Kiev','Europa',0,0,0,0,0),
 (0,'Rangers FC','Europa',0,0,0,0,0),
 (0,'AC Sparta Praga','Europa',0,0,0,0,0),
 (0,'FCSB','Europa',0,0,0,0,0),
 (0,'Guarani','Brasil',0,0,0,0,0),
 (0,'Argentinos Juniors','Argentina',0,0,0,0,0),
 (0,'Sarmiento','Argentina',0,0,0,0,0),
 (0,'SC Braga','Europa',0,0,0,0,0),
 (0,'Servette FC','Europa',0,0,0,0,0),
 (0,'CRB','Brasil',0,0,0,0,0),
 (0,'Colo-Colo','América',0,0,0,0,0),
 (0,'Junior','América',0,0,0,0,0),
 (0,'Nacional de Football','Uruguai',0,0,0,0,0),
 (0,'Belgrano','Argentina',0,0,0,0,0),
 (0,'Santa Clara','Portugal',0,0,0,0,0),
 (0,'Leverkusen','Alemanha',0,0,0,0,0),
 (0,'VfB Stuttgart','Alemanha',0,0,0,0,0),
 (0,'Valência','Espanha',0,0,0,0,0),
 (0,'AS Roma','Itália',0,0,0,0,0),
 (0,'SS Lazio','Itália',0,0,0,0,0),
 (0,'Venezia','Itália',0,0,0,0,0),
 (0,'RCD Mallorca','Espanha',0,0,0,0,0),
 (0,'Rosario Central','Argentina',0,0,0,0,0),
 (0,'Eslovénia','Europa',0,0,0,0,0),
 (0,'Bolívia','América',0,0,0,0,0),
 (0,'Panamá','América',0,0,0,0,0),
 (0,'Santa Catarina','Brasil',0,0,0,0,0),
 (0,'Metropol','Brasil',0,0,0,0,0),
 (0,'Villarreal','Espanha',0,0,0,0,0),
 (0,'Como','Itália',0,0,0,0,0),
 (0,'Lecce','Itália',0,0,0,0,0),
 (0,'Atlanta','Itália',0,0,0,0,0),
 (0,'Huachipato','Chile',0,0,0,0,0),
 (0,'Bodo/Glimt','Europa',0,0,0,0,0),
 (0,'Ituano','Brasil',0,0,0,0,0),
 (0,'Botafogo SP','Brasil',0,0,0,0,0),
 (0,'LDU Quito','Equador',0,0,0,0,0),
 (0,'Avaí','Brasil',0,0,0,0,0);
INSERT INTO "ControleVersao" ("Versao") VALUES (26);
INSERT INTO "Competicoes" ("Cod_Comp","Selecao","Competicao","País","Mercados","Green","Red","P/L","Total") VALUES (1,'False','Brasileirão Série A','Brasil',32,0,0,0,0),
 (2,'False','Brasileirão Série B','Brasil',5,0,0,0,0),
 (3,'False','Eurocopa','Europa',2,0,0,0,0),
 (4,'False','Bundesliga 1','Alemanha',0,0,0,0,0),
 (5,'False','Bundesliga 2','Alemanha',0,0,0,0,0),
 (6,'False','DFB Pokal','Alemanha',0,0,0,0,0),
 (7,'False','Supercopa da Alemanha','Alemanha',0,0,0,0,0),
 (8,'False','Supercopa Intern. Argentina','Argentina',0,0,0,0,0),
 (9,'False','Campeonato Argentino','Argentina',0,0,0,0,0),
 (10,'False','Copa Argentina','Argentina',0,0,0,0,0),
 (11,'False','Copa do Brasil','Brasil',2,0,0,0,0),
 (12,'False','Estaduais','Brasil',0,0,0,0,0),
 (13,'False','La Liga','Espanha',0,0,0,0,0),
 (14,'False','La Liga 2','Espanha',0,0,0,0,0),
 (15,'False','Copa do Rei','Espanha',0,0,0,0,0),
 (16,'False','Supercopa da Espanha','Espanha',0,0,0,0,0),
 (17,'False','MLS','Estados Unidos',0,0,0,0,0),
 (18,'False','Ligue 1','França',0,0,0,0,0),
 (19,'False','Ligue 2','França',0,0,0,0,0),
 (20,'False','Copa da França','França',0,0,0,0,0),
 (21,'False','Supercopa da França','França',0,0,0,0,0),
 (22,'False','Eredivisie','Holanda',0,0,0,0,0),
 (23,'False','Premier League','Inglaterra',0,0,0,0,0),
 (24,'False','Championship','Inglaterra',0,0,0,0,0),
 (25,'False','FA Cup','Inglaterra',0,0,0,0,0),
 (26,'False','Copa da Liga','Inglaterra',0,0,0,0,0),
 (27,'False','Serie A','Itália',0,0,0,0,0),
 (28,'False','Copa da Itália','Itália',0,0,0,0,0),
 (29,'False','Supercopa da Itália','Itália',0,0,0,0,0),
 (30,'False','Primeira Liga','Portugal',0,0,0,0,0),
 (31,'False','Copa de Portugal','Portugal',0,0,0,0,0),
 (32,'False','Eliteserien','Noruega',0,0,0,0,0),
 (33,'False','Allsvenskan','Suécia',0,0,0,0,0),
 (34,'False','Super Lig','Turquia',0,0,0,0,0),
 (35,'False','Copa Sulamericana','América do Sul',0,0,0,0,0),
 (36,'False','Copa Libertadores','América do Sul',0,0,0,0,0),
 (37,'False','Recopa','América do Sul',0,0,0,0,0),
 (38,'False','Eliminatórias América Do Sul','América do Sul',0,0,0,0,0),
 (39,'False','Copa América','América do Sul',0,0,0,0,0),
 (40,'False','Champions League','Europa',0,0,0,0,0),
 (41,'False','Europa League','Europa',0,0,0,0,0),
 (42,'False','Nations','Internacional',0,0,0,0,0),
 (43,'False','Eliminatórias Europa','Europa',0,0,0,0,0),
 (44,'False','Mundial Interclubes','Internacional',0,0,0,0,0),
 (45,'False','Copa do Mundo','Internacional',0,0,0,0,0),
 (46,'False','Copa das Confederações','Internacional',0,0,0,0,0),
 (47,'False','Amistosos','Internacional',0,0,0,0,0),
 (48,'False','AFC Champions League','Ásia',0,0,0,0,0),
 (49,'False','Arábia Saudita','Ásia',0,0,0,0,0),
 (50,'False','Bahrein','Ásia',0,0,0,0,0),
 (51,'False','Emirados Árabes','Ásia',0,0,0,0,0),
 (52,'False','Irã','Ásia',0,0,0,0,0),
 (53,'False','Iraque','Ásia',0,0,0,0,0),
 (54,'False','Kuwait','Ásia',0,0,0,0,0),
 (55,'False','Catar','Ásia',0,0,0,0,0),
 (56,'False','China','Ásia',0,0,0,0,0),
 (57,'False','K League','Coreia do Sul',0,0,0,0,0),
 (58,'False','J League','Japão',0,0,0,0,0),
 (59,'False','Indonésia','Ásia',0,0,0,0,0),
 (60,'False','Tailândia','Ásia',0,0,0,0,0),
 (61,'False','Australiano','Austrália',0,0,0,0,0),
 (62,'False','Tajiquistão','Ásia',0,0,0,0,0),
 (63,'False','Bielorussia','Europa',0,0,0,0,0),
 (64,'False','Austriaco','Áustria',0,0,0,0,0),
 (65,'False','Suiço','Suíça',0,0,0,0,0),
 (66,'False','Dinamarques','Dinamarca',0,0,0,0,0),
 (67,'False','Islandês','Islândia',0,0,0,0,0),
 (73,0,'Liga Europa','Europa',0,0,0,0,0),
 (74,0,'Liga dos Campeões','Europa',0,0,0,0,0),
 (75,0,'Liga Portugal','Portugal',0,0,0,0,0),
 (76,0,'Itália - Série A','Itália',0,0,0,0,0),
 (77,0,'Catarinense Série B','Brasil',0,0,0,0,0);
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
 (161,'- 0,5 Gols',16),
 (162,'Europeu +4',4),
 (163,'+ 0,5 Gols Casa',15),
 (164,'+ 0,5 Gols Fora',15),
 (165,'+ 2,5 Cartões Casa',19),
 (166,'+ 2,5 Cartões Fora',19),
 (167,'Ambas Marcam',15),
 (168,'+ 3,5 Cantos Casa',17),
 (169,'+ 3,5 Cantos Fora',17),
 (170,'Casa Qualificar-se',1),
 (171,'Fora Qualificar-se',1),
 (172,'+ 3,5 Cantos 1° Tempo',17),
 (174,'Mais Cantos Casa',17),
 (175,'Mais Cantos Fora',17),
 (178,'- 2,5 Gols Casa',16),
 (179,'- 2,5 Gols Fora',16);
 INSERT INTO ConfigPrograma DEFAULT VALUES;
 
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
				AND Mercados.Status = 'Meio Red')
	AND NOT EXISTS (SELECT 1 FROM Mercados 
			    WHERE Cod_Aposta = NEW.Cod_Aposta 
				AND Mercados.Status = 'Red');
				
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
CREATE TRIGGER "Cashout" 
AFTER UPDATE ON Apostas 
FOR EACH ROW 
BEGIN 
  UPDATE Apostas 
  SET Lucro = Retorno - Valor_Aposta 
  WHERE Cod_Aposta = NEW.Cod_Aposta 
  AND Cashout = 1;
END;
