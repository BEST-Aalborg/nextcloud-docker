[TOC]

# Intro

This setup of Nextcloud is used by BEST Aalborg, use it if you want.


# Setup

1. Clone repo and `cd` into it
2. run `cp config.env.sample config.env`
3. modify the config file `config.env`
4. Create all the need folders, use magic one-liner `cat docker-compose.yml | yq -r '.volumes[].driver_opts.device' | tr '\n' '\0' | xargs -0 -I '{}' bash -c 'source <(grep "^DATA_PATH=" .env); mkdir -vp "{}"'`


