# API Reference

All calls use `fiscalai.FiscalAIClient`. Authentication is sent with the `X-Api-Key` header. Company-scoped methods accept one of the Fiscal.ai identifier sets: `CompanyKey`, `Ticker` with optional `Exchange` or `MicCode`, `Cusip`, `Isin`, `Figi`, or `Cik`.

## Response Shapes

Use `ReturnType="auto"` by default. Flat lists and time-series payloads return MATLAB tables where practical. Nested payloads remain structs. Use `ReturnType="struct"` to preserve raw JSON-derived data, `ReturnType="table"` to require table conversion, or `ReturnType="timetable"` for date-indexed time series and period rows.

Set `NormalizeTypes=true` on the client to conservatively convert date-like fields to `datetime`, text fields to `string`, and obvious numeric text fields to doubles. The default is `false` to preserve raw Fiscal.ai response fidelity. `ReturnType="timetable"` applies the same conservative conversions before selecting a date-like row-time variable.

Financial and ratio period payloads flatten `metricValues` or `metricsValues` into wide tables with period metadata plus one column per metric. Binary endpoints return `[bytes, metadata]` and write to `OutputFile` when provided.

## Methods

Generated method help is available in [METHOD_HELP.md](METHOD_HELP.md).

| Method | Fiscal.ai endpoint | Notes |
| --- | --- | --- |
| `companiesList` | `/v2/companies-list` | Supports `PageNumber`, `PageSize`. |
| `companiesAll` | `/v2/companies-list` | Retrieves all catalog pages into one table; supports `MaxPages`. |
| `companyProfile` | `/v2/company/profile` | Detailed company descriptors and available datasets. |
| `companyLogo` | `/v2/company/logo` | Binary PNG; supports `Variant` and `OutputFile`. |
| `companyNews` | `/v1/company/news` | Supports date range, event type, and importance filters. |
| `asReportedIncomeStatement` | `/v1/company/financials/income-statement/as-reported` | As-reported income statement. |
| `asReportedBalanceSheet` | `/v1/company/financials/balance-sheet/as-reported` | As-reported balance sheet. |
| `asReportedCashFlowStatement` | `/v1/company/financials/cash-flow-statement/as-reported` | As-reported cash flow statement. |
| `asReportedFinancials` | `/v1/company/financials/{statementType}/as-reported` | Generic wrapper for supported statement types. |
| `standardizedIncomeStatement` | `/v1/company/financials/income-statement/standardized` | Wide table in auto mode. |
| `standardizedBalanceSheet` | `/v1/company/financials/balance-sheet/standardized` | Wide table in auto mode. |
| `standardizedCashFlowStatement` | `/v1/company/financials/cash-flow-statement/standardized` | Wide table in auto mode. |
| `standardizedFinancials` | `/v1/company/financials/{statementType}/standardized` | Generic wrapper; supports `ReturnType="timetable"`. |
| `standardizedMetricsList` | `/v1/standardized-metrics-list/{templateType}/{statementType}` | Requires template and statement path values. |
| `allStandardizedMetricsList` | `/v1/standardized-metrics-list` | Full standardized metric catalog. |
| `ratiosList` | `/v1/ratios-list` | Ratio catalog. |
| `companyRatios` | `/v1/company/ratios` | Wide table in auto mode; supports `RatioId`. |
| `dailyRatios` | `/v1/company/ratios/daily/{ratioId}` | Daily ratio time series. |
| `sharesOutstanding` | `/v1/company/shares-outstanding` | Latest shares outstanding. |
| `adjustedMetrics` | `/v1/company/adjusted-metrics` | Adjusted metrics endpoint. |
| `adjustedNumbers` | `/v1/company/adjusted-numbers` | Adjusted numbers alias endpoint. |
| `segmentsAndKpis` | `/v2/company/segments-and-kpis` | Current segments and KPIs endpoint. |
| `legacySegmentsAndKpis` | `/v1/company/segments-and-kpis` | Deprecated v1 endpoint. |
| `stockSplits` | `/v1/company/stock-splits` | Split history. |
| `stockPrices` | `/v2/company/stock-prices` | Supports date range and `Latest`. |
| `legacyStockPrices` | `/v1/company/stock-prices` | Deprecated v1 endpoint. |
| `intradayStockPrices` | `/v1/company/stock-prices/intraday` | Intraday date range. |
| `companyFilings` | `/v2/company/filings` | Global filings; auto mode returns a table. |
| `secFilings` | `/v1/company/filings` | Deprecated SEC filings endpoint. |
| `filingImage` | `/v1/filing/{filingId}/page/{pageNumber}/image` | Binary page image. |
| `filingPdf` | `/v1/filing/{filingId}/pdf` | Binary PDF. |
| `earningsCalendar` | `/v1/calendar/earnings` | Supports tickers, dates, paging, sorting, and importance. |
| `earningsSummary` | `/v1/company/earnings-summary` | Latest company earnings summary. |
| `legacyCompaniesList` | `/v1/companies-list` | Deprecated v1 endpoint. |
| `legacyCompanyProfile` | `/v1/company/profile` | Deprecated v1 endpoint. |
| `endpointCatalog` | N/A | Static table of endpoint families and wrapper status. |
| `request` | Any GET path | Escape hatch for new Fiscal.ai endpoints. |

## Workflow Helpers

| Function | Purpose |
| --- | --- |
| `fiscalai.workflows.companySnapshot` | Pulls profile, standardized statements, valuation ratios, prices, and earnings into one struct. |
| `fiscalai.workflows.companyProfiles` | Pulls profiles for multiple companies into one table. |
| `fiscalai.workflows.pricePanel` | Pulls daily prices for multiple companies into one combined table. |
| `fiscalai.workflows.valuationScreen` | Builds a latest-ratio table for one or more companies. |
| `fiscalai.workflows.exportTables` | Exports tables, timetables, and scalar structs to CSV/MAT files with a manifest. |

## Examples

```matlab
client = fiscalai.FiscalAIClient();
income = client.standardizedIncomeStatement(CompanyKey="NASDAQ_MSFT", PeriodType="annual");
incomeTT = client.standardizedFinancials("income-statement", CompanyKey="NASDAQ_MSFT", ReturnType="timetable");
prices = client.stockPrices(CompanyKey="NASDAQ_MSFT", StartDate="2025-01-01", EndDate="2025-12-31");
[bytes, metadata] = client.companyLogo(CompanyKey="NASDAQ_MSFT", Variant="logo");
```
