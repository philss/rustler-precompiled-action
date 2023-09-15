# Rustler Precompiled Action

This is a GitHub Action that builds library crates conditionally using [cross],
and renames the final library file to the naming expected by [RustlerPrecompiled].

It's **important to notice that this Action won't install Rust**. So you need to
install it first. For that we recommend the [dtolnay/rust-toolchain] action that
is well maintained.

See the [RustlerPrecompiled's guide] before trying to setup your project, because
there is a lot of things **you must configure in your project** before using this
GH Action.

## Usage

```yaml
- name: Build the project
  id: build
  uses: philss/rustler-precompiled-action@v1.0.1
  with:
    project-name: example
    project-version: "0.5.2"
    target: aarch64-unknown-linux-gnu
    nif-version: "2.16"
    use-cross: true
    project-dir: "native/example"
```

See the example workflow below.

## Inputs

The following inputs are accepted:

| Name              | Description                                                           | Required | Default    |
|-------------------|-----------------------------------------------------------------------|----------|------------|
| `cross-version`   |  The version desired for cross. Only relevant if `use-cross` is true. | false    | `"v0.2.4"` |
| `nif-version`     |  The NIF version that we are aiming to.                               | false    | `"2.16"`   |
| `project-dir`     |  A relative path where the project is located.                        | true     | `"./"`     |
| `project-name`    |  Name of the crate that is being built. Same as in Cargo.toml         | true     |            |
| `project-version` |  The version of the Elixir package that the crate is in.              | true     |            |
| `target`          |  The Rust target we are building to.                                  | true     |            |
| `use-cross`       |  If the target requires the usage of cross.                           | false    |            |

## Outputs

| Name          | Description                                       |
|---------------|---------------------------------------------------|
| `file-name`   | The name of the tarball file for this build.      |
| `file-path`   | The full path of the tarball file for this build. |
| `file-sha256` | The SHA256 of the tarball file.                   |

## Example

Here is an example extracted from the [RustlerPrecompiledExample] project:

```yaml
name: Build precompiled NIFs

on:
  push:
    branches:
      - main
    tags:
      - '*'

jobs:
  build_release:
    name: NIF ${{ matrix.nif }} - ${{ matrix.job.target }} (${{ matrix.job.os }})
    runs-on: ${{ matrix.job.os }}
    strategy:
      fail-fast: false
      matrix:
        nif: ["2.15"]
        job:
          - { target: aarch64-apple-darwin        , os: macos-11      }
          - { target: aarch64-unknown-linux-gnu   , os: ubuntu-20.04 , use-cross: true }
          - { target: aarch64-unknown-linux-musl  , os: ubuntu-20.04 , use-cross: true }
          - { target: arm-unknown-linux-gnueabihf , os: ubuntu-20.04 , use-cross: true }
          - { target: riscv64gc-unknown-linux-gnu , os: ubuntu-20.04 , use-cross: true }
          - { target: x86_64-apple-darwin         , os: macos-11      }
          - { target: x86_64-pc-windows-gnu       , os: windows-2019  }
          - { target: x86_64-pc-windows-msvc      , os: windows-2019  }
          - { target: x86_64-unknown-linux-gnu    , os: ubuntu-20.04  }
          - { target: x86_64-unknown-linux-musl   , os: ubuntu-20.04 , use-cross: true }

    steps:
    - name: Checkout source code
      uses: actions/checkout@v3

    - name: Extract project version
      shell: bash
      run: |
        # Get the project version from mix.exs
        echo "PROJECT_VERSION=$(sed -n 's/^  @version "\(.*\)"/\1/p' mix.exs | head -n1)" >> $GITHUB_ENV

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable
      with:
        toolchain: stable
        target: ${{ matrix.job.target }}

    - name: Build the project
      id: build-crate
      uses: philss/rustler-precompiled-action@v1.0.0
      with:
        project-name: example
        project-version: ${{ env.PROJECT_VERSION }}
        target: ${{ matrix.job.target }}
        nif-version: ${{ matrix.nif }}
        use-cross: ${{ matrix.job.use-cross }}
        project-dir: "native/example"

    - name: Artifact upload
      uses: actions/upload-artifact@v3
      with:
        name: ${{ steps.build-crate.outputs.file-name }}
        path: ${{ steps.build-crate.outputs.file-path }}

    - name: Publish archives and packages
      uses: softprops/action-gh-release@v1
      with:
        files: |
          ${{ steps.build-crate.outputs.file-path }}
      if: startsWith(github.ref, 'refs/tags/')

```

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
[RustlerPrecompiledExample]: https://github.com/philss/rustler_precompilation_example 
[dtolnay/rust-toolchain]: https://github.com/dtolnay/rust-toolchain
[RustlerPrecompiled's guide]: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html
