# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit python-r1 unpacker

DESCRIPTION="Proton AG VPN Core API"
HOMEPAGE="https://github.com/ProtonVPN/python-proton-vpn-api-core"

# Official prebuilt package straight from Proton's own apt repo: the Rust
# extension (proton/vpn/platform.abi3.so) links a private Cargo registry
# and a private git submodule (dependencies/protun), so it cannot be built
# from the public GitHub source tree.
SRC_URI="https://repo.protonvpn.com/debian/dists/stable/main/binary-amd64/python3-${PN}_${PV}_amd64.deb -> ${P}.deb"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/dbus-fast[${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/fido2[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/pynacl[${PYTHON_USEDEP}]
		dev-python/sentry-sdk[${PYTHON_USEDEP}]
		>=dev-python/proton-core-0.5.0[${PYTHON_USEDEP}]
	')
	net-libs/libmnl
	net-libs/libnftnl
	net-misc/networkmanager
	net-vpn/networkmanager-openvpn
"
BDEPEND=""

QA_PREBUILT="usr/lib/python*/site-packages/proton/vpn/platform.abi3.so"

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	python_foreach_impl python_domodule usr/lib/python3/dist-packages/proton
	python_foreach_impl python_domodule \
		"usr/lib/python3/dist-packages/proton_vpn_api_core-${PV}.egg-info"

	exeinto /usr/libexec
	doexe usr/libexec/nm-protun-auth-dialog
	doexe usr/libexec/nm-protun-service
	doexe usr/libexec/proton-vpn-kill-switch-service

	insinto /usr/lib/NetworkManager/VPN
	doins usr/lib/NetworkManager/VPN/nm-protun.name

	insinto /usr/share/dbus-1/system.d
	doins usr/share/dbus-1/system.d/me.proton.vpn.kill_switch.conf
	doins usr/share/dbus-1/system.d/nm-protun-service.conf

	insinto /usr/share/dbus-1/system-services
	doins usr/share/dbus-1/system-services/me.proton.vpn.kill_switch.service
}
