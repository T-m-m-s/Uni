#!/usr/bin/env bash
# ==============================================================================
# Ctl_Hub - Linux Host Installer
# Configura l'ambiente, la CLI ctlhub, le regole udev e l'eventuale demone systemd.
# ==============================================================================

set -e

# Colori terminale
BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

log_info()  { echo -e "${CYAN}[INFO]${RESET} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${RESET} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*"; }

# Determinazione cartella root del repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SCRIPT_DIR}/Host"
UDEV_RULE="${PACKAGE_DIR}/udev/99-ctlhub.rules"

echo -e "${BOLD}=== Installazione Ctl_Hub Linux Host ===${RESET}"
echo -e "Directory progetto: ${SCRIPT_DIR}\n"

# 1. Verifica Python 3
log_info "Verifica requisiti di sistema..."
if ! command -v python3 &>/dev/null; then
    log_error "Python 3 non trovato. Installa python3 tramite il package manager della tua distribuzione."
    exit 1
fi
log_ok "Python 3 presente: $(python3 --version)"

# 2. Verifica pipx
if ! command -v pipx &>/dev/null; then
    log_warn "Strumento 'pipx' non trovato."
    echo -e "Installazione consigliata di pipx:"
    if command -v pacman &>/dev/null; then
        echo -e "  sudo pacman -S python-pipx"
    elif command -v apt &>/dev/null; then
        echo -e "  sudo apt install pipx"
    elif command -v dnf &>/dev/null; then
        echo -e "  sudo dnf install pipx"
    else
        echo -e "  python3 -m pip install --user pipx"
    fi
    read -r -p "[?] Desideri procedere con l'installazione automatica di pipx? [S/n]: " install_pipx
    install_pipx="${install_pipx:-S}"
    if [[ "$install_pipx" =~ ^[SsYy]$ ]]; then
        if command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm python-pipx
        elif command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y pipx
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y pipx
        else
            python3 -m pip install --user pipx
        fi
    else
        log_error "Installazione interrotta. Installa pipx manualmente e riesegui ./install.sh."
        exit 1
    fi
fi
log_ok "pipx disponibile: $(pipx --version)"

# Assicura il PATH per ~/.local/bin
log_info "Configurazione PATH ~/.local/bin..."
pipx ensurepath >/dev/null 2>&1 || true

# 3. Installazione pacchetto ctlhub con pipx
log_info "Installazione del pacchetto ctlhub in modalità editabile..."
if [ -d "$PACKAGE_DIR" ]; then
    pipx install --editable "$PACKAGE_DIR" --force
    log_ok "Pacchetto ctlhub installato correttamente."
else
    log_error "Cartella pacchetto non trovata: $PACKAGE_DIR"
    exit 1
fi

# 4. Configurazione regole udev per symlink /dev/ctlhub e permessi seriali
echo
log_info "Configurazione permessi hardware e regole udev..."
if [ -f "$UDEV_RULE" ]; then
    echo -e "La copia delle regole udev in /etc/udev/rules.d richiede privilegi di amministratore (sudo):"
    sudo cp "$UDEV_RULE" /etc/udev/rules.d/99-ctlhub.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    log_ok "Regola /etc/udev/rules.d/99-ctlhub.rules installata e applicata."

    # Aggiunta dell'utente corrente ai gruppi dialout/uucp se non presenti
    USER_GROUPS=$(id -Gn "$USER")
    for grp in dialout uucp; do
        if getent group "$grp" >/dev/null 2>&1; then
            if [[ ! " $USER_GROUPS " =~ " $grp " ]]; then
                log_info "Aggiunta dell'utente '$USER' al gruppo '$grp'..."
                sudo usermod -aG "$grp" "$USER"
            fi
        fi
    done
else
    log_warn "File regole udev non trovato in $UDEV_RULE. Saltato."
fi

# 5. Domanda interattiva per servizio systemd in background all'avvio
echo
echo -e "${BOLD}--- Configurazione Avvio Automatico ---${RESET}"
read -r -p "[?] Vuoi eseguire Ctl_Hub come demone in background all'avvio del PC? [S/n]: " enable_daemon
enable_daemon="${enable_daemon:-S}"

SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/ctlhub.service"

if [[ "$enable_daemon" =~ ^[SsYy]$ ]]; then
    log_info "Configurazione del servizio utente systemd..."
    mkdir -p "$SERVICE_DIR"

    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Ctl_Hub ESP32 Stream Deck Host Daemon
After=graphical-session.target sound.target

[Service]
Type=simple
ExecStart=%h/.local/bin/ctlhub run
Restart=always
RestartSec=3
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now ctlhub.service
    log_ok "Servizio systemd 'ctlhub.service' abilitato e avviato."
    log_info "Comandi per la gestione del servizio:"
    echo -e "  - Arrestare:   ctlhub kill   (oppure: systemctl --user stop ctlhub)"
    echo -e "  - Avviare:     systemctl --user start ctlhub"
    echo -e "  - Log live:    journalctl --user -u ctlhub -f"
else
    log_info "Avvio automatico escluso. Puoi avviare il bridge quando vuoi con 'ctlhub run'."
    # Se il servizio era precedentemente attivo, lo disattiviamo
    if systemctl --user is-enabled ctlhub.service >/dev/null 2>&1; then
        systemctl --user disable --now ctlhub.service >/dev/null 2>&1 || true
        log_info "Precedente servizio systemd disattivato."
    fi
fi

# 6. Verifica connessione hardware attuale
echo
log_info "Verifica connessione con l'ESP32..."
if command -v ctlhub &>/dev/null; then
    ctlhub status || true
else
    "$HOME/.local/bin/ctlhub" status || true
fi

# 7. Riepilogo comandi
echo
echo -e "${BOLD}=== Installazione completata con successo ===${RESET}"
echo -e "Comandi principali disponibili da qualsiasi cartella:"
echo -e "  ${BOLD}ctlhub run${RESET}      - Avvia il bridge in primo piano"
echo -e "  ${BOLD}ctlhub kill${RESET}     - Arresta il bridge in background o il servizio systemd"
echo -e "  ${BOLD}ctlhub gui${RESET}      - Apre l'interfaccia grafica web di configurazione"
echo -e "  ${BOLD}ctlhub reinit${RESET}   - Re-inizializza lo schermo (in caso di falsi contatti)"
echo -e "  ${BOLD}ctlhub status${RESET}   - Mostra se il dispositivo e' connesso"
echo -e "  ${BOLD}ctlhub next${RESET}     - Passa al profilo successivo"
echo -e "  ${BOLD}ctlhub prev${RESET}     - Passa al profilo precedente"
echo -e "  ${BOLD}ctlhub switch${RESET}   - Cambia profilo attivo (es. ctlhub switch coding)"
echo
