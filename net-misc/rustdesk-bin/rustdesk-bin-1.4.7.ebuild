# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="The Fast Open-Source Remote Access and Support Software"
HOMEPAGE="https://rustdesk.com"
SRC_URI="https://github.com/rustdesk/rustdesk/releases/download/${PV}/rustdesk-${PV}-x86_64.deb"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-libs/alsa-lib
	media-libs/gst-plugins-base
	media-libs/libva
	sys-libs/pam
	x11-libs/gtk+:3
	x11-libs/libxcb
	x11-libs/libXfixes
	x11-misc/xdotool"

RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	insinto /opt/"${PN}"
	doins -r usr/.

	fperms -R +x /opt/"${PN}"/share/rustdesk/rustdesk

	dosym /opt/"${PN}"/share/rustdesk/rustdesk /usr/bin/rustdesk-bin
	domenu /opt/"${PN}"/share/rustdesk/files/rustdesk.desktop

	dosym /opt/"${PN}"/share/icons/hicolor/256x256/apps/rustdesk.png /usr/share/pixmaps/rustdesk.png
	newicon -s 256 /opt/"${PN}"/share/icons/hicolor/256x256/apps/rustdesk.png rustdesk.png
}
