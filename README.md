# Graxaim Gestão de Banca
Sistema de gestão de banca para apostas esportivas.

## Introdução
Este programa tem o intuito de substituir o uso de planilhas de gestão de banca por um sistema de gestão intuitivo e simples de usar, tanto para apostadores iniciantes quanto para os profissionais. 
*Atenção:* o programa está no início de seu desenvolvimento, e ainda não está em condições de uso para a sua finalidade. Aos curiosos que quiserem testar o projeto em seu estado atual, sintam-se livres para fazer suas sugestões e críticas.

### Recursos utilizáveis: 
- Inserção de registros de novas apostas, com data, time mandante, time visitante, estratégia, unidade, etc.
- Determinação do valor inicial da banca.
### Recursos em desenvolvimento: 
- Edição de registros no banco de dados;
- Filtragem das apostas;
- Gráficos de controle do lucro;
- Inserção e remoção de times, campeonatos e estratégias.
### Recursos que serão implementados no futuro:
- Inserção de países no banco de dados, com controle de perda e ganho total de cada país registrado;
- Possibilidade de salvar o banco de dados na nuvem, pensando num futuro desenvolvimento de sistema para aparelhos móveis;
- Demais recursos que forem sugeridos.

## Como instalar o programa:

### Windows: 

Navegar até os <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest"> lançamentos </a> e baixar o executável .EXE. 
> [!IMPORTANT]
> O Windows e o navegador podem detectar o instalador como potencial risco de segurança, mas não se preocupe, isso acontece porque este programa não tem certificado digital. Caso desconfie de algo, sinta-se a vontade para fazer uma verificação com antivírus.

### Linux:

#### Instalação Simples (pacote)
Acesse os <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest"> lançamentos </a> e baixe a versão de acordo com sua distro:
- Debian, Ubuntu, Linux Mint, Pop!_OS e derivados: baixar e executar o arquivo **DEB.**
- Fedora, OpenSUSE, RedHat e derivados: baixar e executar o arquivo **RPM.**
- Manjaro e Arch Linux: Baixe e execute o arquivo **.SH**, certifique-se de que esteja com permissões para ser executado nas propriedades do arquivo.

#### Instalação Manual (Compilação)    
Instale o git para fazer o clone do repositório, e instale o make para fazer a compilação.

- Debian, Ubuntu, Linux Mint, Pop!_OS e derivados:
   ```
  sudo apt install git
  sudo apt install make
  ```
- RedHat:
  ```
  sudo yum install git
  sudo yum install make
  ```
- Fedora:
  ```
  sudo dnf install git
  sudo dnf install make
  ```
- Manjaro e Arch Linux:
  ```
  sudo pacman -Sy git
  sudo pacman -Sy make
  ```
- OpenSUSE:
  ```
  sudo zypper install git
  sudo zypper install make
  ```
- Distribuições não listadas: instalar as seguintes dependências manualmente (os nomes dos pacotes podem variar um pouco):
  `fpc, git, gtk2, libX11-6, gdk-pixbuf2, glib2, pango, cairo, atk, glibc, sqlite3, sqlite3-devel`

Após a instalação do git e do make, digite os seguintes comandos no terminal:
```
git clone https://github.com/FeroxGraxaim/graxaimgestaodebanca.git
cd graxaimgestaodebanca
make all
```
> [!NOTE]
> Caso baixe o código-fonte sem usar o git, o próprio makefile fará a instalação automaticamente, para o download temporário do compilador.

  Isso deverá instalar o programa. Caso ocorra algum problema, <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/issues"> favor relatar. </a> 
    
