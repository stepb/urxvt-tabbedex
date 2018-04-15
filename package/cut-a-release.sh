#!/bin/sh

set -eu

noclobber=true
patchlevel=
tag=-a
for arg; do
	case "$arg" in
	-t|--no-tag) tag= ;;
	-s|--sign)   tag=-s ;;
	-f|--force)  noclobber=false ;;
	-p?*)        patchlevel=${arg#-?} ;;
	*)
		echo "$1: unknown flag" >&2
		exit 1
	esac
	shift
done

version=$(git log -1 --format=%cd --date=format:%g.%-V%u)${patchlevel:+.$patchlevel}
pkg=urxvt-tabbedex-$version

out=${TMPDIR:-/tmp}/$pkg.tar.bz2
experimental=o/experimental
master=o/master

if [ -z "$(which tput 2>/dev/null)" ]; then
	setf() { true; }
	bold=
	sgr0=
else
	setf() { tput setf "$1"; }
	bold=$(tput bold)
	sgr0=$(tput sgr0)
fi

if $noclobber && [ -e "$out" ]; then
	echo "$(setf 4)Release file (‘${bold}$out$(setf 4)’) already exists, aborting${sgr0}" >&2
	exit 1
fi

echo "Creating release ${bold}urxvt-tabbedex $version${sgr0} from $master:"
git log -n1 --pretty="format:    $(setf 6)%h  $(setf 3)%s${sgr0}"

if [ -n "$tag" ]; then
	git tag $tag "v$version" "$master"
fi

tmp=$(mktemp -d)
trap 'rm -r -- "$tmp"' 0

git archive --format=tar --prefix="$pkg/" "$master" | tar xC "$tmp" \
	--exclude=.gitignore --exclude=install --exclude=\*cut-a-release\*

mkdir -- "$tmp/$pkg/experimental"
git format-patch -o "$tmp/$pkg/experimental" "$master".."$experimental" >/dev/null

echo "$version" >$tmp/$pkg/.version

cd -- "$tmp"
echo
setf 7
tar jcvf "$out" --sort=name --owner=0 --group=0 --mode=a+rX "$pkg"
echo "$sgr0"

echo ">>  Release file saved to ${bold}$out${sgr0}  <<"
