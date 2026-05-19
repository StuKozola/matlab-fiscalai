# Quickstart

## Install From Source

Clone the repository or install the `.mltbx` release asset. For source usage:

```matlab
addpath("src")
```

## Configure Authentication

Use one of these options:

```matlab
client = fiscalai.FiscalAIClient(ApiKey="YOUR_API_KEY");
client = fiscalai.FiscalAIClient(SecretName="FISCALAI_API_KEY");
client = fiscalai.FiscalAIClient(); % Vault, environment, then .env
```

For local development, create `.env` in the repository root:

```text
FISCALAI_API_KEY=YOUR_API_KEY
```

## Make First Calls

```matlab
client = fiscalai.FiscalAIClient(NormalizeTypes=true);

profile = client.companyProfile(CompanyKey="NASDAQ_MSFT");
income = client.standardizedFinancials( ...
    "income-statement", CompanyKey="NASDAQ_MSFT", ReturnType="timetable");
prices = client.stockPrices( ...
    CompanyKey="NASDAQ_MSFT", Latest=true, ReturnType="table");
```

Use `ReturnType="struct"` for raw JSON-derived data, `ReturnType="table"` for flat data, and `ReturnType="timetable"` for date-indexed time series or period rows.

## Use Workflows

```matlab
snapshot = fiscalai.workflows.companySnapshot( ...
    client, CompanyKey="NASDAQ_MSFT", RatioIds="ratio_price_to_sales");

screen = fiscalai.workflows.valuationScreen( ...
    client, ["NASDAQ_MSFT" "NASDAQ_AAPL"], ...
    RatioIds=["ratio_price_to_earnings" "ratio_price_to_sales"]);
```

## Validate Locally

```matlab
results = [runtests("tests/FiscalAIClientTest.m"), ...
           runtests("tests/FiscalAIWorkflowTest.m")];
assertSuccess(results)

addpath("tools")
runCoverage()
```
