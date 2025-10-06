# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Wireguard GTK GUI for Linux"
HOMEPAGE="https://github.com/UnnoTed/wireguird"
SRC_URI="https://github.com/UnnoTed/wireguird/releases/download/v${PV}/${PN}_amd64.deb"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="gui-libs/gtk
		dev-libs/ayatana-ido
		dev-lang/go
		virtual/resolvconf
		net-dns/openresolv"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	insinto /opt/wireguird
	doins -r deb/usr/.

	domenu /opt/wireguird/share/applications/wireguird.desktop
	dosym /opt/wireguird/local/bin/wireguird /usr/bin/wireguird
	newicon -s 256 Icon/256x256/wireguard.png wireguird.png
}
