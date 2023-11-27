#!/bin/sh
# Install script to Fluxbox-mod

_D_os=$(uname -s)
_D_zsh_confdir="$HOME/.config/zsh.d"
_D_basedir=$(pwd)
_D_patchdir="${_D_basedir}/zsh/patches"
_D_OpenBSD_deps="linuxlibertine-fonts-ttf feh zsh breeze-icons rofi fluxbox \
                 zsh-syntax-highlighting noto-nerd-fonts cmake gmake wget binutils"
_D_FreeBSD_deps="zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
                 nerd-fonts cmake gmake wget binutils perl5 linuxlibertine feh \
                 kf5-breeze-icons rofi fluxbox"
_D_NetBSD_deps="linux-libertine-ttf feh zsh zsh-autosuggestions zsh-syntax-highlighting \
                zsh-completions breeze-icons rofi fluxbox nerd-fonts-Meslo cmake gmake \
                wget binutils perl"
mkdir extrenal

# Small functions
msg() {
    echo ">>> $@"
}

patching() {
    for _patch in $(ls "$_D_patchdir"/"$1"/); do
        patch -Np1 -i "$_D_patchdir"/"$1"/"$_patch" || return 1
    done
    if [ "$_D_os" = "OpenBSD" ]; then
        for _patcho in $(ls "$_D_patchdir"/openbsd/"$1"/); do
            patch -Np1 -i "$_D_patchdir"/openbsd/"$1"/"$_patcho" || return 1
        done
    fi
    return 0
}

cleaning() {
    msg "Clean build directory..."
    rm -rf build
}

# Install dependencies from binary repository
install_deps() {
    if [ "$_D_os" = "OpenBSD" ]; then
        doas pkg_add $_D_OpenBSD_deps || return 1
    elif [ "$_D_os" = "FreeBSD" ] || [ "$_D_os" = "DragonFly" ]; then
        sudo pkg install $_D_FreeBSD_deps || return 1
    fi
    return 0
}

# manjaro-zsh-config
# https://gitlab.manjaro.org/packages/community/manjaro-zsh-config/-/blob/master/PKGBUILD
# https://github.com/Chrysostomus/manjaro-zsh-config
# DEPS: zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
#       zsh-completions ttf-meslo-nerd-font-powerlevel10k zsh-theme-powerlevel10k
# BUILD ON: OpenBSD, FreeBSD, DragonFly, NetBSD
build_mzc() {
    msg "Build manjaro-zsh-config..."
    cd extrenal
    git clone https://github.com/Chrysostomus/manjaro-zsh-config || return 1
    cd manjaro-zsh-config
    patching manjaro-zsh-config || return 1
    install -d ${_D_zsh_confdir} || return 1
    install -m644 .zshrc  "${HOME}/.zshrc" || return 1
    install -m644 manjaro-zsh-config "${_D_zsh_confdir}/manjaro-zsh-config" || return 1
    install -m644 manjaro-zsh-prompt "${_D_zsh_confdir}/manjaro-zsh-prompt" || return 1
    install -m644 p10k.zsh "${_D_zsh_confdir}/p10k.zsh" || return 1
    install -m644 p10k-portable.zsh "${_D_zsh_confdir}/p10k-portable.zsh" || return 1
    msg "...manjaro-zsh-config done." && cd $_D_basedir
    return 0
}

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
# BUILD ON: OpenBSD
build_zas() {
    msg "Build zsh-autosuggestions..."
    cd extrenal
    git clone https://github.com/zsh-users/zsh-autosuggestions || return 1
    cd zsh-autosuggestions
    install -m644 zsh-autosuggestions.zsh "${_D_zsh_confdir}/zsh-autosuggestions.zsh" || return 1
    msg "...zsh-autosuggestions done." && cd $_D_basedir
    return 0
}

# zsh-history-substring-search
# https://github.com/zsh-users/zsh-history-substring-search
# BUILD ON: OpenBSD, FreeBSD, DragonFly
build_zhss() {
    msg "Build zsh-history-substring-search..."
    cd extrenal
    git clone https://github.com/zsh-users/zsh-history-substring-search || return 1
    cd zsh-history-substring-search
    install -m644 zsh-history-substring-search.zsh "${_D_zsh_confdir}/zsh-history-substring-search.zsh" || return 1
    msg "...zsh-history-substring-search done." && cd $_D_basedir
    return 0
}

# zsh-completions
# https://github.com/zsh-users/zsh-completions
# https://gitlab.archlinux.org/archlinux/packaging/packages/zsh-completions/-/blob/main/PKGBUILD?ref_type=heads
# BUILD ON: OpenBSD
build_zc() {
    msg "Build zsh-completions..."
    cd extrenal
    git clone https://github.com/zsh-users/zsh-completions || return 1
    cd zsh-completions
    install -vDm 644 src/* -t "${_D_zsh_confdir}/zsh-completions/" || return 1
    msg "...zsh-completions done." && cd $_D_basedir
    return 0
}

# zsh-theme-powerlevel10k
# https://github.com/romkatv/powerlevel10k
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zsh-theme-powerlevel10k-git
# BUILD ON: OpenBSD, FreeBSD, DragonFly, NetBSD
build_p10k() {
    msg "Build powerlevel10k theme..."
    cd extrenal
    git clone https://github.com/romkatv/powerlevel10k || return 1
    cd powerlevel10k/gitstatus
    sed -i '' '/gitstatus_cxx=clang++12/d' build  || return 1
    ./build -w  || return 1
    # go to ./build/powerlevel10k
    cd ..
    rm -rf  .git
    rm -rf gitstatus/src  || return 1
    rm -rf gitstatus/deps  || return 1
    rm -rf gitstatus/.vscode  || return 1
    install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/config  || return 1
    install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/internal  || return 1
    install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/gitstatus/usrbin  || return 1
    install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/gitstatus/docs  || return 1
    find . -type f -exec install '{}' "${_D_zsh_confdir}/zsh-theme-powerlevel10k/{}" ';'  || return 1
    make -C ${_D_zsh_confdir}/zsh-theme-powerlevel10k minify  || return 1
    cd ${_D_zsh_confdir}/zsh-theme-powerlevel10k
    for file in *.zsh-theme internal/*.zsh gitstatus/*.zsh gitstatus/install; do
        zsh -fc "emulate zsh -o no_aliases && zcompile -R -- $file.zwc $file"  || return 1
    done
    msg "...powerlevel10k theme done." && cd $_D_basedir
    return 0
}

# Work
msg "Install dependencies:"
install_deps || exit 1
msg "Start build and install Fluxbox-mod:"
build_mzc || exit 1
build_zhss || exit 1
build_p10k || exit 1
if [ "$_D_os" = "OpenBSD" ]; then
    build_zc || exit 1
    build_zas || exit 1
fi

if [ "$1" != "-d" ]; then
    cleaning
    msg "Ready."
else
    msg "Finished without cleaning."
fi

exit 0
