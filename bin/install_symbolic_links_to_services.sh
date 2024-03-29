#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

if [ ! -d .git ]; then
  echo The working directory have to the root directory of the git project
  exit 1
fi

mkdir -p ~/.config/systemd/user

for file in ~/.config/systemd/user/*.service; do
  if [ -L "${file}" ]; then
    if [ ! -e "${file}" ]; then
      rm --verbose "${file}"
    fi
  fi
done

for file in ${PWD}/systemd.service/*.service; do
  if [ -f "${file}" ] && [ ! -e ~/.config/systemd/user/$(basename "${file}") ]; then
    ln --verbose --symbolic "${file}" ~/.config/systemd/user/$(basename "${file}")
  fi
done

for file in ${PWD}/systemd.service/*.disabled; do
  file_name="$(basename "${file:-%.disabled}")"

  if [ -e ~/.config/systemd/user/${file_name} ]; then
    rm --verbose ~/.config/systemd/user/${file_name}
  fi
done

