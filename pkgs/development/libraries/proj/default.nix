{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, buildPackages
, sqlite
, libtiff
, curl
, gtest
, nlohmann_json
, python3
}:

stdenv.mkDerivation rec {
  pname = "proj";
  version = "9.1.0";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "PROJ";
    rev = version;
    hash = "sha256-Upsp72RorV+5PFPHOK3zCJgVTRZ6fSVVFRope8Bp8/M=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ sqlite libtiff curl nlohmann_json ];

  checkInputs = [ gtest ];

  cmakeFlags = [
    "-DUSE_EXTERNAL_GTEST=ON"
    "-DRUN_NETWORK_DEPENDENT_TESTS=OFF"
    "-DNLOHMANN_JSON_ORIGIN=external"
    "-DEXE_SQLITE3=${buildPackages.sqlite}/bin/sqlite3"
  ];

  preCheck =
    let
      libPathEnvVar = if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
      ''
        export HOME=$TMPDIR
        export TMP=$TMPDIR
        export ${libPathEnvVar}=$PWD/lib
      '';

  doCheck = true;

  passthru.tests = {
    python = python3.pkgs.pyproj;
  };

  meta = with lib; {
    description = "Cartographic Projections Library";
    homepage = "https://proj.org/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ dotlambda ];
  };
}
