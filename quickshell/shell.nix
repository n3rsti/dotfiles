{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = [
    pkgs.quickshell
    pkgs.kdePackages.qtdeclarative
    pkgs.qt6.qtdeclarative
  ];
  shellHook = ''
    # Required for qmlls to find the correct type declarations
    export QMLLS_BUILD_DIRS=${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${pkgs.quickshell}/lib/qt-6/qml/
    export QML_IMPORT_PATH=$PWD/src
  '';
}
