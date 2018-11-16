#!/bin/bash
#
#  make-build.sh
#  Blockchain
#
#  Created by Maurice A. on 11/12/18.
#  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
#
#  Compatibility
#  -------------
#  ‣ This script only runs on macOS using Bash 3.0+
#  ‣ Requires Xcode Command Line Tools.
#

set -eu
set -o pipefail

if ! [ -e "Blockchain.xcodeproj" ]; then
    printf '\e[1;31m%-6s\e[m\n' "Unable to find the Xcode project file. Please ensure you are in the root directory of this project."
    exit 1
fi

if ! [ -x "$(command -v agvtool)" ]; then
  printf '\e[1;31m%-6s\e[m\n' "You are missing the Xcode Command Line Tools. To install them, please run: xcode-select --install."
  exit 1
fi

printf "Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.\n"
printf "You are about to make a new build. Please follow the instructions carefully.\n\n"
printf '\e[1;34m%-6s\e[m\n\n' "\"With Great Power Comes Great Responsibility\" -Voltaire"

read -p "‣ Enter the new value for the project version (e.g. 2.3.4), followed by [ENTER]: " project_version_number

if ! [[ $project_version_number =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  printf '\n\e[1;31m%-6s\e[m\n' "You have entered an invalid version number."
  exit 1
fi

read -p "‣ Next, enter the new value for the project build (e.g. 5), followed by [ENTER]: " project_build_number

if ! [[ $project_build_number =~ ^[0-9]+ ]]; then
  printf '\n\e[1;31m%-6s\e[m\n' "You have entered an invalid build number."
  exit 1
fi

git_tag="v${project_version_number}(${project_build_number})"

if [ $(git tag -l "$git_tag") ]; then
  printf '\n\e[1;31m%-6s\e[m\n' "The version you entered already exists!"
  exit 1
fi

local_branch="ci"
release_branch="release-test"
user_branch=$(git branch | grep \* | cut -d ' ' -f2)
build_number="${project_version_number}.${project_build_number}"
printf "\nPlease review the information about your build below:\n"
printf "Xcode project version to use (CFBundleShortVersionString): ${project_version_number}\n"
printf "Xcode project build number to use (CFBundleVersion): ${build_number}\n"
printf "Git tag to use: ${git_tag}\n\n"
read -p "‣ Would you like to proceed? [y/N]: " answer
if printf "$answer" | grep -iq "^n" ; then
  printf '\e[1;31m%-6s\e[m' "Aborted the build process."
  exit 6
fi
git checkout $release_branch > /dev/null 2>&1
git pull origin $release_branch > /dev/null 2>&1
git merge $local_branch > /dev/null 2>&1
agvtool new-marketing-version $project_version_number > /dev/null 2>&1
agvtool new-version -all $build_number > /dev/null 2>&1
git add .
git commit -m "version bump: ${git_tag}" > /dev/null 2>&1
git tag -s $git_tag -m "Release ${project_version_number}" > /dev/null 2>&1
git push origin $git_tag > /dev/null 2>&1
git push origin $release_branch > /dev/null 2>&1
git-changelog -t $(git describe --abbrev=0) > /dev/null 2>&1
read -p "‣ Would you like to copy the contents of Changelog.md to your clipboard? [y/N]: " answer
if printf "$answer" | grep -iq "^y" ; then
  cat Changelog.md | pbcopy
fi
rm Changelog.md
git checkout $user_branch > /dev/null 2>&1
printf '\n\e[1;32m%-6s\e[m\n' "Everything completed successfully 🎉"
