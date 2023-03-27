# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[v1.0.1]: https://github.com/philss/rustler-precompiled-action/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/philss/rustler-precompiled-action/releases/tag/v1.0.0
