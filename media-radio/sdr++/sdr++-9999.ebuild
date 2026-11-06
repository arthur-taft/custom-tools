# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit cmake xdg git-r3

DESCRIPTION="Cross-platform, bloat-free Software Defined Radio (SDR) application"
HOMEPAGE="https://www.sdrpp.org https://github.com/AlexandreRouma/SDRPlusPlus"
EGIT_REPO_URI="https://github.com/AlexandreRouma/SDRPlusPlus.git"

LICENSE="GPL-3"
SLOT="0"
# Live ebuild: leave KEYWORDS empty. For a pinned snapshot, see the notes
# at the bottom of this file and set KEYWORDS="~amd64".
KEYWORDS=""

IUSE="airspy airspyhf bladerf codec2 hackrf limesuite plutosdr portaudio +rtlsdr soapy usrp"

PYTHON_COMPAT=( python3_13 python3_14 )

# Core libraries required by sdrpp_core. The audio source/sink modules are
# built unconditionally because without an audio sink you cannot actually
# listen to demodulated audio, which makes the program useless on the desktop.
RDEPEND="
	app-arch/zstd:=
	media-libs/glew:0=
	media-libs/glfw
	media-libs/rtaudio
	sci-libs/fftw:3.0=
	>=sci-libs/volk-3.2.0
	virtual/opengl
	airspy? ( net-wireless/airspy )
	airspyhf? ( net-wireless/airspyhf )
	bladerf? ( net-wireless/bladerf )
	codec2? ( media-libs/codec2 )
	hackrf? ( net-wireless/hackrf-tools )
	limesuite? ( net-wireless/limesuite )
	plutosdr? (
		net-libs/libiio
		net-libs/libad9361-iio
	)
	portaudio? ( media-libs/portaudio )
	rtlsdr? ( net-wireless/rtl-sdr )
	soapy? ( net-wireless/soapysdr )
	usrp? ( net-wireless/uhd )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		# Backend / compatibility
		-DOPT_BACKEND_GLFW=ON
		-DOPT_BACKEND_ANDROID=OFF
		-DOPT_OVERRIDE_STD_FILESYSTEM=OFF

		# libcorrect is vendored and not packaged separately in ::gentoo
		-DUSE_INTERNAL_LIBCORRECT=ON

		# Audio I/O (needed to actually hear anything)
		-DOPT_BUILD_AUDIO_SOURCE=ON
		-DOPT_BUILD_AUDIO_SINK=ON

		# Hardware source modules (each gated on a USE flag + its library)
		-DOPT_BUILD_AIRSPY_SOURCE=$(usex airspy)
		-DOPT_BUILD_AIRSPYHF_SOURCE=$(usex airspyhf)
		-DOPT_BUILD_BLADERF_SOURCE=$(usex bladerf)
		-DOPT_BUILD_HACKRF_SOURCE=$(usex hackrf)
		-DOPT_BUILD_LIMESDR_SOURCE=$(usex limesuite)
		-DOPT_BUILD_PLUTOSDR_SOURCE=$(usex plutosdr)
		-DOPT_BUILD_RTL_SDR_SOURCE=$(usex rtlsdr)
		-DOPT_BUILD_SOAPY_SOURCE=$(usex soapy)
		-DOPT_BUILD_USRP_SOURCE=$(usex usrp)

		# Dependency-free network / file sources stay enabled
		-DOPT_BUILD_FILE_SOURCE=ON
		-DOPT_BUILD_NETWORK_SOURCE=ON
		-DOPT_BUILD_RTL_TCP_SOURCE=ON
		-DOPT_BUILD_RFSPACE_SOURCE=ON
		-DOPT_BUILD_SPECTRAN_HTTP_SOURCE=ON
		-DOPT_BUILD_SPYSERVER_SOURCE=ON
		-DOPT_BUILD_SDRPP_SERVER_SOURCE=ON
		-DOPT_BUILD_HERMES_SOURCE=ON

		# Sinks
		-DOPT_BUILD_NETWORK_SINK=ON
		-DOPT_BUILD_PORTAUDIO_SINK=$(usex portaudio)
		-DOPT_BUILD_NEW_PORTAUDIO_SINK=OFF

		# Decoders / demodulators
		-DOPT_BUILD_RADIO=ON
		-DOPT_BUILD_METEOR_DEMODULATOR=ON
		-DOPT_BUILD_PAGER_DECODER=ON
		-DOPT_BUILD_ATV_DECODER=ON
		-DOPT_BUILD_M17_DECODER=$(usex codec2)

		# Misc modules (no extra dependencies)
		-DOPT_BUILD_FREQUENCY_MANAGER=ON
		-DOPT_BUILD_RECORDER=ON
		-DOPT_BUILD_RIGCTL_SERVER=ON
		-DOPT_BUILD_RIGCTL_CLIENT=ON
		-DOPT_BUILD_SCANNER=ON
		-DOPT_BUILD_IQ_EXPORTER=ON

		# Discord Rich Presence is off by default (phones home)
		-DOPT_BUILD_DISCORD_PRESENCE=OFF
	)

	cmake_src_configure
}

# ---------------------------------------------------------------------------
# Making a pinned (non-live) version instead:
#
#   1. Drop "git-r3" from inherit and remove EGIT_REPO_URI.
#   2. Add a commit/tag and a tarball SRC_URI, e.g.:
#
#        MY_COMMIT="b2948dd37c9b5a96f7c9a44c4c750021035ea1d8"
#        SRC_URI="https://github.com/AlexandreRouma/SDRPlusPlus/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
#        S="${WORKDIR}/SDRPlusPlus-${MY_COMMIT}"
#        KEYWORDS="~amd64"
#
#   Name the file e.g. sdrpp-1.2.1_p20260101.ebuild and regenerate Manifest
#   with `ebuild sdrpp-<ver>.ebuild manifest`.
# ---------------------------------------------------------------------------
