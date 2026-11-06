# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker wrapper xdg

MY_PN="RemoteDesktopManager"

DESCRIPTION="Devolutions Remote Desktop Manager - centralized remote connection manager"
HOMEPAGE="https://devolutions.net/remote-desktop-manager/"
SRC_URI="
	amd64? ( https://cdn.devolutions.net/download/Linux/RDM/${PV}/${MY_PN}_${PV}_amd64.deb )
	arm64? ( https://cdn.devolutions.net/download/Linux/RDM/${PV}/${MY_PN}_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

# Self-contained .NET app + GTK3/WebKitGTK/VTE front end.
# After installing, run `lddtree -a /opt/devolutions/RemoteDesktopManager/*`
# (app-misc/pax-utils) to catch anything missing on your system.
RDEPEND="
	app-crypt/libsecret
	dev-libs/glib:2
	dev-libs/icu:=
	dev-libs/openssl:=
	media-libs/fontconfig
	media-libs/freetype
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-libs/zlib
	virtual/krb5
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/pango
	x11-libs/vte:2.91
"

QA_PREBUILT="opt/devolutions/*"

RDM_DIR="/opt/devolutions/${MY_PN}"

src_prepare() {
	default

	# Upstream installs to /usr/lib/devolutions; relocate to /opt so
	# 64-bit prebuilt ELFs don't land in /usr/lib (multilib-strict QA).
	if [[ -d usr/lib/devolutions ]]; then
		mkdir -p opt || die
		mv usr/lib/devolutions opt/ || die
		rmdir usr/lib 2>/dev/null
	fi
	[[ -d opt/devolutions/${MY_PN} ]] || die "Unexpected .deb layout: ${MY_PN} dir not found"

	# Fix launchers in /usr/bin (symlinks or shell scripts)
	local f tgt
	if [[ -d usr/bin ]]; then
		for f in usr/bin/*; do
			if [[ -L ${f} ]]; then
				tgt=$(readlink "${f}") || die
				if [[ ${tgt} == *lib/devolutions/* ]]; then
					ln -sfn "/opt/devolutions/${tgt#*lib/devolutions/}" "${f}" || die
				fi
			elif [[ -f ${f} ]]; then
				sed -i 's:/usr/lib/devolutions:/opt/devolutions:g' "${f}" || die
			fi
		done
	fi

	# Fix paths in .desktop files, MIME/icon metadata, etc.
	if [[ -d usr/share ]]; then
		grep -rlZ '/usr/lib/devolutions' usr/share 2>/dev/null \
			| xargs -0r sed -i 's:/usr/lib/devolutions:/opt/devolutions:g' || die
	fi

	# Debian packaging leftovers
	rm -rf usr/share/doc usr/share/lintian || die
}

src_install() {
	local d
	for d in opt usr etc; do
		[[ -d ${d} ]] && { cp -a "${d}" "${ED}"/ || die; }
	done

	# Fallback launcher if the .deb didn't ship one
	if [[ ! -e ${ED}/usr/bin/remotedesktopmanager ]]; then
		[[ -x ${ED}${RDM_DIR}/${MY_PN} ]] \
			|| die "No launcher found and ${RDM_DIR}/${MY_PN} is not executable"
		make_wrapper remotedesktopmanager "${RDM_DIR}/${MY_PN}" "${RDM_DIR}"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Remote Desktop Manager is proprietary software. Accept its license with:"
	elog "  echo '${CATEGORY}/${PN} all-rights-reserved' >> /etc/portage/package.license"
	elog
	elog "Launch it with: remotedesktopmanager"
}
