#!/bin/bash

# We don't need return codes for "$(command)", only stdout is needed.
# Allow `[[ -n "$(command)" ]]`, `func "$(command)"`, pipes, etc.
# shellcheck disable=SC2312

set -u

source utils/setup

directories=(
  .npup
  bin etc lib sbin share var opt
  Cellar Caskroom Frameworks Gems
)

mkdirs=()
for dir in "${directories[@]}"
do
  if ! [[ -d "${NEXT_PREFIX}/${dir}" ]]
  then
    mkdirs+=("${NEXT_PREFIX}/${dir}")
  fi
done

if [[ "${#mkdirs[@]}" -gt 0 ]]
then
  execute_sudo "${MKDIR[@]}" "${mkdirs[@]}"
  execute_sudo "${CHMOD[@]}" "ug=rwx" "${mkdirs[@]}"
  execute_sudo "${CHOWN[@]}" "${USER}" "${mkdirs[@]}"
  execute_sudo "${CHGRP[@]}" "${GROUP}" "${mkdirs[@]}"
fi

if ! [[ -d "${NEXT_REPOSITORY}" ]]
then
  execute_sudo "${MKDIR[@]}" "${NEXT_REPOSITORY}"
fi
execute_sudo "${CHOWN[@]}" "-R" "${USER}:${GROUP}" "${NEXT_REPOSITORY}"

ohai "Downloading and installing NextPangea..."
(
    cd "${NEXT_REPOSITORY}" >/dev/null || return

    # we do it in four steps to avoid merge errors when reinstalling
    execute "git" "-c" "init.defaultBranch=master" "init" "--quiet"

    # "git remote add" will fail if the remote is defined in the global config
    execute "git" "config" "remote.origin.url" "${NEXT_GIT_REMOTE}"
    execute "git" "config" "remote.origin.fetch" "+refs/heads/*:refs/remotes/origin/*"

    # ensure we don't munge line endings on checkout
    execute "git" "config" "--bool" "core.autocrlf" "false"

    # make sure symlinks are saved as-is
    execute "git" "config" "--bool" "core.symlinks" "true"

    if [[ -z "${NONINTERACTIVE-}" ]]
    then
        quiet_progress=("--quiet" "--progress")
    else
        quiet_progress=("--quiet")
    fi
    retry 5 "git" "fetch" "${quiet_progress[@]}" "--force" "origin"
    retry 5 "git" "fetch" "${quiet_progress[@]}" "--force" "--tags" "origin"

    execute "git" "remote" "set-head" "origin" "--auto" >/dev/null

    LATEST_GIT_TAG="$("git" tag --list --sort="-version:refname" | head -n1)"
    if [[ -z "${LATEST_GIT_TAG}" ]]
    then
        abort "Failed to query latest np Git tag."
    fi
    execute "git" "checkout" "--quiet" "--force" "-B" "stable" "${LATEST_GIT_TAG}"

    if [[ "${NEXT_REPOSITORY}" != "${NEXT_PREFIX}" ]]
    then
        if [[ "${NEXT_REPOSITORY}" == "${NEXT_PREFIX}/np" ]]
        then
        execute "ln" "-sf" "../np/bin/np" "${NEXT_PREFIX}/bin/np"
        else
        abort "The np repository should be placed in the np prefix directory."
        fi
    fi
)

ohai "Installation successful!"

ring_bell
