
# Download planetiler v0.7.0
curl -L -o planetiler.jar https://github.com/onthegomap/planetiler/releases/download/v0.7.0/planetiler.jar

# Download planetiler v0.7.0 checksum
curl -L -o ./planetiler.jar.sha256 https://github.com/onthegomap/planetiler/releases/download/v0.7.0/planetiler.jar.sha256

shasum -a 256 -c planetiler.jar.sha256