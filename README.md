# ClickHouse Homebrew tap (by Altinity)

## Available formulae

```text
clickhouse

clickhouse@21.11 (keg-only)
clickhouse@21.12 (keg-only)

clickhouse-cpp (special variant)
clickhouse-odbc (special variant)
```

## Quick start: one-liner

```sh
brew install altinity/clickhouse/clickhouse
```

## Quick start: fine control

First, register the tap (needs to be done only once):

```sh
brew tap altinity/clickhouse
```

Then, install the formula you need:

```sh
brew install clickhouse
# ..or
brew install clickhouse@21.11
# ...and so on.
```

Please, always carefully read the `Caveats` sections, which is displayed after the installation.

Note, that the installation doesn't require `sudo` and will deploy ClickHouse under the standard Homebrew prefix.

### Running ClickHouse server

Do not use `sudo` ever. Do not start the ClickHouse server manually, instead use `brew services`:

```sh
brew services start clickhouse
# ..or
brew services start clickhouse@21.11
# ...and so on.
```

ClickHouse is deployed under the standard Homebrew prefix. The relevant directories are:

```text
Config:   $(brew --prefix)/etc/clickhouse-server/
Data:     $(brew --prefix)/var/lib/clickhouse/
Logs:     $(brew --prefix)/var/log/clickhouse-server/
PID file: $(brew --prefix)/var/run/clickhouse-server/
```

These files and directories will be preserved between installations.

Make sure you stop the server, when upgrading the formula.

If you absolutely need to run ClickHouse server manually, the command that corresponds to `brew services start clickhouse` would be:

```sh
$(brew --prefix clickhouse)/bin/clickhouse server --config-file $(brew --prefix)/etc/clickhouse-server/config.xml --pid-file $(brew --prefix)/var/run/clickhouse-server/clickhouse-server.pid
```

### Versioned formulae

The versioned formulae are configured as [keg-only](https://docs.brew.sh/FAQ#what-does-keg-only-mean), so to run them specifically, you have to provide the full path to the executables, e.g.:

```sh
$(brew --prefix clickhouse@21.11)/bin/clickhouse client ...
```

### Aliases

The following aliases are defined and can be used:

```sh
brew install clickhouse-client # same as: 'brew install clickhouse'
brew install clickhouse-server # same as: 'brew install clickhouse'
brew install clickhouse@stable # same as: 'brew install clickhouse@21.12' (or whatever the latest stable versioned formula is)
```

## Other formulae

This tap also contains its own versions of `clickhouse-odbc` and `clikchouse-cpp` formulae, and in order to install these versions (which we recommend over the default ones), you have to provide the full names, since the default Homebrew registry contains those too:

```sh
brew install altinity/clickhouse/clickhouse-odbc
brew install altinity/clickhouse/clickhouse-cpp
```

## Pre-built binary packages (bottles)

Bottles for the following platforms are available:

```text
macOS Monterey (version 12) on Intel
macOS Monterey (version 12) on Apple silicon
```

Eventually, this list will be extended to also contain some of the previous versions of macOS.

## Building (the latest versions) from sources

Formulae will be built from sources automatically if the corresponding bottles are not available for your platform.

If you want to see the progress, add `--verbose`:

```sh
brew install --verbose clickhouse
```

You can also build the latest version (`HEAD`) of the sources for a formula:

```sh
brew install --HEAD --verbose clickhouse
```

The above command will check out the `master` branch of the official ClickHouse repo and build it. For versioned formulae, the tip of the branch that correspond to that specific version will be checked out (e.g., branch `21.11` for `clickhouse@21.11` and so on).

## Homebrew on Linux (Linuxbrew)

Building the formulae from this tap is not tested in Linux, and bottles are not available, but there are no known conceptual problems, and they should generally work. Feel free to experiment and report any [issues](https://github.com/Altinity/homebrew-clickhouse/issues).

## Useful links

- [ClickHouse](https://clickhouse.com/)
- [ClickHouse C++ client library](https://github.com/ClickHouse/clickhouse-cpp)
- [ClickHouse ODBC driver](https://github.com/ClickHouse/clickhouse-odbc)
- [ClickHouse Tableau connector](https://github.com/Altinity/clickhouse-tableau-connector-odbc)
- [Homebrew](https://brew.sh)
