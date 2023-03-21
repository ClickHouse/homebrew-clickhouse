# Homebrew Tap for ClickHouse (by Altinity)

## Available formulae

```text
clickhouse                       - alias, same as clickhouse@stable
clickhouse-client                - alias, same as clickhouse@stable
clickhouse-server                - alias, same as clickhouse@stable

clickhouse@stable                - alias, always points to the latest stable versioned formula (clickhouse@23.2)
clickhouse@lts                   - alias, always points to the latest LTS versioned formula (clickhouse@22.3)
clickhouse@altinity-stable       - alias, always points to the latest Altinity-stable versioned formula (clickhouse@22.3-altinity-stable)

clickhouse@23.2                  - 
clickhouse@22.7                  - the latest release, version: 22.7.2.15-stable
clickhouse@22.6                  - keg-only, version: 22.6.4.35-stable
clickhouse@22.5                  - keg-only, version: 22.5.3.21-stable
clickhouse@22.4                  - keg-only, version: 22.4.6.53-stable
clickhouse@22.3                  - keg-only, version: 22.3.9.19-lts
clickhouse@22.2                  - keg-only, version: 22.2.3.5-stable
clickhouse@22.1                  - keg-only, version: 22.1.4.30-stable
clickhouse@21.12                 - keg-only, version: 21.12.4.1-stable
clickhouse@21.11                 - keg-only, version: 21.11.11.1-stable

clickhouse@22.3-altinity-stable  - keg-only, the latest Altinity-stable release, version: 22.3.8.40-altinitystable
clickhouse@21.8-altinity-stable  - keg-only, Altinity-stable release, version: 21.8.15.15-altinitystable

clickhouse-odbc                  - recommended variant, version: 1.1.10.20210822
clickhouse-cpp                   - recommended variant, version: 2.2.1
```

## Quick start: one-liner

```sh
brew install vantage-sh/clickhouse/clickhouse
```

## Quick start: fine control

First, register the tap (needs to be done only once):

```sh
brew tap vantage-sh/clickhouse
```

Then, install the formula you need:

```sh
brew install clickhouse
# ..or
brew install clickhouse@21.11
# ...and so on.
```

Please, always read the `Caveats` sections, which are displayed after the installation, carefully.

Note, that the installation doesn't require `sudo` and will deploy ClickHouse under the standard Homebrew prefix.

## Running ClickHouse server

Do not use `sudo`, ever. Do not start the ClickHouse server manually, instead use `brew services`:

```sh
brew services start clickhouse
# ..or
brew services start clickhouse@21.11
# ...and so on.
```

ClickHouse is deployed under the standard Homebrew prefix. The relevant directories are:

```text
Config:    $(brew --prefix)/etc/clickhouse-server/
Data:      $(brew --prefix)/var/lib/clickhouse/
Logs:      $(brew --prefix)/var/log/clickhouse-server/
PID file:  $(brew --prefix)/var/run/clickhouse-server/
```

These files and directories will be preserved between installations.

Make sure you stop the server, when upgrading the formula.

If you absolutely need to run ClickHouse server manually, the command that corresponds to `brew services start clickhouse` would be:

```sh
$(brew --prefix clickhouse)/bin/clickhouse server --config-file $(brew --prefix)/etc/clickhouse-server/config.xml --pid-file $(brew --prefix)/var/run/clickhouse-server/clickhouse-server.pid
```

## Versioned formulae

All except the latest versioned ClickHouse formulae are configured as [keg-only](https://docs.brew.sh/FAQ#what-does-keg-only-mean), so in order to refer to an executable from such formula you have to provide the full path to it, e.g.:

```sh
$(brew --prefix clickhouse@21.11)/bin/clickhouse client
```

## Other formulae

This tap also contains its own versions of `clickhouse-odbc` and `clikchouse-cpp` formulae, and in order to install these versions (which we recommend over the default ones), you have to provide the full names to avoid ambiguity, since the default Homebrew registry contains those too:

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

It could take several hours to build ClickHouse from sources, so you will probably want to monitor the progress. To enable verbose output for that scenario, add `--verbose` to `brew install ...`:

```sh
brew install --verbose clickhouse
```

You can also build the latest version (`HEAD`) of the sources for a formula:

```sh
brew install --HEAD --verbose clickhouse
```

The above command will check out the tip of the branch that corresponds to that specific version (e.g., branch [21.11](https://github.com/ClickHouse/ClickHouse/tree/21.11) for `clickhouse@21.11` and so on) and build it from sources.

## Homebrew on Linux (Linuxbrew)

Building the formulae from this tap is not tested in Linux, and bottles are not available, but there are no known conceptual problems, and they should generally work. Feel free to experiment and report any [issues](https://github.com/Altinity/homebrew-clickhouse/issues).

## Adding or updating formulae in this tap (for maintainers only)

Refer to [Maintenance](MAINTENANCE.md) for instructions.

## Useful links

- [Altinity](https://altinity.com/)
- [ClickHouse](https://clickhouse.com/)
- [ClickHouse C++ client library](https://github.com/ClickHouse/clickhouse-cpp)
- [ClickHouse ODBC driver](https://github.com/ClickHouse/clickhouse-odbc)
- [ClickHouse Tableau connector](https://github.com/Altinity/clickhouse-tableau-connector-odbc)
- [Homebrew](https://brew.sh)
