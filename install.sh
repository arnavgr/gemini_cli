#!/bin/bash
# =============================================================================
#  install.sh — installer for gemini CLI
#  Usage:
#    bash install.sh                      # install to /usr/local/bin
#    bash install.sh --prefix ~/.local    # install to ~/.local/bin
#    bash install.sh --uninstall          # remove it
# =============================================================================

REPO="arnavgr/gemini_cli"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main/gemini"
BINARY_NAME="gemini"
DEFAULT_PREFIX="/usr/local"
PREFIX="$DEFAULT_PREFIX"
UNINSTALL=false

# Colors (no tput dependency — use raw ANSI for the installer itself)
R='\033[0m'; BOLD='\033[1m'; OK='\033[0;32m'; ERR='\033[0;31m'; INFO='\033[0;36m'; WARN='\033[0;33m'

print_ok()   { printf "${OK}✓${R} %s\n" "$1"; }
print_err()  { printf "${ERR}✗${R} %s\n" "$1"; }
print_info() { printf "${INFO}→${R} %s\n" "$1"; }
print_warn() { printf "${WARN}!${R} %s\n" "$1"; }

# --- Parse args --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)   PREFIX="$2"; shift 2 ;;
        --uninstall) UNINSTALL=true; shift ;;
        --help)
            echo "Usage: bash install.sh [--prefix DIR] [--uninstall]"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

INSTALL_DIR="${PREFIX}/bin"
INSTALL_PATH="${INSTALL_DIR}/${BINARY_NAME}"

# =============================================================================
#  UNINSTALL
# =============================================================================
if [ "$UNINSTALL" = true ]; then
    if [ -f "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH"
        print_ok "Removed $INSTALL_PATH"
    else
        print_warn "$INSTALL_PATH not found, nothing to remove."
    fi
    exit 0
fi

# =============================================================================
#  INSTALL
# =============================================================================
echo ""
echo "${BOLD}gemini CLI installer${R}"
echo "────────────────────"
echo ""

# --- Dependency check --------------------------------------------------------
print_info "Checking dependencies…"
missing=()
for cmd in curl jq sed awk; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
done

if [ ${#missing[@]} -gt 0 ]; then
    print_err "Missing required tools: ${missing[*]}"
    echo ""
    if command -v apt &>/dev/null; then
        echo "  Run: sudo apt install ${missing[*]}"
    elif command -v dnf &>/dev/null; then
        echo "  Run: sudo dnf install ${missing[*]}"
    elif command -v pacman &>/dev/null; then
        echo "  Run: sudo pacman -S ${missing[*]}"
    elif command -v brew &>/dev/null; then
        echo "  Run: brew install ${missing[*]}"
    fi
    echo ""
    exit 1
fi
print_ok "All dependencies found."

# --- Create install dir if needed --------------------------------------------
if [ ! -d "$INSTALL_DIR" ]; then
    print_info "Creating $INSTALL_DIR…"
    mkdir -p "$INSTALL_DIR" 2>/dev/null || {
        print_info "Need sudo to create $INSTALL_DIR"
        sudo mkdir -p "$INSTALL_DIR"
    }
fi

# --- Check if we can write to install dir ------------------------------------
USE_SUDO=false
if [ ! -w "$INSTALL_DIR" ]; then
    print_warn "$INSTALL_DIR is not writable — will use sudo."
    USE_SUDO=true
    if ! sudo -v 2>/dev/null; then
        print_err "sudo access required but not available."
        exit 1
    fi
fi

# --- Download ----------------------------------------------------------------
print_info "Downloading from ${REPO}…"
TMP=$(mktemp)

HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TMP" "$RAW_URL")
if [ "$HTTP_CODE" != "200" ]; then
    print_err "Download failed (HTTP $HTTP_CODE)."
    print_warn "Is the repo public? Check REPO= in install.sh."
    rm -f "$TMP"
    exit 1
fi

VERSION=$(grep '^VERSION=' "$TMP" | head -n1 | cut -d'"' -f2)
print_ok "Downloaded gemini v${VERSION}."

# --- Install -----------------------------------------------------------------
chmod +x "$TMP"
if [ "$USE_SUDO" = true ]; then
    sudo mv "$TMP" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
else
    mv "$TMP" "$INSTALL_PATH"
    chmod +x "$INSTALL_PATH"
fi

print_ok "Installed to $INSTALL_PATH"

# --- PATH check --------------------------------------------------------------
echo ""
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    print_warn "$INSTALL_DIR is not in your \$PATH."
    echo ""
    echo "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "    ${BOLD}export PATH=\"\$PATH:${INSTALL_DIR}\"${R}"
    echo ""
else
    print_ok "$INSTALL_DIR is in your \$PATH."
fi

# --- Done --------------------------------------------------------------------
echo ""
echo "${BOLD}All done!${R} Run ${INFO}gemini --help${R} to get started."
echo ""
echo "  On first run you'll be prompted for your Gemini API key."
echo "  Get one free at: ${INFO}https://aistudio.google.com/app/apikey${R}"
echo ""
