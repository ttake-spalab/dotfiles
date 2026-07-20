#!/usr/bin/env bash
#
# install.sh
#
# Bootstrap script for a Nix + Home Manager dotfiles repository.
#
# Responsibilities:
#   1. Install Nix (if necessary)
#   2. Clone/update the dotfiles repository
#   3. Persist the selected role
#   4. Apply the flake configuration
#
# All configuration logic belongs to flake.nix.
#

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/<YOUR_USERNAME>/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

ROLE_DIR="${HOME}/.config/dotfiles"
ROLE_FILE="${ROLE_DIR}/role"

NIX_INSTALLER="https://install.determinate.systems/nix"

FORCE_UPDATE=false

###############################################################################
# Logging
###############################################################################
log() {
    printf "\033[1;34m==>\033[0m %s\n" "$*"
}

warn() {
    printf "\033[1;33mWarning:\033[0m %s\n" "$*" >&2
}

die() {
    printf "\033[1;31mError:\033[0m %s\n" "$*" >&2
    exit 1
}

###############################################################################
# Usage
###############################################################################
usage() {
cat <<EOF
Usage:
    install.sh [ROLE]
or
    install.sh --role ROLE

Options:
    --role ROLE
        Save or change the current role.
    --force
        Force reset the local repository before applying.
    -h, --help
        Show this help.

Examples:
    ./install.sh workstation
    ./install.sh laptop
    ./install.sh

Environment Variables:
    DOTFILES_REPO
        Repository URL.
    DOTFILES_DIR
        Clone destination.

EOF
}

###############################################################################
# Parse arguments
###############################################################################
ROLE=""
while [[ $# -gt 0 ]]; do
    case "$1" in

        --role)
            [[ $# -ge 2 ]] || die "--role requires an argument."
            ROLE="$2"
            shift 2
            ;;

        --force)
            FORCE_UPDATE=true
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        -*)
            die "Unknown option: $1"
            ;;

        *)
            ROLE="$1"
            shift
            ;;

    esac
done

###############################################################################
# Dependency checks
###############################################################################
require_command() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' is required."
}

check_dependencies() {
    require_command curl
    require_command git
}

###############################################################################
# Role
###############################################################################
load_role() {
    mkdir -p "$ROLE_DIR"
    if [[ -n "$ROLE" ]]; then
        printf "%s\n" "$ROLE" > "$ROLE_FILE"
        log "Saved role: $ROLE"
        return
    fi

    if [[ -f "$ROLE_FILE" ]]; then
        ROLE="$(<"$ROLE_FILE")"
        log "Using saved role: $ROLE"
        return
    fi

    cat <<EOF
No role has been configured.
First-time setup:
    ./install.sh workstation

Available examples:
    workstation
    laptop
    server
    minimal

EOF
    exit 1
}

###############################################################################
# Install Nix
###############################################################################
install_nix() {
    if command -v nix >/dev/null 2>&1; then
        log "Nix already installed."
        return
    fi

    log "Installing Nix..."
    sh <(curl -fsSL "$NIX_INSTALLER")

    for profile in \
        "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" \
        "${HOME}/.nix-profile/etc/profile.d/nix.sh"
    do
        if [[ -f "$profile" ]]; then
            # shellcheck disable=SC1090
            source "$profile"
            break
        fi
    done

    if ! command -v nix >/dev/null 2>&1; then
        die "Nix installed successfully, but is not available in the current shell.
Please open a new terminal and run install.sh again."
    fi
}

###############################################################################
# Configure Nix
###############################################################################
configure_nix() {
    mkdir -p "${HOME}/.config/nix"
    local conf="${HOME}/.config/nix/nix.conf"
    touch "$conf"
    if ! grep -q '^experimental-features' "$conf"; then
        echo "experimental-features = nix-command flakes" >> "$conf"
    fi
}

###############################################################################
# Dotfiles
###############################################################################
clone_or_update_dotfiles() {
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        log "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        return
    fi

    if "$FORCE_UPDATE"; then
        log "Force updating repository..."
        git -C "$DOTFILES_DIR" fetch origin
        git -C "$DOTFILES_DIR" reset --hard origin/HEAD
    else
        log "Updating repository..."
        git -C "$DOTFILES_DIR" pull --ff-only
    fi
}

###############################################################################
# Apply flake
###############################################################################
apply_configuration() {
    local host
    host="$(hostname -s 2>/dev/null || hostname)"

    log "Applying configuration"
    log "Host : ${host}"
    log "Role : ${ROLE}"

    #
    # The flake is responsible for mapping:
    #
    # host
    # role
    # common
    #
    # into the final Home Manager configuration.
    #
    nix run github:nix-community/home-manager -- switch \
        --flake "${DOTFILES_DIR}#${host}" \
        --impure \
        --argstr role "${ROLE}"
}

###############################################################################
# Main
###############################################################################
main() {
    check_dependencies
    load_role
    install_nix
    configure_nix
    clone_or_update_dotfiles
    apply_configuration
    log "Bootstrap completed successfully."
}

main "$@"
