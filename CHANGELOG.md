# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.1.3] - 2023-10-27

### Fixed

- Revert the latest release due to a bug introduced: it was not possible to
  install `cross`.

## [v1.1.2] - 2023-10-27

### Fixed

- Explicitly check for `use-cross` to be equal to `true` in order to execute the
  "cross" branch blocks.
  This is going to prevent the block to be executed for any value that is not "true".

## [v1.1.1] - 2023-10-17

### Added

- Add option to install `cross` from source.
  Using the string "from-source" instead of a version will install "cross" from
  the GitHub repository.

## [v1.1.0] - 2023-09-22

### Added

- Add support for the `:variant` option. This is a way to build alternative versions
  for the same target. The idea is to build for different dependencies, or with different
  features.

  This feature is compatible with `RustlerPrecompiled` since version 0.7.
  See: https://github.com/philss/rustler_precompiled/releases/tag/v0.7.0

- Add the `:cargo-args` option. It enables the users to pass arbitrary flags
  to the `cargo build` command (this may be `cross build` sometimes).

- Support the `RUSTFLAGS` environment variable. It pass down options to the
  Rust compiler.

  Normally this env var is not needed, since it's possible to configure the
  same flags by configuring the `.cargo/config.toml` file in your project.

  Be aware that you need to set this env var before using this GitHub Action.
  It is also required to configure the `Cross.toml` file to read this env var.
  See the [guide](https://hexdocs.pm/rustler_precompiled/precompilation_guide.html)
  for details

- Add two env vars to make easier to debug:
  - `RUSTLER_PRECOMPILED_DEBUG_MODE`: sets the compilation profile to "debug" instead
    of the default "release".
  - `DRY_RUN`: avoid to run the build command, and instead print what would be executed.

- Support Rustler NIF version selection by cargo features.

  This makes the selection of the NIF version work for projects using Rustler
  above version 0.29. The `RUSTLER_NIF_VERSION` is deprecated since that version,
  and was removed in the v0.30 of Rustler.

  The build script is going to detect which cargo features the project has declared
  that are related to NIF versions. It is going to take the same naming used by
  Rustler - e.g. `nif_version_2_15`. If the project has declared any "version features",
  the build script is going to activate the correct version based on the `:nif-version`
  input of the GitHub Action.

  See the update from Rustler: https://github.com/rusterlium/rustler/blob/master/UPGRADE.md#028---029
  And also the RustlerPrecompiled guide: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html#additional-configuration-before-build

## [v1.0.1] - 2023-03-27

### Fixed

- Fix missing export of `RUSTLER_NIF_VERSION` env var, that is needed to tell Rustler
  which version of NIF to use.

  This fix also includes a check to see if this env var is present in the `Cross.toml`
  file. If isn't, then we fail the build and print an error message. So people must
  use the `Cross.toml` to tell cross to passthrough this env var.

  An example of this file is the following:

  ```toml
  [build.env]
  passthrough = [
    "RUSTLER_NIF_VERSION"
  ]
  ```

  The `Cross.toml` must be in the same directory of the Rust project that represents
  the NIF.

## [v1.0.0] - 2023-01-23

### Added

- Added all needed for the first release. See the README.md for a full description
  of inputs and outputs.

[v1.1.3]: https://github.com/philss/rustler-precompiled-action/compare/v1.1.2...v1.1.3
[v1.1.2]: https://github.com/philss/rustler-precompiled-action/compare/v1.1.1...v1.1.2
[v1.1.1]: https://github.com/philss/rustler-precompiled-action/compare/v1.1.0...v1.1.1
[v1.1.0]: https://github.com/philss/rustler-precompiled-action/compare/v1.0.1...v1.1.0
[v1.0.1]: https://github.com/philss/rustler-precompiled-action/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/philss/rustler-precompiled-action/releases/tag/v1.0.0
