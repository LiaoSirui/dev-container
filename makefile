include public.mk

build_base:
	make DOCKERFILE=centos-base/Dockerfile CUSTOM_IMAGE_NAME='base' DOCKER_BUILD_BASE_DIR=./centos-base build

compile_zsh:
	make DOCKERFILE=compile-zsh/Dockerfile CUSTOM_IMAGE_NAME='compile-zsh' DOCKER_BUILD_BASE_DIR=./compile-zsh build

compile_python:
	make DOCKERFILE=compile-python/Dockerfile CUSTOM_IMAGE_NAME='compile-python' DOCKER_BUILD_BASE_DIR=./compile-python build

build_runtime:
	# docker pull docker.io/library/centos:7.9.2009
	make DOCKERFILE=centos-runtime/Dockerfile CUSTOM_IMAGE_NAME='runtime' DOCKER_BUILD_BASE_DIR=./centos-runtime build

build_bigquant:
	# docker pull docker.io/library/centos:7.9.2009
	make DOCKERFILE=centos-bigquant/Dockerfile CUSTOM_IMAGE_NAME='bigquant' DOCKER_BUILD_BASE_DIR=./centos-bigquant build

build_all:
	make build_base build_runtime build_bigquant
