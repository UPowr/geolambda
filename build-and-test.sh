#!/bin/bash
set -e
VERSION=$(cat VERSION)
INTERACTIVE=$(if test -t 0; then echo -i; fi)
DOCKER_PLATFORM_OPT=${DOCKER_PLATFORM_OPT:---platform linux/amd64}

declare -a depot_opts=()
if build.sh get depot-installed >/dev/null; then
	depot_opts=(--load)
fi

docker build ${DOCKER_PLATFORM_OPT} . -t developmentseed/geolambda:${VERSION} "${depot_opts[@]}"
docker run ${DOCKER_PLATFORM_OPT}  --rm -v $PWD:/home/geolambda ${INTERACTIVE} -t developmentseed/geolambda:${VERSION} package.sh

cd python
docker build . ${DOCKER_PLATFORM_OPT} --build-arg VERSION=${VERSION} -t developmentseed/geolambda:${VERSION}-python "${depot_opts[@]}"
docker run ${DOCKER_PLATFORM_OPT}  -v ${PWD}:/home/geolambda -t developmentseed/geolambda:${VERSION}-python package-python.sh

docker run --rm -e PROJ_LIB=/opt/share/proj -v ${PWD}/lambda:/var/task -v ${PWD}/../lambda:/opt lambci/lambda:python3.7 lambda_function.lambda_handler '{}'
