# Repository Guidelines

## Project Structure & Module Organization

This workspace is intended for the `fiscal` MATLAB project. Keep source code in `src/`, tests in `tests/`, examples or exploratory scripts in `examples/`, and reusable data or fixtures in `data/` only when they are small enough to version. Put generated outputs, reports, caches, and large local datasets outside the repository or under an ignored `output/` directory.

Use package folders when behavior grows beyond a few standalone functions, for example `src/+fiscal/calculateTax.m`. Keep public entry points shallow and place helpers next to the code that owns them.

## Build, Test, and Development Commands

- `matlab -batch "addpath('src'); runtests('tests')"` runs the MATLAB test suite from a clean command-line session.
- `matlab -batch "checkcode('src','-cyc')"` runs MATLAB Code Analyzer checks for source files, including cyclomatic complexity.
- `matlab -batch "run('examples/exampleName.m')"` runs a specific example script locally.

Prefer command-line MATLAB runs for repeatable validation before opening a pull request.

## Coding Style & Naming Conventions

Use 4-space indentation in MATLAB files. Name functions and methods with lower camel case, such as `loadFiscalData`, and name classes with upper camel case, such as `FiscalCalendar`. Test classes should end in `Test`, and test methods should describe behavior, for example `testRejectsInvalidFiscalYear`.

Keep one primary function or class per `.m` file, with the filename matching the public symbol. Avoid hard-coded absolute paths; build paths with `fullfile` and anchor them from the project root when possible.

## Testing Guidelines

Use `matlab.unittest` for automated tests. Place tests under `tests/`, mirroring the source package when useful, such as `tests/+fiscal/FiscalCalendarTest.m`. Add focused tests for boundary dates, empty inputs, invalid fiscal periods, and data import edge cases.

Tests should not depend on user-specific files or network access. Store small fixtures under `tests/fixtures/`.

## Commit & Pull Request Guidelines

No Git history is available in this working tree, so use a simple imperative convention: `Add fiscal calendar validation`, `Fix quarter rollover logic`, or `Update import fixture tests`.

Pull requests should include a short problem statement, a summary of changed files, commands run for validation, and linked issues when applicable. Include screenshots or exported figures only for UI, plotting, or report-format changes.

## Agent-Specific Instructions

Keep edits scoped to the requested behavior. Do not commit generated MATLAB cache files, large datasets, or local configuration. When adding dependencies, document the required MATLAB release and toolboxes in the pull request or a dedicated setup note.
