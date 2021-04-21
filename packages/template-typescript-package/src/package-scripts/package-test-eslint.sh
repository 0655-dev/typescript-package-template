#!/usr/bin/env bash

# WARNING: this package is auto-generated from a template
# do not try to make changes in here, they will be overwritten

#
# turn this on to debug script
# set -x

#
# abort on error
# https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

# import other vars from the package config
PACKAGE_ROOT=.
PACKAGE_CONFIG=$PACKAGE_ROOT/package-config.sh
source $PACKAGE_CONFIG

if [ "$PACKAGE_USE_ESLINT" = false ]; then exit 0; fi

if [ -z "$PACKAGE_SRC" ]; then echo "[ERROR] PACKAGE_SRC var is not set"; exit 1; fi
if [ -z "$PACKAGE_ESLINTRC" ]; then echo "[ERROR] PACKAGE_ESLINTRC var is not set"; exit 1; fi

echo ""
echo "[INFO] running eslint against source code"

# eslint sometimes misses some files
# so, instead we use find to find all matching files,
# sort them,
# and pipe into eslint via xargs

( \
	find \
		$PACKAGE_SRC \
		\( -type f -and -name "*.js" \) -or \
		\( -type f -and -name "*.jsx" \) -or \
		\( -type f -and -name "*.ts" \) -or \
		\( -type f -and -name "*.tsx" \) \
	| \
	sort \
		--stable \
		--ignore-case \
		--field-separator=/ \
		--key=2.2 \
		--key=2.1 \
	| \
	xargs \
		pnpx eslint \
			--quiet \
			--config="$PACKAGE_ESLINTRC" \
)

echo "[INFO] eslint checks passed!"
echo ""