#!/bin/sh
# Install script to the BSD Zsh config

_D_zsh_confdir="$HOME/.config/zsh.d"
_D_builddir=$(pwd)
mkdir build

# Small functions
msg() {
	echo ">>> $@"
}

patching() {
	for _patch in $(ls ../../patches/"$1"/); do
		patch -Np1 -i ../../patches/"$1"/"$_patch"
	done
}

cleaning() {
	msg "Clean build directory..."
	rm -rf build
}

# manjaro-zsh-config
# https://gitlab.manjaro.org/packages/community/manjaro-zsh-config/-/blob/master/PKGBUILD
# https://github.com/Chrysostomus/manjaro-zsh-config
build_mzc() {
	msg "Build manjaro-zsh-config..."
	cd build
	git clone https://github.com/Chrysostomus/manjaro-zsh-config
	cd manjaro-zsh-config
	patching manjaro-zsh-config
	install -d ${_D_zsh_confdir}
	install -m644 .zshrc  "${HOME}/.zshrc"
	install -m644 manjaro-zsh-config "${_D_zsh_confdir}/manjaro-zsh-config"
	install -m644 manjaro-zsh-prompt "${_D_zsh_confdir}/manjaro-zsh-prompt"
	install -m644 p10k.zsh "${_D_zsh_confdir}/p10k.zsh"
	install -m644 p10k-portable.zsh "${_D_zsh_confdir}/p10k-portable.zsh"
	install -m644 command-not-found.zsh "${_D_zsh_confdir}/command-not-found.zsh"
	msg "...manjaro-zsh-config done." && cd $_D_builddir
}

# zsh-history-substring-search
# https://github.com/zsh-users/zsh-history-substring-search
build_hss() {
	msg "Build history-substring-search..."
	cd build
	git clone https://github.com/zsh-users/zsh-history-substring-search
	cd zsh-history-substring-search
	install -m644 zsh-history-substring-search.zsh "${_D_zsh_confdir}/zsh-history-substring-search.zsh"
	msg "...history-substring-search done." && cd $_D_builddir
}

# zsh-theme-powerlevel10k
# https://github.com/romkatv/powerlevel10k
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=zsh-theme-powerlevel10k-git
build_p10k() {
	msg "Build powerlevel10k theme..."
	cd build
	git clone https://github.com/romkatv/powerlevel10k
	cd powerlevel10k/gitstatus
	sed -i '' '/gitstatus_cxx=clang++12/d' build
	./build -w
	# go to ./build/powerlevel10k
	cd ..
	rm -rf  .git
	rm -rf gitstatus/src
	rm -rf gitstatus/deps
	rm -rf gitstatus/.vscode
	install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/config
	install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/internal
	install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/gitstatus/usrbin
	install -d ${_D_zsh_confdir}/zsh-theme-powerlevel10k/gitstatus/docs
	find . -type f -exec install '{}' "${_D_zsh_confdir}/zsh-theme-powerlevel10k/{}" ';'
	make -C ${_D_zsh_confdir}/zsh-theme-powerlevel10k minify
	cd ${_D_zsh_confdir}/zsh-theme-powerlevel10k
	for file in *.zsh-theme internal/*.zsh gitstatus/*.zsh gitstatus/install; do
		zsh -fc "emulate zsh -o no_aliases && zcompile -R -- $file.zwc $file"
	done
	msg "...powerlevel10k theme done." && cd $_D_builddir
}

# Work
msg "Start build Dragonfly zsh config:"
build_mzc
build_hss
build_p10k
if [ "$1" != "-d" ]; then
	cleaning
	msg "Ready."
else
	msg "Finished without cleaning."
fi

exit 0
