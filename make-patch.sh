#!/bin/sh
# 在 CarWithin 本地克隆目录里跑：sh make-patch.sh
# 产出 voge-port.patch，拖到 CI 仓库根目录即可重新出包。
set -e
cd "$(dirname "$0")"
git add -N App/VogeConnection.swift App/InstrumentVideoSession.swift 2>/dev/null || true
git diff -- App TDSCarKit.xcodeproj > voge-port.patch
echo "已生成 $(pwd)/voge-port.patch ($(wc -c < voge-port.patch) 字节)"
