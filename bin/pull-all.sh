#!/bin/bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab:

set -eu

if [ ! -d .git ]; then
  echo The working directory have to the root directory of the git project
  exit 1
fi

TEST=${TEST:-}

docker_tag() {
    image="$1"
    filter="${2:-}"
    curl --silent --show-error https://registry.hub.docker.com/v1/repositories/${image}/tags | \
        jq -r ".[].name | select(. | test(\"${filter}\"))"
}


for file in $(find . -name Dockerfile); do
    image_and_tag="$(sed -nE 's/FROM[[:space:]]+//p' "${file}")"
    tag="${image_and_tag##*:}"
    image="${image_and_tag%:$tag}"

    ### Figure out when to switch/upgrade to the new version ###
    # Before version 18 it was possible to use the tag "production", but now that is only
    # available for paying customers. Nextcloud change how the tags works.
    # The benefit of the production tag, is that it doesn't update right away, when a new
    # major version comes out, but instead would wait 2 releases.
    # This if statement in the script was created to re-create the functionality
    # there was previously provided by the production tag.
    if [ "${image}" == "nextcloud" ]; then
        nextcloud_version_file=".env"

        if ! grep --quiet 'NEXTCLOUD_VERSION' "${nextcloud_version_file}"; then
            latest_major_tag="$(docker_tag "${image}" | grep '^[0-9]*-fpm$' | sort -V | tail -n 1)"

            _branch=${latest_major_tag##*-}
            _version=${latest_major_tag%-$_branch}
        else
            _version="$(sed -n 's/NEXTCLOUD_VERSION=//p' "${nextcloud_version_file}")"
            _branch="$(sed -n 's/NEXTCLOUD_BRANCH=//p' "${nextcloud_version_file}")"
            [ -z "${_branch}" ] && _branch="fpm"
        fi

        # Check if we are far enough into the next major release to that we want to upgrade
        _check_new_version=$(expr ${_version} + 1)
        [ -n "$(docker_tag "${image}" "^${_check_new_version}[0-9.]*5-${_branch}$")" ] && _version="${_check_new_version}"

        image_and_tag="${image}:${_version}-${_branch}"

        # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
        if [ -z "${TEST}" ]; then
            if grep --quiet 'NEXTCLOUD_VERSION' "${nextcloud_version_file}"; then
                sed -i "s/NEXTCLOUD_VERSION=.*/NEXTCLOUD_VERSION=${_version}/" "${nextcloud_version_file}"
            else
                echo "NEXTCLOUD_VERSION=${_version}" >> "${nextcloud_version_file}"
            fi
            if grep --quiet 'NEXTCLOUD_BRANCH' "${nextcloud_version_file}"; then
                sed -i "s/NEXTCLOUD_BRANCH=.*/NEXTCLOUD_BRANCH=${_branch}/" "${nextcloud_version_file}"
            else
                echo "NEXTCLOUD_BRANCH=${_branch}" >> "${nextcloud_version_file}"
            fi
        else
            echo "TEST: Set the new Nextcloud image to be '${image_and_tag}' in the file: ${nextcloud_version_file}"
        fi
    fi

    # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
    if [ -z "${TEST}" ]; then
        docker pull "${image_and_tag}"
    else
        echo "TEST: Pull the image '${image_and_tag}'"
    fi
done

# Only run if the envirement variable `TEST` is not set
[ -z "${TEST}" ] && docker-compose -f docker-compose.yml pull

