{
  description = "A documentation generator plugin for the Google Protocol Buffers compiler (protoc)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          protoc-gen-doc = pkgs.buildGoModule {
            pname = "protoc-gen-doc";
            version = "1.5.1";

            src = ./.;

            vendorHash = "sha256-PcgIsiFn6yED4zxfNkO5yve3JcBklynRnh+jFuJUPNY=";

            subPackages = [ "cmd/protoc-gen-doc" ];

            nativeBuildInputs = [ pkgs.protobuf ];

            meta = with pkgs.lib; {
              description = "Documentation generator plugin for Google Protocol Buffers";
              homepage = "https://github.com/pseudomuto/protoc-gen-doc";
              license = licenses.mit;
              maintainers = [ ];
              mainProgram = "protoc-gen-doc";
            };
          };

          default = self.packages.${system}.protoc-gen-doc;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            protobuf
            goreleaser
            revive
          ];

          shellHook = ''
            echo "protoc-gen-doc development shell"
            echo "Go version: $(go version)"
            echo "Protoc version: $(protoc --version)"
          '';
        };

        apps = {
          protoc-gen-doc = {
            type = "app";
            program = "${self.packages.${system}.protoc-gen-doc}/bin/protoc-gen-doc";
          };

          default = self.apps.${system}.protoc-gen-doc;
        };
      }
    );
}
