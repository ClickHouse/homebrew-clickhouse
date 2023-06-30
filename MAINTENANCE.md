# Maintenance

## Overview

When adding or upgrading a formula, the GitHub Actions workflows for this tap are configured to build, test, and register the bottles automatically.

Currently, the workflows require the availability of these 2 runners:

```text
macos-monterey-x86_64  - tags: self-hosted macOS x86_64 x64 homebrew monterey
macos-monterey-arm64   - tags: self-hosted macOS arm64 homebrew monterey
```

In a nutshell, the following steps need to be taken:

- [setup and start](#setting-up-the-runners) the GitHub Actions runners, if [not started](https://github.com/Altinity/homebrew-clickhouse/settings/actions/runners) already
- [add a new](#adding-a-new-formula) or [upgrade an existing](#upgrading-an-existing-formula) formula

## Setting up the runners

In fresh (or, at least, believed to be in a good shape) macOS Monterey (version 12) systems (Intel + Apple silicon):

- (try to) uninstall Homebrew by executing the command (clean up any reported residues manually): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"`
- install Homebrew by executing the command: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- for Intel:
  - unpack the standalone portable `golang` distribution under `/opt/go/...`: [go1.18.darwin-amd64.tar.gz](https://go.dev/dl/go1.18.darwin-amd64.tar.gz) (or newer)
  - unpack the standalone portable `node` distribution under `/opt/node/...`: [node-v16.14.2-darwin-x64.tar.gz](https://nodejs.org/dist/v16.14.2/node-v16.14.2-darwin-x64.tar.gz) (or newer)
- for Apple silicon:
  - unpack the standalone portable `golang` distribution under `/opt/go/...`: [go1.18.darwin-arm64.tar.gz](https://go.dev/dl/go1.18.darwin-arm64.tar.gz) (or newer)
  - unpack the standalone portable `node` distribution under `/opt/node/...`: [node-v16.14.2-darwin-arm64.tar.gz](https://nodejs.org/dist/v16.14.2/node-v16.14.2-darwin-arm64.tar.gz) (or newer)
- clone the alternative GitHub Actions runner: `git clone https://github.com/ChristopherHX/github-act-runner.git --recursive /opt/github-act-runner`
- [allocate a runner token](https://github.com/Altinity/homebrew-clickhouse/settings/actions/runners/new) for each machine (it is OK to select `x64` for a `arm64` runner at this point)
- `cd /opt/github-act-runner` on each machine
- for Intel:
  - configure the runner (adjust the token): `PATH=/opt/go/bin:/opt/node/bin:$PATH go run . configure --url https://github.com/Altinity/homebrew-clickhouse --token XXXXXXXXXXXXXXXXXXXXXXXXXXXX --name macos-monterey-x86_64 --no-default-labels -l self-hosted,macOS,x86_64,x64,homebrew,monterey --replace`
- for Apple silicon:
  - configure the runner (adjust the token): `PATH=/opt/go/bin:/opt/node/bin:$PATH go run . configure --url https://github.com/Altinity/homebrew-clickhouse --token XXXXXXXXXXXXXXXXXXXXXXXXXXXX --name macos-monterey-arm64 --no-default-labels -l self-hosted,macOS,arm64,homebrew,monterey --replace`
- start the runner on each machine: `PATH=/opt/go/bin:/opt/node/bin:$PATH go run . run`
- [make sure](https://github.com/Altinity/homebrew-clickhouse/settings/actions/runners) the runners are online and in `idle` state

## Adding a new formula

### Adding a new non-ClickHouse formula

Use `Formula/clickhouse-odbc.rb` or `Formula/clickhouse-cpp.rb` formulae as a template:

- step 1: prepare the new formula
  - create a dedicated branch in the repo, do not use forks, make the branch in the original repo (TODO: fix permission issues with workflows modifying the upstream)
  - create a new file `Formula/myformula.rb`, this **must be the only** file changed in the branch
  - for a better idea of what needs to be changed, compare `Formula/clickhouse-odbc.rb` and `Formula/clickhouse-cpp.rb`, then in your new formula:
    - adjust the class name to match the formula name
    - adjust the `url.tag`, `url.revision`, and `head.branch` values accordingly
    - adjust the `regex` expression in the `livecheck do .. end` section to properly match the versions during `livecheck`
    - remove the `bottle do ... end` section remained from the old template, this will be recreated automatically later
    - remove the `keg_only :versioned_formula` line remained from the old template, if any
    - adjust the configure/build flags and steps
  - make a PR from this branch into `main`, use `myformula XX.XX.XX.XX (new formula)` caption and an empty description (adjust the version)
  - wait until all checks are green in the GitHub PR page, during which bottles will be created and uploaded as artifacts in GitHub
  - once all checks are green, add `pr-pull` tag on the PR, this will trigger another action that will modify the formula, register the bottles in it, and will close (but not merge!) the PR; even though the PR will be shown as closed, the branch will be merged into `main` and the new formula with bottles will be available to the users (they will need to do `brew update` to see the changes)
- step 2: adjust the `README.md`
  - as a separate commit directly into `main` of the upstream:
    - add entries about the new formula in the `README.md`

### Adding a new (versioned) ClickHouse formula

Use the latest `Formula/clickhouse@YY.YY.rb` formulae as a template:

- step 1: register the new formula as an audit exception, to skip `non-master head branch` audit warnings
  - as a separate commit directly into `main` of the upstream, add the name of the formula at the top of the list in `audit_exceptions/head_non_default_branch_allowlist.json`
- step 2: prepare the new formula
  - create a dedicated branch in the repo, do not use forks, make the branch in the original repo (TODO: fix permission issues with workflows modifying the upstream)
  - create a new file `Formula/clickhouse@XX.XX.rb` following the pattern of the latest formula, this **must be the only** file changed in the branch
  - for a better idea of what needs to be changed, compare one of the older versioned formulae with the current latest formula, then in your new formula:
    - adjust the class name to match the formula name
    - adjust the `url.tag`, `url.revision`, and `head.branch` values accordingly
    - adjust the `regex` expression in the `livecheck do .. end` section to properly match the new versions during `livecheck`
    - remove the `bottle do ... end` section remained from the old template, this will be recreated automatically later
    - remove the `keg_only :versioned_formula` line remained from the old template, if any (assuming, you are adding a latest version of ClickHouse)
    - adjust the configure/build flags and steps, if needed
  - make a PR from this branch into `main`, use `clickhouse@XX.XX XX.XX.XX.XX (new formula)` caption and an empty description (adjust the versions)
  - wait until all checks are green in the GitHub PR page, during which bottles will be created and uploaded as artifacts in GitHub
  - once all checks are green, add `pr-pull` tag on the PR, this will trigger another action that will modify the formula, register the bottles in it, and will close (but **not** merge!) the PR; even though the PR will be shown as closed, the branch will be merged into `main` and the new versioned formula with bottles will be available to the users (they will need to do `brew update` to see the changes)
- step 3: adjust the `README.md` and aliases
  - as a separate commit directly into `main` of the upstream:
    - add a `keg_only :versioned_formula` line to the previous latest versioned formula (the one you used as a template) right after the `bottle do ... end` section (compare with the older formulae for examples)
    - change all the relevant symlinks under `Aliases/...` to point to the new formula (NB: stable vs lts)
    - add entries about the new versioned formula in the `README.md` and adjust all other references in the text to reflect the changes

## Upgrading an existing formula

Use `brew livecheck ...` and `brew bump-formula-pr ...` to automatically detect and create a PR with a newer version of the formula, if available:

- make sure you have an up-to-date Homebrew installation locally, and the tap is added to it
- run `brew livecheck altinity/clickhouse/clickhouse@21.11` locally to see if a new version of the software is available (adjust version/formula name as needed), write down the new version, if any, as reported by `brew livecheck ...` - you will use it in the next steps
- make sure you have a valid `GITHUB_TOKEN` and `HOMEBREW_GITHUB_API_TOKEN` in your `env` so that you will be able to push the changes made to the tap repo clone stored in your local brew's internal directories
- run `brew bump-formula-pr altinity/clickhouse/clickhouse@21.11 --version=21.11.11.1 --no-fork`, it will create a PR with the new version (here `21.11.11.1`, as an example of a version that `brew livecheck ...` detected as one to upgrade to)
- wait until all checks are green in the GitHub PR page, during which bottles will be created and uploaded as artifacts in GitHub
- once all checks are green, add `pr-pull` tag on the PR, this will trigger another action that will modify the formula, register the bottles in it, and will close (but **not** merge!) the PR; even though the PR will be shown as closed, the branch will be merged into `main` and the new version of the formula with bottles will be available to the users (they will need to do `brew update` to see the changes)
- as a separate commit directly into `main` of the upstream:
  - adjust the relevant version number in `README.md` to reflect the changes

## Manually updating a formula

```
brew tap clickhouse/clickhouse
cd $(brew --repository clickhouse/clickhouse)
export HOMEBREW_NO_INSTALL_FROM_API=1
# copy latest formula and edit it
# brew install --verbose --build-from-source clickhouse/clickhouse/clickhouse@23.5 # for verification, doesn't bottle
brew install --build-bottle clickhouse/clickhouse/clickhouse@23.5 && brew bottle clickhouse/clickhouse/clickhouse@23.5
# make a new release with `gh release create`, then upload the bottle
# push formula to homebrew
```
