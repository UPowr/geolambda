#!/bin/bash
set -e
VERSION=$(cat VERSION)

INTERACTIVE=$(if test -t 0; then echo -i; fi)

declare -a depot_opts=()
if build.sh get depot-installed >/dev/null; then
	depot_opts=(--load)
fi

docker build --platform linux/amd64 . -t developmentseed/geolambda:${VERSION} "${depot_opts[@]}"
docker run --rm -v $PWD:/home/geolambda ${INTERACTIVE} -t developmentseed/geolambda:${VERSION} package.sh

cd python
docker build . --platform linux/amd64 --build-arg VERSION=${VERSION} -t developmentseed/geolambda:${VERSION}-python "${depot_opts[@]}"
docker run -v ${PWD}:/home/geolambda -t developmentseed/geolambda:${VERSION}-python package-python.sh

docker run --rm -e PROJ_LIB=/opt/share/proj -v ${PWD}/lambda:/var/task -v ${PWD}/../lambda:/opt lambci/lambda:python3.7 lambda_function.lambda_handler '{}'
