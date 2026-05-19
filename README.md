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

Most list and time-series responses are converted to `table` values when the response shape is flat. Nested responses are returned as structs unless `ReturnType="table"` is requested and conversion is possible.

## Endpoint Coverage

`fiscalai.FiscalAIClient` includes wrappers for companies, profiles, as-reported and standardized financials, standardized metrics, ratios, shares outstanding, adjusted metrics, segments and KPIs, stock splits, stock prices, filings, filing images/PDFs, logos, company news, earnings calendar, and earnings summary. Use `client.request("/path", Query=struct(...))` for new Fiscal.ai endpoints before a dedicated wrapper exists.

See [docs/API_REFERENCE.md](docs/API_REFERENCE.md) for the method-to-endpoint map and return-shape notes.

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
