# Repository Guidelines

## Project Structure & Module Organization

This workspace contains the `matlab-fiscalai` MATLAB client. Source lives in `src/+fiscalai/`, tests in `tests/`, helpers in `tests/helpers/`, examples in `examples/`, docs in `docs/`, and utilities in `tools/`. Workflows live in `.github/workflows/`. Keep generated outputs, reports, caches, and large datasets outside the repo or under ignored `output/`.

Use the `fiscalai` package namespace, for example `src/+fiscalai/FiscalAIClient.m`. Keep public entry points shallow and place helpers next to owning code.

## Build, Test, and Development Commands

- `matlab -batch "addpath('src'); results = runtests('tests'); assertSuccess(results)"` runs the MATLAB unit tests.
- `matlab -batch "addpath('src'); results = runtests('tests/FiscalAIClientTest.m'); assertSuccess(results)"` runs CI-safe tests.
- `matlab -batch "addpath('src'); results = runtests('tests/FiscalAIIntegrationTest.m'); assertSuccess(results)"` runs live tests when an API key is available.
- `matlab -batch "addpath('tools'); packageToolbox"` writes `output/matlab-fiscalai.mltbx`.
- `matlab -batch "checkcode('src/+fiscalai/FiscalAIClient.m','-cyc')"` runs MATLAB Code Analyzer checks, including cyclomatic complexity.
- `matlab -batch "run('examples/exampleName.m')"` runs a specific example script locally.

Prefer command-line MATLAB runs before opening a pull request.

## Coding Style & Naming Conventions

Use 4-space indentation in MATLAB files. Name functions and methods with lower camel case, such as `loadFiscalData`, and name classes with upper camel case, such as `FiscalCalendar`. Test classes should end in `Test`, and test methods should describe behavior, for example `testRejectsInvalidFiscalYear`.

Keep one primary function or class per `.m` file, with the filename matching the public symbol. Avoid hard-coded absolute paths; build paths with `fullfile` and anchor them from the project root when possible.

## Testing Guidelines

Use `matlab.unittest` for automated tests. Place tests under `tests/` and use mocked transports for API tests so unit tests do not need a Fiscal.ai key. Cover request construction, auth, response conversion, retries, error IDs, and binary downloads.

Tests should not depend on user-specific files or network access. Store small fixtures under `tests/fixtures/`.

## Commit & Pull Request Guidelines

Use short imperative commit messages, such as `Add Fiscal.ai client`, `Fix retry handling`, or `Update stock price example`.

Pull requests should include a short problem statement, changed-file summary, validation commands, and linked issues when applicable.

## Agent-Specific Instructions

Keep edits scoped to the requested behavior. Do not commit API keys, generated MATLAB cache files, downloaded filings/logos, large datasets, or local configuration. When adding dependencies, document the required MATLAB release and toolboxes in the pull request or setup notes.
