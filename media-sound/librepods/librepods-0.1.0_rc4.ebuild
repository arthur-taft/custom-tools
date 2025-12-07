# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

CORRECTED_PV="${PV/_rc/-rc.}"

DESCRIPTION="AirPods Liberated from Apple's Ecosystem"
HOMEPAGE="https://github.com/kavishdevar/librepods"
SRC_URI="https://github.com/kavishdevar/${PN}/archive/refs/tags/v${CORRECTED_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-build/cmake
	dev-libs/openssl
	dev-qt/qtbase:6
	dev-qt/qtconnectivity:6[bluetooth]
	dev-qt/qtmultimedia:6[ffmpeg]
	media-libs/libpulse"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}-${CORRECTED_PV}/linux"

src_prepare() {
	sed -i 's/applinux/librepods/g' CMakeLists.txt || die "failed to rename binary"

	cmake_src_prepare
}
