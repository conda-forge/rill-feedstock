#!/bin/bash
set -exuo pipefail

# Fetch build commit
PKG_COMMIT=$(curl https://api.github.com/repos/rilldata/rill/git/ref/tags/v${PKG_VERSION} | jq -r ".object.sha" | head -c 8)

pushd cli
go-licenses save . --save_path ../library_licenses --ignore modernc.org/mathutil --ignore go.uber.org/zap/exp/zapslog
popd

# Don't use bundled pre-built static libs
export GOFLAGS='-tags=duckdb_use_lib,dynamic'
make cli.prepare
go build \
    -v \
    -o "${PREFIX}"/bin/rill \
    -ldflags="-s -w -X main.Version=${PKG_VERSION} -X main.Commit=${PKG_COMMIT} -X main.BuildDate=$(date)" \
    cli/main.go 

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
