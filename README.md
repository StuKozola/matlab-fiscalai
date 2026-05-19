# matlab-fiscalai

MATLAB client for the Fiscal.ai REST API.

## Setup

Add the package source to the MATLAB path:

```matlab
addpath("src")
```

Provide your API key explicitly, through MATLAB Vault, or through an environment variable:

```matlab
client = fiscalai.FiscalAIClient(ApiKey="YOUR_API_KEY");
client = fiscalai.FiscalAIClient(SecretName="FISCALAI_API_KEY");
client = fiscalai.FiscalAIClient(); % reads FISCALAI_API_KEY from Vault, then env
client = fiscalai.FiscalAIClient(NormalizeTypes=true);
client = fiscalai.FiscalAIClient(ReturnType="timetable");
```

The client also reads a local `.env` file by default after Vault and environment lookup:

```text
FISCALAI_API_KEY=YOUR_API_KEY
```

To store the key in MATLAB Vault:

```matlab
setSecret("FISCALAI_API_KEY", "YOUR_API_KEY")
```

## Basic Usage

```matlab
client = fiscalai.FiscalAIClient();

profile = client.companyProfile(CompanyKey="NASDAQ_MSFT");
financials = client.standardizedIncomeStatement( ...
    CompanyKey="NASDAQ_MSFT", PeriodType=["annual" "quarterly"]);
prices = client.stockPrices( ...
    CompanyKey="NASDAQ_MSFT", StartDate="2025-01-01", EndDate="2025-12-31");
```

Most list and time-series responses are converted to `table` values when the response shape is flat. Nested responses are returned as structs unless `ReturnType="table"` is requested and conversion is possible. Set `ReturnType="timetable"` for date-indexed time series or period rows. Set `NormalizeTypes=true` to conservatively convert date-like fields to `datetime`, text fields to `string`, and obvious numeric text fields to doubles.

Runnable workflows are available in `examples/`, including financial statement analysis, ratio screening, filing downloads, earnings calendars, stock prices, and binary assets. Reusable workflow functions live in `src/+fiscalai/+workflows/`.

## Endpoint Coverage

`fiscalai.FiscalAIClient` includes wrappers for companies, profiles, as-reported and standardized financials, standardized metrics, ratios, shares outstanding, adjusted metrics, segments and KPIs, stock splits, stock prices, filings, filing images/PDFs, logos, company news, earnings calendar, and earnings summary. Use `fiscalai.FiscalAIClient.endpointCatalog()` to inspect wrapper coverage. Use `client.request("/path", Query=struct(...))` for new Fiscal.ai endpoints before a dedicated wrapper exists.

See [docs/QUICKSTART.md](docs/QUICKSTART.md) to get started, [docs/API_REFERENCE.md](docs/API_REFERENCE.md) for the method-to-endpoint map and return-shape notes, [docs/API_EXAMPLES.md](docs/API_EXAMPLES.md) for endpoint-family examples, and [docs/METHOD_HELP.md](docs/METHOD_HELP.md) for generated method help.

Binary endpoints return bytes and metadata, and can write directly to a file:

```matlab
client.companyLogo(CompanyKey="NASDAQ_MSFT", Variant="logo", OutputFile="msft-logo.png");
client.filingPdf("0000320193-24-000123", Ticker="AAPL", Exchange="NASDAQ", OutputFile="aapl-filing.pdf");
```

## Validation

Run unit tests without a live API key:

```matlab
results = runtests("tests/FiscalAIClientTest.m");
assertSuccess(results)
```

Run workflow unit tests:

```matlab
results = runtests("tests/FiscalAIWorkflowTest.m");
assertSuccess(results)
```

Run optional live integration tests when an API key is available:

```matlab
results = runtests("tests/FiscalAIIntegrationTest.m");
assertSuccess(results)
```

Run a live endpoint smoke pass:

```matlab
addpath("tools")
results = smokeFiscalAI()
```

Generate a unit-test coverage report:

```matlab
addpath("tools")
runCoverage()
```

Run Code Analyzer:

```matlab
checkcode("src/+fiscalai/FiscalAIClient.m", "-cyc")
```

Package a local MATLAB toolbox:

```matlab
addpath("tools")
packageToolbox()
```

The package is written to `output/matlab-fiscalai.mltbx`, which is ignored by Git.

## Release Automation

Use the `MATLAB Release` GitHub Actions workflow to package and publish a release. Provide a semantic version without the leading `v`, for example `0.3.0`. The workflow runs unit tests, Code Analyzer, packages the toolbox, tags the commit, creates the GitHub release, and uploads the `.mltbx` asset.

The `MATLAB Live Smoke` workflow also runs on a weekly schedule and can be started manually. It requires the `FISCALAI_API_KEY` repository secret.
