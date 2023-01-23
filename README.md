# Rustler Precompiled Action

:warning: - **Please do not use this project yet. It's under construction.**"

This is a GitHub Action that builds library crates conditionally using [cross],
and renames the final library file to the naming expected by [RustlerPrecompiled].

It's **important to notice that this Action won't install Rust**. So you need to
install it first.

## Inputs

The following inputs are accepted:

| Name              | Description   | Required | Default   |
|-------------------|---------------|----------|-----------|
| `project-name`    |  Name of the crate that is being built. This is the same of the Cargo.toml of the crate.    | true  |   |
| `project-version` |  The version to use in the name of the lib. This mostly matches the Elixir package version. | true  |   |
| `target`          |  The Rust target we are building to. | true  |   |
| `nif-version`     |  The NIF version that we are aiming to. | false   | `"2.16"`  |
| `use-cross`       |  If the target requires the usage of cross. | false   |   |
| `cross-version`   |  The version desired for cross, the tool that builds for multiple plataforms. | false  | `"v0.2.4"`  |
| `project-dir`   |  A relative path where the project is located. | true | "./" |

## Outputs

| Name        | Description |
|-------------|-------------|
| `file-name` | The name of the tarball file for this build |
| `file-path` | The full path of the tarball file for this build |

## License

Copyright 2023 Philip Sampaio

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[cross]: https://github.com/cross-rs/cross
[RustlerPrecompiled]: https://github.com/philss/rustler_precompiled
