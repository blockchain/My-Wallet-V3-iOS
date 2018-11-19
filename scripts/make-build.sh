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

if [ -n "$(git status --untracked-files=no --porcelain)" ]; then
  printf '\e[1;31m%-6s\e[m\n' "Making a new build requires that you have a clean git working directory. Please commit your changes or stash them to continue."
  exit 1
fi

if ! [ -e "Blockchain.xcodeproj" ]; then
    printf '\e[1;31m%-6s\e[m\n' "Unable to find the Xcode project file. Please ensure you are in the root directory of this project."
    exit 1
fi

if ! [ -x "$(command -v agvtool)" ]; then
  printf '\e[1;31m%-6s\e[m\n' "You are missing the Xcode Command Line Tools. To install them, please run: xcode-select --install."
  exit 1
fi

printf "You are about to tag, archive, and upload a new build.\n"

git fetch --tags
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
read -p "‣ Enter the new value for the project version (e.g., 2.3.4; latest tag is $latestTag), followed by [ENTER]: " project_version_number

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
printf "Xcode project build number to use (CFBundleVersion): ${project_build_number}\n"
printf "Git tag to use: ${git_tag}\n\n"
printf "Development branch (will be merged into Release branch): ${local_branch}"
printf "Release branch: ${release_branch}"
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
git add Blockchain/Blockchain-Info.plist
git add BlockchainTests/Info.plist
git checkout .
git commit -m "version bump: ${git_tag}" > /dev/null 2>&1
latestTagCommit=$(git show-ref -s $latestTag)
git tag -s $git_tag -m "Release ${project_version_number}" > /dev/null 2>&1
git push origin $git_tag > /dev/null 2>&1
git push origin $release_branch > /dev/null 2>&1
git-changelog -t $latestTagCommit > /dev/null 2>&1
read -p "‣ Would you like to copy the contents of Changelog.md to your clipboard? [y/N]: " answer
if printf "$answer" | grep -iq "^y" ; then
  cat Changelog.md | pbcopy
fi
rm Changelog.md
git checkout $user_branch > /dev/null 2>&1
printf '\n\e[1;32m%-6s\e[m\n' "Script completed successfully 🎉"
printf '\e[1;32m%-6s\e[m\n' "CircleCI is tracking the branch $release_branch."
printf '\e[1;32m%-6s\e[m\n' "Please check Jobs in CircleCI to view the progress of tests, archiving, and uploading the build."
