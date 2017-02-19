FROM ubuntu

RUN  apt-get update \
  && apt-get install -y apt-mirror rsync \
  && rm -rf /var/lib/apt/lists/*

ENV BASE_PATH		/var/spool/apt-mirror
ENV MIRROR_PATH		${BASE_PATH}/mirror
ENV SKEL_PATH		${BASE_PATH}/skel
ENV VAR_PATH		${BASE_PATH}/var
ENV POSTMIRROR_SCRIPT	${VAR_PATH}/post-mirror.sh
ENV RUN_POSTMIRROR	1
ENV NTHREADS		20
ENV TILDE		0
ENV DEFAULTARCH		x86_64
ENV UNLINK		1
ENV USE_PROXY		off

# Can be http, rsync or ftp
ENV MIRROR_PROTO 	http

# Choose a local mirror containing _both_ distros (see below)
ENV MIRROR_HOST		archive.ubuntu.com

# Space-separated list of...
ENV MIRROR_DISTROS	"ubuntu"
ENV MIRROR_FLAVORS	"trusty"
ENV MIRROR_BRANCHES	"security updates proposed backports"
ENV MIRROR_COMPONENTS	"main restricted universe multiverse"

VOLUME ${BASE_PATH}

COPY resources/apt/post-mirror.sh ${VAR_PATH}/
COPY resources/start.sh /start.sh

ENTRYPOINT ["/start.sh"]
