{ lib
, stdenv
, fetchurl
, meson
, ninja
, pkg-config
, gobject-introspection
, vala
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, gtk3
, glade
, dbus
, xvfb_run
, libxml2
, gdk-pixbuf
, librsvg
, hicolor-icon-theme
, at-spi2-atk
, at-spi2-core
, gnome3
}:

stdenv.mkDerivation rec {
  pname = "libhandy";
  version = "1.2.2";

  outputs = [ "out" "dev" "devdoc" "glade" ];
  outputBin = "dev";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-R//Shl0CvRyleVIt6t1+L5U2Lx8gJGL9XuriuBZosEg=";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_43
    docbook-xsl-nons
    gobject-introspection
    gtk-doc
    libxml2
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    gdk-pixbuf
    glade
    gtk3
    libxml2
  ];

  checkInputs = [
    dbus
    xvfb_run
    at-spi2-atk
    at-spi2-core
    librsvg
    hicolor-icon-theme
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  # Uses define_variable in pkg-config, but we still need it to use the glade output
  PKG_CONFIG_GLADEUI_2_0_MODULEDIR = "${placeholder "glade"}/lib/glade/modules";
  PKG_CONFIG_GLADEUI_2_0_CATALOGDIR = "${placeholder "glade"}/share/glade/catalogs";

  doCheck = true;

  checkPhase = ''
    NO_AT_BRIDGE=1 \
    XDG_DATA_DIRS="$XDG_DATA_DIRS:${hicolor-icon-theme}/share" \
    GDK_PIXBUF_MODULE_FILE="${librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus.daemon}/share/dbus-1/session.conf \
      meson test --print-errorlogs
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with lib; {
    changelog = "https://gitlab.gnome.org/GNOME/libhandy/-/tags/${version}";
    description = "Building blocks for modern adaptive GNOME apps";
    homepage = "https://gitlab.gnome.org/GNOME/libhandy";
    license = licenses.lgpl21Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.linux;
  };
}
