# Copyright 2025 Gentoo Authors
# Copyright 2025 Arthur Taft
# Copyright 2021 RickdeJager
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Cryptography cracker and embedder"
HOMEPAGE="https://github.com/RickdeJager/stegseek"
SRC_URI="https://github.com/RickdeJager/stegseek/archive/refs/tags/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="app-crypt/mhash 
		dev-libs/libmcrypt 
		media-libs/libjpeg-turbo 
		sys-libs/zlib 
		dev-build/make 
		sys-devel/gcc 
		dev-build/cmake 
		dev-vcs/git"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	mkdir -p build && cd build
	cmake -DCMAKE_BUILD_TYPE=Release ..
}

src_compile() {
	cd build
	emake
}

src_install() {
	cd build
	emake DESTDIR="${D}" install
}