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

#### Windows: 

Navegar até os <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest"> lançamentos </a> e baixar o executável .EXE. 
> [!IMPORTANT]
> O Windows e o navegador podem detectar o instalador como potencial risco de segurança, mas não se preocupe, isso acontece porque este programa não tem certificado digital. Caso desconfie de algo, sinta-se a vontade para fazer uma verificação com antivírus.

#### Linux: 
- **Instalador:** Acesse os <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest"> lançamentos </a> e baixe a versão de acordo com sua distro:
  - **Debian, Ubuntu, Linux Mint, Pop!_OS e demais distros baseadas em Debian:** Baixar e executar o arquivo .DEB.
  - **Fedora, OpenSUSE, RedHat e demais distros baseadas em RedHat:** Baixar e executar o arquivo .RPM
  - **Manjaro e Arch Linux:** Infelizmente ainda não há opção pré-compilada, sendo necessário compilar o código-fonte o programa conforme será ensinado abaixo.
- **Compilação:** Recomendável que tenha git instalado.
  - Baseados em Debian:
    ```
    sudo apt install git
    ```
  - RedHat:
    ```
    sudo yum install git
    ```
  - Manjaro e Arch Linux:
    ```
    sudo pacman -S git
    ```
  - OpenSUSE:
    ```
    sudo zypper install git
    ```
> [!NOTE]
> Caso baixe o código-fonte sem usar o git, o próprio makefile fará a instalação automaticamente, para o download temporário do compilador.
  
  Após a instalação do git, digite os seguintes comandos no terminal:
  ```
  git clone https://github.com/FeroxGraxaim/graxaimgestaodebanca.git
  cd graxaimgestaodebanca
  make
  make install
  ```
  Isso deverá instalar o programa. Caso ocorra algum problema, <a href="https://github.com/FeroxGraxaim/graxaimgestaodebanca/issues"> favor relatar. </a> 
    
