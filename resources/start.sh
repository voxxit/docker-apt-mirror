#!/bin/bash

cat > mirrors.list <<-EOF
set base_path         ${BASE_PATH}
set mirror_path       ${MIRROR_PATH}
set skel_path         ${SKEL_PATH}
set var_path          ${VAR_PATH}
set defaultarch       ${DEFAULTARCH}

# Post-mirror script - runs after mirroring; useful for rsync, etc.
set postmirror_script ${POSTMIRROR_SCRIPT}
set run_postmirror    ${RUN_POSTMIRROR}

# How many threads you want, and whether or not to run in the home directory
set nthreads          ${NTHREADS}
set _tilde            ${TILDE}

# Use --unlink with wget (for use with hardlinked directories)
set unlink            ${UNLINK}

# Proxy settings
set use_proxy         ${USE_PROXY}
set http_proxy        ${HTTP_PROXY}
set proxy_user        ${PROXY_USER}
set proxy_password    ${PROXY_PASSWORD}

EOF

# Environment variables; helps build the /etc/apt/mirrors.list sources for you...
declare -a distros=(${MIRROR_DISTROS})
declare -a flavors=(${MIRROR_FLAVORS})
declare -a branches=(${MIRROR_BRANCHES})

for distro in "${distros[@]}"; do
  for flavor in "${flavors[@]}"; do
    echo "deb ${MIRROR_PROTO}://${MIRROR_HOST}/${distro} ${flavor} ${MIRROR_COMPONENTS}" | tee -a /etc/apt/mirrors.list

    if [ ! -z ${MIRROR_INCLUDE_SOURCE} ]; then
      echo "deb-src ${MIRROR_PROTO}://${MIRROR_HOST}/${distro} ${flavor} ${MIRROR_COMPONENTS}" | tee -a /etc/apt/mirrors.list
    fi

    for branch in "${branches[@]}"; do
      echo "deb ${MIRROR_PROTO}://${MIRROR_HOST}/${distro} ${flavor}-${branch} ${MIRROR_COMPONENTS}" | tee -a /etc/apt/mirrors.list

      if [ ! -z ${MIRROR_INCLUDE_SOURCE} ]; then
        echo "deb-src ${MIRROR_PROTO}://${MIRROR_HOST}/${distro} ${flavor}-${branch} ${MIRROR_COMPONENTS}" | tee -a /etc/apt/mirrors.list
      fi
    done
  done
  
  echo "clean ${MIRROR_PROTO}://${MIRROR_HOST}/${distro}" | tee -a /etc/apt/mirrors.list
done

exec /usr/bin/apt-mirror
