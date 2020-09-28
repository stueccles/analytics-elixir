# -------------------------------------------
# Common variables
# -------------------------------------------

VERSION_FILE := mix.exs
VERSION := $(shell sed -En "s/^.*@version \"([0-9]*\\.[0-9]*\\.[0-9]*)\"*/\\1/p" ${VERSION_FILE})

BLUE_COLOR := \033[0;34m
DEFAULT_COLOR := \033[0;39m
DIM_COLOR := \033[0;2m
YELLOW_COLOR := \033[0;33m

# -------------------------------------------
# Default task
# -------------------------------------------

.DEFAULT_GOAL := help

.PHONY: help
help: ## Print this help
	@printf "Segment Analytics Elixir ${VERSION}\n"
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "${BLUE_COLOR}%-30s${DEFAULT_COLOR} %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

# -------------------------------------------
# Release task
# -------------------------------------------

CHANGELOG_FILE := CHANGELOG.md
DATE := $(shell date +"%Y-%m-%d")
MAJOR := $(shell echo "${VERSION}" | cut -d . -f1)
MINOR := $(shell echo "${VERSION}" | cut -d . -f2)
PATCH := $(shell echo "${VERSION}" | cut -d . -f3)
REPO_NAME := analytics-elixir
REPO := https:\/\/github.com\/FindHotel\/${REPO_NAME}\/compare

.PHONY: release
release: ## Bump the version and create a new tag
	@printf "${BLUE_COLOR}The current version is:${DEFAULT_COLOR} ${VERSION}\n" && \
	  read -r -p "Do you want to release a [major|minor|patch]: " TYPE && \
	  case "$$TYPE" in \
	  "major") \
	    MAJOR=$$((${MAJOR}+1)); \
	    MINOR="0"; \
	    PATCH="0"; \
	    NEW_VERSION="$$MAJOR.$$MINOR.$$PATCH" \
	    ;; \
	  "minor") \
	    MINOR=$$((${MINOR}+1)); \
	    PATCH="0" && \
	    NEW_VERSION="${MAJOR}.$$MINOR.$$PATCH" \
	    ;; \
	  "patch") \
	    PATCH=$$((${PATCH}+1)); \
	    NEW_VERSION="${MAJOR}.${MINOR}.$$PATCH" \
	    ;; \
	  *) \
	    printf "\\n${YELLOW_COLOR}Release canceled!\n"; \
	    exit 0 \
	    ;; \
	  esac && \
	  printf "${BLUE_COLOR}The new version is:${DEFAULT_COLOR} $$NEW_VERSION\n" && \
	  printf "\t${DIM_COLOR}Updating ${VERSION_FILE} version${DEFAULT_COLOR}\n" && \
	  perl -p -i -e "s/@version \"${VERSION}\"/@version \"$$NEW_VERSION\"/g" ${VERSION_FILE} && \
	  printf "\t${DIM_COLOR}Updating ${CHANGELOG_FILE} version${DEFAULT_COLOR}\n" && \
	  perl -p -i -e "s/## \[Unreleased\]/## \[Unreleased\]\\n\\n## \[$$NEW_VERSION\] - ${DATE}/g" ${CHANGELOG_FILE} && \
          perl -p -i -e "s/${REPO}\/${VERSION}...master/${REPO}\/$$NEW_VERSION...master/g" ${CHANGELOG_FILE} && \
	  perl -p -i -e "s/...master/...master\\n\[$$NEW_VERSION\]: ${REPO}\/${VERSION}...$$NEW_VERSION/g" ${CHANGELOG_FILE} && \
	  printf "\t${DIM_COLOR}Recording changes to the repository${DEFAULT_COLOR}\n" && \
	  git add ${VERSION_FILE} ${CHANGELOG_FILE} && \
	  git commit -m "Bump to $$NEW_VERSION" > /dev/null && \
	  printf "\t${DIM_COLOR}Creating release tag${DEFAULT_COLOR}\n" && \
	  git tag -a -m "" $$NEW_VERSION && \
	  printf "\n${BLUE_COLOR}If everything's ok, push the changes to updstream!${DEFAULT_COLOR}\n"
