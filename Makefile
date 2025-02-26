FPC_VERSION = 3.2.0
LCL_VERSION = 3.0
CPU_TARGET = x86_64-linux
INSTALL_DIR_BIN = /usr/local/bin
INSTALL_DIR_SHARE = /usr/share/GraxaimBanca
FILES = datafiles/criarbd.sql \
        datafiles/localizarbd.sql \
        graxaimbanca.png
PROJECT_FILE = GraxaimBanca.lpr
LAZARUS_DIR = /tmp/lazarus
LAZARUS_REPO = https://gitlab.com/freepascal.org/lazarus/lazarus.git
LAZARUS_BIN = $(LAZARUS_DIR)/lazbuild
TARGET = GraxaimBanca

all: install-deps install

install-lazarus:
	@echo "Baixando o Lazarus..."
	@if [ ! -d "$(LAZARUS_DIR)" ]; then \
		git clone --branch lazarus_3_4 $(LAZARUS_REPO) $(LAZARUS_DIR); \
	fi
	@echo "Compilando o Lazarus..."
	@cd $(LAZARUS_DIR) && \
	make clean && \
	make

build-program:
	@echo "Compilando o programa com o Lazarus local..."
	$(LAZARUS_BIN) --verbose --lazarusdir=$(LAZARUS_DIR) $(PROJECT_FILE)

clean:
	@echo "Limpando arquivos temporários..."
	rm -f $(TARGET) *.ppu *.o
	rm -rf $(LAZARUS_DIR)

install-deps:
	@echo "Detectando distribuição e instalando dependências..."
	@if [ -f /etc/debian_version ]; then \
		DISTRO="debian"; \
	elif [ -f /etc/redhat-release ]; then \
		DISTRO="redhat"; \
	elif [ -f /etc/arch-release ]; then \
		DISTRO="arch"; \
	elif [ -f /etc/os-release ] && grep -q "openSUSE" /etc/os-release; then \
		DISTRO="opensuse"; \
	else \
		echo "Distribuição não suportada"; \
		exit 1; \
	fi; \
	\
	case $$DISTRO in \
		debian) \
			echo "Instalando dependências para Debian/Ubuntu"; \
			sudo apt update; \
			sudo apt install -y \
				fpc \
				git \
				libgtk2.0-dev \
				libx11-dev \
				libgdk-pixbuf2.0-dev \
				libglib2.0-dev \
				libpango1.0-dev \
				libcairo2-dev \
				libatk1.0-dev \
				libc6-dev \
				libsqlite3-dev; \
			;; \
		redhat) \
			echo "Instalando dependências para Red Hat/CentOS/Fedora"; \
			sudo yum install -y \
				fpc \
				git \
				gtk2-devel \
				libX11-devel \
				gdk-pixbuf2-devel \
				glib2-devel \
				pango-devel \
				cairo-devel \
				atk-devel \
				glibc-devel \
				sqlite-devel; \
			;; \
		arch) \
			echo "Instalando dependências para Arch Linux"; \
			sudo pacman -Syu --noconfirm \
				fpc \
				git \
				gtk2 \
				libx11 \
				gdk-pixbuf2 \
				glib2 \
				pango \
				cairo \
				atk \
				glibc \
				sqlite; \
			;; \
		opensuse) \
			echo "Instalando dependências para openSUSE"; \
			sudo zypper refresh; \
			sudo zypper install -y \
				fpc \
				git \
				gtk2 \
				libX11-6 \
				gdk_pixbuf-2_0-0 \
				libglib-2_0-0 \
				pango \
				cairo \
				atk \
				glibc \
				sqlite3-devel \
				sqlite3; \
			;; \
		*) \
			echo "Distribuição não suportada"; \
			exit 1; \
			;; \
	esac

install: build-program
	@echo "Instalando $(TARGET) em $(INSTALL_DIR_BIN)"
	sudo cp $(TARGET) $(INSTALL_DIR_BIN)
	sudo chmod 755 $(INSTALL_DIR_BIN)/$(TARGET)
	@echo "$(TARGET) instalado em $(INSTALL_DIR_BIN)"
	@echo "Criando diretório e copiando arquivos para $(INSTALL_DIR_SHARE)"
	sudo mkdir -p $(INSTALL_DIR_SHARE)
	for file in $(FILES); do \
		sudo cp $$file $(INSTALL_DIR_SHARE); \
	done
	cp Graxaim\ Gestão\ de\ Banca.desktop $(INSTALL_DIR_SHARE)
	sudo chmod 644 $(INSTALL_DIR_SHARE)/*
	@echo "Arquivos instalados em $(INSTALL_DIR_SHARE)"

uninstall:
	@echo "Desinstalando $(TARGET) e arquivos associados"
	sudo rm -f $(INSTALL_DIR_BIN)/$(TARGET)
	sudo rm -rf $(INSTALL_DIR_SHARE)
