# Melos Monorepo Example

This project is a Flutter monorepo managed with **Melos**.

## Overview

- Contains **2 Flutter apps**:
  - `apps/demo`
  - `apps/demo_2`
- Contains shared packages:
  - `packages/core` for common theme and colors
  - `packages/design_system` for reusable UI components
- Both apps use the same shared `PrimaryButton`.
- On button click, each app shows:
  - A message in the center
  - A counter value that increments

## Monorepo Structure

```text
melos_example/
  apps/
    demo/
    demo_2/
  packages/
    core/
    design_system/
  melos.yaml
  pubspec.yaml
```

## Shared Packages

### `core`

- Exposes shared app theme and colors.
- Used by both apps and `design_system`.

### `design_system`

- Exposes `PrimaryButton`.
- Uses shared colors from `core`.

## Getting Started

Run from the root folder:

```bash
flutter pub get
```

Optional Melos scripts:

```bash
melos run bootstrap
melos run analyze
melos run run:demo
melos run run:demo2
```

## Learning Goal

This repository is created to learn:

- Flutter monorepo setup
- Melos workspace management
- Sharing common UI and theme across multiple apps
