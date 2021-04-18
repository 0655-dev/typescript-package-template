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

ROOT_DIR=.
SRC_DIR=$ROOT_DIR/src
DIST_DIR=$ROOT_DIR/dist

SCRIPTS_DIR=$ROOT_DIR/package-scripts
SOURCE_MAP=$ROOT_DIR/.sourcemap

echo ""
echo "[INFO] starting package build";

_check_env () {
	for tool in "$@"
	do
		if ! [ -x "$(command -v $tool)" ]; then
			echo "[ERROR] $tool not found, aborting..." >&2
			exit 1
		fi
	done
}

_check_env pnpx rsync mktemp;

# load source_hash function
source $SCRIPTS_DIR/source-hash.sh

echo "[INFO] starting build check"

# SOURCE_HASH_FILE is the name of the source hash to check against
SOURCE_HASH_FILE=.SOURCE_HASH

# SHOULD_REBUILD is the flag to check if a rebuild is needed
SHOULD_REBUILD=1

_MAKE_SOURCE_HASH() {
	echo "[INFO] calculating source hash";
	SOURCE_HASH=$(source_hash $SOURCE_MAP)
	echo "[INFO] source hash $SOURCE_HASH";
}

_CHECK_SOURCE_HASH() {
	echo "[INFO] verifying source hash against build";
	if [ -f $DIST_DIR/$SOURCE_HASH_FILE ]
	then
		DIST_SOURCE_HASH=$(cat $DIST_DIR/$SOURCE_HASH_FILE);
		# echo "dist source hash $DIST_SOURCE_HASH";
		if [ "$SOURCE_HASH" == "$DIST_SOURCE_HASH" ]
		then
			echo "[INFO] source hash '$SOURCE_HASH' is equal to dist source hash '$DIST_SOURCE_HASH'";
			SHOULD_REBUILD=0;
		else
			echo "[INFO] source hash '$SOURCE_HASH' is not equal to dist source hash '$DIST_SOURCE_HASH'";
			SHOULD_REBUILD=1;
		fi
	else
		SHOULD_REBUILD=1;
	fi
}

_MAKE_BUILD_DIR () {
	#
	# make a temporary build dir
	# this command is linux / osx agnostic
	# https://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
	echo "[INFO] creating temporary build dir"
	BUILD_DIR=''
	BUILD_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'build-dir'`
}

_UNMAKE_BUILD_DIR () {
	#
	# clean up build dir
	echo "[INFO] removing temporary build dir"
	rm -rf $BUILD_DIR
}

_BUILD_TS () {
	#
	# build typescript into temp dir
	echo "[INFO] compiling TS into build dir"
	(pnpx tsc \
		--outDir "$BUILD_DIR"
		--noEmitOnError false \
	) > /dev/null 2>&1 || true
}

_COPY_ASSETS () {
	#
	# copy src/**/*.js into temp dir
	echo "[INFO] copying non-TS assets into build dir"
	rsync \
		--update \
		--recursive \
		--exclude='*.ts' \
		--exclude='*.tsx' \
		--include='*' \
		$SRC_DIR/ \
		$BUILD_DIR
		# --itemize-changes \
}

_BUILD_EXTRAS () {
	echo '[INFO] copying extras into build dir'
	echo "$SOURCE_HASH" > $BUILD_DIR/$SOURCE_HASH_FILE
}

_WRITE_BUILD_TO_DIST () {
	#
	# use rsync to fast-sync the dist dir with the build dir
	# 'temp' is excluded to work around an issue with local temp dirs getting used
	echo "[INFO] writing build to dist"
	rsync \
		--update \
		--recursive \
		--exclude='temp' \
		--delete \
		$BUILD_DIR/ \
		$DIST_DIR
		# --itemize-changes \
}

_CLEANUP () {
	_UNMAKE_BUILD_DIR || true
	echo ""
}

_MAKE_SOURCE_HASH
_CHECK_SOURCE_HASH

if [ $SHOULD_REBUILD == 1 ]
then
	echo "[INFO] starting build"
	trap _CLEANUP ERR EXIT
	_MAKE_BUILD_DIR
	_COPY_ASSETS
	_BUILD_TS
	_BUILD_EXTRAS
	_WRITE_BUILD_TO_DIST
	echo "[INFO] build for finished!"
	echo ""
else
	echo "[INFO] build is up-to-date, exiting"
	echo ""
fi