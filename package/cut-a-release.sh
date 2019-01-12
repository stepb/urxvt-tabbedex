#!/bin/sh

set -eu

if [ -z "$(which tput 2>/dev/null)" ]; then
	setf() { true; }
	bold=
	sgr0=
else
	setf() { tput setf "$1"; }
	bold=$(tput bold)
	sgr0=$(tput sgr0)
fi

die() {
	echo "${0##*/}: $(setf 4)$*${sgr0}" >&2
	exit 1
}

noclobber=true
patchlevel=
tag=-a
dry=
experimental=o/experimental
master=o/master
n=0
while [ $# -gt 0 ]; do
	case "$n:$1" in
	?:-s|?:--sign)    tag=-s ;;
	?:-f|?:--force)   noclobber=false ;;
	?:-n|?:--dry-run) dry="echo >" ;;
	?:-p?*)           patchlevel=${1#-?} ;;
	0:?*)
		master=$1
		experimental=HEAD
		n=1
		;;
	1:?*)
		experimental=$1
		n=2
		;;
	*)
		die "unknown argument: $1"
	esac
	shift
done

version=$(date +%g.%V)${patchlevel:+.$patchlevel}
pkg=urxvt-tabbedex-$version

out=${TMPDIR:-/tmp}/$pkg.tar.bz2

git remote update o

if ! git merge-base --is-ancestor "$master" "$experimental"; then
	die "$master is not an ancestor of $experimental" >&2
elif [ -z "$dry" ] && $noclobber && [ -e "$out" ]; then
	die "Release file (‘${bold}$out$(setf 4)’) already exists, aborting" >&2
fi

echo "Creating release ${bold}urxvt-tabbedex $version${sgr0} from $master:"
git log -n1 --pretty="format:    $(setf 6)%h  $(setf 3)%s${sgr0}" "$master"

$dry git tag $tag "v$version" "$master"
$dry git push o +"v$version:refs/tags/v$version" \
     "$master:refs/heads/master" +"$experimental:refs/heads/experimental"

tmp=$(mktemp -d)
trap 'rm -r -- "$tmp"' 0

git archive --format=tar --prefix="$pkg/" "$master" | tar xC "$tmp" \
	--exclude=.gitignore --exclude=install --exclude=\*cut-a-release\*

mkdir -- "$tmp/$pkg/experimental"
git format-patch -o "$tmp/$pkg/experimental" "$master".."$experimental" >/dev/null

echo "$version" >$tmp/$pkg/.version

mkdir -- "$tmp/$pkg/release-notes"
for tag in $(g tag | grep -o '^v[1-9][0-9]\.[0-9][0-9][0-9]$'); do
	git cat-file tag $tag | sed '1,/^$/d' >$tmp/$pkg/release-notes/$tag.txt
done

cd -- "$tmp"
echo
setf 7
dry_out=${dry:+/dev/null}
tar jcvf "${dry_out:-$out}" --sort=name --owner=0 --group=0 --mode=a+rX "$pkg"
echo "$sgr0"

if [ -z "$dry" ]; then
	echo ">>  Release file saved to ${bold}$out${sgr0}  <<"
else
	echo ">>  Would save release file to ${bold}$out${sgr0}  <<"
fi
