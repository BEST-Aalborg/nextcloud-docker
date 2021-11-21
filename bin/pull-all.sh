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
        jq -r ".[].name | select(. | test(\"${filter}\"))" | sort -V
}

get_next_major_release_number() {
    current_major_release="$1"
    minium_next_intermediate_number="${2:-5}"

    awk -F '.' '
    BEGIN{
      current_major_release='"${current_major_release}"';
      minium_next_intermediate_number='"${minium_next_intermediate_number}"';
      intermediate_release_detected=0;
      next_major_release=current_major_release
    }
    {
      if ($1 < current_major_release) {
        next
      }
      if (current_major_release + 2 == $1) {
        next_major_release=current_major_release + 1;
        print "2 release behind: bump";
      }
      if ($2 > 0) {
        intermediate_release_detected=1;
        print "intermediate relesae detected";
      }
      if (intermediate_release_detected == 0 && $3 > minium_next_intermediate_number) {
        next_major_release=$1;
        print "high minor relesae: bump";
      }
      else if (intermediate_release_detected == 1 && $2 > minium_next_intermediate_number) {
        next_major_release=$1;
        print "high intermediate relesae: bump";
      }
    }
    END{
      if (next_major_release > current_major_release + 1) {
        next_major_release = current_major_release + 1
        print "only bump next release with 1";
      }
      printf "%s", next_major_release
    }
    '
}


for file in $(find . -name Dockerfile); do
    image_and_tag="$(sed -nE 's/FROM[[:space:]]+//p' "${file}")"
    tag="${image_and_tag##*:}"
    image="${image_and_tag%:$tag}"
    envirment_file=".env"

    ### Figure out when to switch/upgrade to the new version ###
    # Before version 18 it was possible to use the tag "production", but now that is only
    # available for paying customers. Nextcloud change how the tags works.
    # The benefit of the production tag, is that it doesn't update right away, when a new
    # major version comes out, but instead would wait 2 intermediate releases.
    #
    # This if-statement was made to re-create the functionality there was
    # previously provided by the production tag.
    #
    # Note: I made it so we first upgrade major release, when intermediate release 5
    #       of a major release is avalable
    #
    # Source: Explain major release and intermediate release
    # https://softwareengineering.stackexchange.com/questions/3199/what-version-naming-convention-do-you-use/130903#130903
    if [ "${image}" == "nextcloud" ]; then
        if ! grep --quiet 'NEXTCLOUD_VERSION' "${envirment_file}"; then
            latest_major_tag="$(docker_tag "${image}" | grep '^[0-9.]*-fpm$' | tail -n 1)"

            _branch=${latest_major_tag##*-}
            _version=${latest_major_tag%-$_branch}
        else
            _version="$(sed -n 's/NEXTCLOUD_VERSION=//p' "${envirment_file}")"
            _branch="$(sed -n 's/NEXTCLOUD_BRANCH=//p' "${envirment_file}")"
            [ -z "${_branch}" ] && _branch="fpm"
        fi

        # Check if the next major release is mature enough to that we want to upgrade
        _tmp_version="$(docker_tag "${image}" "^[0-9.]*-${_branch}$" | sed "s/-${_branch}//" | \
        get_next_major_release_number "$_version" 5)"
        _version="$(tail -n 1 <<<"$_tmp_version" | tr -d '\n')"

        image_and_tag="${image}:${_version}-${_branch}"

        # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
        if [ -z "${TEST}" ]; then
            if grep --quiet 'NEXTCLOUD_VERSION' "${envirment_file}"; then
                sed -i "s/NEXTCLOUD_VERSION=.*/NEXTCLOUD_VERSION=${_version}/" "${envirment_file}"
            else
                echo "NEXTCLOUD_VERSION=${_version}" >> "${envirment_file}"
            fi
            if grep --quiet 'NEXTCLOUD_BRANCH' "${envirment_file}"; then
                sed -i "s/NEXTCLOUD_BRANCH=.*/NEXTCLOUD_BRANCH=${_branch}/" "${envirment_file}"
            else
                echo "NEXTCLOUD_BRANCH=${_branch}" >> "${envirment_file}"
            fi
        else
            echo "TEST: Set the new Nextcloud image to be '${image_and_tag}' in the file: ${envirment_file}"
        fi
    fi

    if [ "${image}" == "elasticsearch" ]; then
        _docker_tags=$(docker_tag "${image}" "^[0-9]*[.]")

        if ! grep --quiet 'ELASTIC_SEARCH_VERSION' "${envirment_file}"; then
            _version="$(tail -n 1 <<<"${_docker_tags}")"
        else
            _version="$(sed -n 's/ELASTIC_SEARCH_VERSION=//p' "${envirment_file}")"
        fi

        # Check if we are far enough into the next major release to that we want to upgrade
        _tmp_version="$(get_next_major_release_number "${_version%%.*}" <<<"${_docker_tags}")"
        _version="$(grep "^$(tail -n 1 <<<"$_tmp_version" | tr -d '\n')\." <<<"${_docker_tags}" | tail -n 1)"

        image_and_tag="${image}:${_version}"

        # Only pull new image if the envirement variable `TEST` is not set else `echo` the image
        if [ -z "${TEST}" ]; then
            if grep --quiet 'ELASTIC_SEARCH_VERSION' "${envirment_file}"; then
                sed -i "s/ELASTIC_SEARCH_VERSION=.*/ELASTIC_SEARCH_VERSION=${_version}/" "${envirment_file}"
            else
                echo "ELASTIC_SEARCH_VERSION=${_version}" >> "${envirment_file}"
            fi
        else
            echo "TEST: Set the new Elastic Search image to be '${image_and_tag}' in the file: ${envirment_file}"
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

