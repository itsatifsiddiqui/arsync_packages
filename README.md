# Arsync Packages

A monorepo for Arsync Flutter packages.

## Packages

- [arsync_exception_toolkit](./packages/arsync_exception_toolkit/README.md) - A flexible exception handling system for Flutter applications

## Getting Started

This repository uses [Melos](https://github.com/invertase/melos) to manage the monorepo.

### Setup

1. Install Melos:
   ```
   dart pub global activate melos
   ```

2. Bootstrap the project:
   ```
   melos bootstrap
   ```

### Commands

- `melos run analyze` - Run analyzer in all packages
- `melos run format` - Run formatter in all packages
- `melos run test` - Run tests in all packages
- `melos run build` - Build all packages
- `melos run clean` - Clean all packages