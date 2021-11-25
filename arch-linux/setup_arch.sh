#!/usr/bin/env bash
set -e
sh setup_etc.sh

sh setup_pkgs.sh

sh setup_gpu.sh

sh setup_pkgs.sh

