{
  description = "A modern emoji picker for Hyprland, written in Rust + GTK4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = "hypremoji";
            version = "1.1.5";
            src = ./.;

            cargoHash = "sha256-uJM79fWX4+vJ24/eIs7Tr+PrZORUCA8Ko4B5ZfmZVS0=";

            nativeBuildInputs = with pkgs; [
              pkg-config
              wrapGAppsHook4
            ];

            buildInputs = with pkgs; [
              gtk4
              glib
              pango
              gdk-pixbuf
              graphene
              cairo
            ];

            postInstall = ''
              mkdir -p $out/share/hypremoji
              cp -r assets $out/share/hypremoji/
              install -Dm644 config/hypremoji.conf $out/share/hypremoji/hypremoji.conf
              install -Dm644 config/paste_config.json $out/share/hypremoji/paste_config.json
            '';

            meta = with pkgs.lib; {
              description = "A modern emoji picker for Hyprland, written in Rust + GTK4";
              homepage = "https://github.com/Musagy/hypremoji";
              license = licenses.isc;
              maintainers = [ ];
              platforms = [
                "x86_64-linux"
                "aarch64-linux"
              ];
              mainProgram = "hypremoji";
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.default ];

            packages = with pkgs; [
              cargo
              rustc
              rust-analyzer
              clippy
              rustfmt
            ];
          };
        }
      );
    };
}
