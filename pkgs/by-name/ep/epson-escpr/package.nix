{
  lib,
  stdenv,
  fetchurl,
  cups,
  rpm,
  cpio
}:

let
  fullname = "epson-inkjet-printer-escpr";
  version = "1.8.6";
in
stdenv.mkDerivation {
  pname = "epson-escpr";
  inherit version;

  src = fetchurl {
    # To find new versions, visit
    # http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX and search for
    # some printer like for instance "WF-7110" to get to the most recent
    # version.
    # NOTE: Don't forget to update the webarchive link too!
    urls = [
      "https://download3.ebz.epson.net/dsc/f/03/00/16/21/79/6d53e6ec3f8c1e55733eb7860e992a425883bf88/epson-inkjet-printer-escpr-1.8.6-1.src.rpm"
      "https://web.archive.org/web/20241201010807/https://download3.ebz.epson.net/dsc/f/03/00/16/21/79/6d53e6ec3f8c1e55733eb7860e992a425883bf88/epson-inkjet-printer-escpr-1.8.6-1.src.rpm"
    ];
    sha256 = "sha256-s419162FmZjtlCtAQPR+AOX2IqvMuCX+IheGyfeI0Lk=";
  };

  patches = [ ./cups-filter-ppd-dirs.patch ];

  buildInputs = [ cups rpm cpio ];

  unpackPhase = ''
    runHook preUnpack

    ${lib.getBin rpm}/bin/rpm2cpio $src | ${lib.getBin cpio}/bin/cpio -idmv
    tar -xvf ${fullname}-${version}-1.tar.gz
    cd ${fullname}-${version}

    runHook postUnpack
  '';

  meta = with lib; {
    homepage = "http://download.ebz.epson.net/dsc/search/01/search";
    description = "ESC/P-R Driver (generic driver)";
    longDescription = ''
      Epson Inkjet Printer Driver (ESC/P-R) for Linux and the
      corresponding PPD files. The list of supported printers
      can be found at http://www.openprinting.org/driver/epson-escpr/ .

      To use the driver adjust your configuration.nix file:
        services.printing = {
          enable = true;
          drivers = [ pkgs.epson-escpr ];
        };

      To setup a wireless printer, enable Avahi which provides
      printer's hostname to CUPS and nss-mdns to make this
      hostname resolvable:
        services.avahi = {
          enable = true;
          nssmdns4 = true;
        };'';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ artuuge ];
    platforms = platforms.linux;
  };
}
