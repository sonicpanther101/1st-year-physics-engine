{
	description = "1st-year-physics-engine";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
	    flake-utils.lib.eachDefaultSystem (system:
			let
				pkgs = nixpkgs.legacyPackages.${system};
			in {
				packages.default = pkgs.stdenv.mkDerivation {
					pname = "1st-year-physics-engine";
					version = "0.1.0";

					src = ./src;

					nativeBuildInputs = with pkgs; [
						pkg-config
					];

					buildInputs = with pkgs; [
						libGL
						glfw
						glew
						glm
						assimp
						imgui
						imgui.lib
						stb
					];

					buildPhase = ''
						# Collect all .cpp files in src/
						SOURCES=$(find . -name "*.cpp" | tr '\n' ' ')

						$CXX $SOURCES \
							-std=c++17 \
							-O2 \
							-D_CRT_SECURE_NO_WARNINGS \
							$(pkg-config --cflags --libs glfw3 glew assimp) \
							-I${pkgs.imgui}/include \
							-I${pkgs.imgui}/include/imgui \
							-I${pkgs.stb}/include/stb \
							-L${pkgs.imgui.lib}/lib -limgui \
							-lGL \
							-o physics-engine
					'';

					installPhase = ''
						mkdir -p $out/bin
						cp physics-engine $out/bin/
					'';
				};

				devShells.default = pkgs.mkShell {
					inputsFrom = [ self.packages.${system}.default ];
					packages = with pkgs; [
						gdb
						clang-tools
					];
				};
			}
		);
}