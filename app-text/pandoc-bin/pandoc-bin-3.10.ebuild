# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream tarball/dir use the plain name; the package is -bin to avoid
# colliding with app-text/pandoc-cli and dev-haskell/pandoc.
MY_PN="${PN%-bin}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Universal document converter (prebuilt upstream binary release)"
HOMEPAGE="https://pandoc.org/ https://github.com/jgm/pandoc"

SRC_URI="
	amd64? ( https://github.com/jgm/pandoc/releases/download/${PV}/${MY_P}-linux-amd64.tar.gz )
	arm64? ( https://github.com/jgm/pandoc/releases/download/${PV}/${MY_P}-linux-arm64.tar.gz )
"
S="${WORKDIR}/${MY_P}"

# Pandoc itself is GPL-2+. The statically linked release bundles many
# Haskell libraries under permissive licenses (mostly BSD/MIT).
LICENSE="GPL-2+ BSD MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# Prebuilt, statically linked binary: nothing to strip, nothing to mirror,
# and no shared-library runtime deps to resolve.
RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/*"

RDEPEND="
	!app-text/pandoc
	!app-text/pandoc-cli
"

src_install() {
	dobin bin/pandoc

	# pandoc-lua and pandoc-server are multi-call symlinks to pandoc in the
	# upstream tarball; recreate them as symlinks, but fall back to dobin in
	# case a future release ships them as separate real binaries.
	local b
	for b in pandoc-lua pandoc-server ; do
		if [[ -L bin/${b} ]] ; then
			dosym pandoc /usr/bin/${b}
		elif [[ -e bin/${b} ]] ; then
			dobin "bin/${b}"
		fi
	done

	if [[ -d share/man/man1 ]] ; then
		doman share/man/man1/*.1*
	fi
}
