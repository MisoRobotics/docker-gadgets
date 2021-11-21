SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:
.NOTPARALLEL:

CMAKE ?= cmake
CPACK ?= cpack
SHDOC ?= shdoc
SUDO ?= sudo

export COLOR ?= 1
export MAKESILENT ?= 0

project_name := docker-gadgets
build := build
sources := $(wildcard *.sh) $(wildcard lib/$(project_name)/*.sh)
docs := $(addprefix doc/,$(notdir $(sources:.sh=.md)))

cmake_args := -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
CMAKE := $(CMAKE) $(cmake_args)

.PHONY: all build clean configure dist doc test

clean: clean-build clean-docs ## Clean all build outputs.

$(build)/CMakeCache.txt:
	@mkdir -pv $(build)/
	$(CMAKE) -S ./ -B $(build)/

help: ## Show usage information for this Makefile.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

configure: $(build)/CMakeCache.txt ## Configure the CMake project.

.PHONY: has-all-deps has-dep-shdoc has-dep-yq-gte-4
has-all-deps: has-dep-shdoc has-dep-yq-gte-4 ## Check for dependencies

has-dep-shdoc: ## Check for shdoc: https://github.com/MisoRobotics/shdoc
	@printf "Checking for shdoc..."
	@which shdoc > /dev/null && echo "found." || (echo "not found." && false)

has-dep-yq-gte-4: ## Check for yq: https://github.com/mikefarah/yq
	@printf "Checking for yq >= 4..."
	@[[ "$(shell yq --version | awk '{print $$NF}' | cut -d. -f1)" -ge "4" ]] \
		&& echo "found." || (echo "not found." && false)

build: configure ## Build the CMake project.
	$(MAKE) -C $(build)/

dist: build doc ## Package the build for distribution.
	cd build && $(CPACK)

doc: has-dep-shdoc $(docs) ## Generate and/or update documentation.

doc/%.md: %.sh
	@mkdir -pv doc/
	$(SHDOC) < $^ > $@
	. lib/docker-gadgets/text-utils.sh && trim-extra-trailing-newlines $@

doc/%.md: lib/$(project_name)/%.sh
	@mkdir -pv doc/
	$(SHDOC) < $^ > $@
	. lib/docker-gadgets/text-utils.sh && trim-extra-trailing-newlines $@

install: dist ## Build and install the package.
	find ./build -maxdepth 1 -name "$(project_name)-*.deb" | xargs $(SUDO) apt-get install -y

test: has-dep-yq-gte-4 ## Run automated unit tests.
	$(MAKE) -C test

.PHONY: clean-docs

get-version: ## Print the version number.
	@cat $(build)/CMakeCache.txt | grep CMAKE_PROJECT_VERSION[:=] | cut -d= -f2

get-package: ## Print the path to the package.
	@pkgs=($(shell ls $(build)/*.deb)) && basename "$${pkgs[@]}"

push: clean dist ## Push the package to the repository.
	gcloud alpha --project=software-builds artifacts apt upload gadgets --location=us --source=$(build)/$(shell $(MAKE) get-package)

clean-docs: ## Clean out changes to documentation.
	if [[ -d doc ]]; then git clean -fxd doc ; git checkout HEAD -f doc/ || true ; fi

clean-build: ## Remove build outputs.
	rm -rf $(build)/
