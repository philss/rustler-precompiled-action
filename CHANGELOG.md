# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[v1.1.0]: https://github.com/philss/rustler-precompiled-action/compare/v1.0.1...v1.1.0
[v1.0.1]: https://github.com/philss/rustler-precompiled-action/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/philss/rustler-precompiled-action/releases/tag/v1.0.0
