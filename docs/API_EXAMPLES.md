# API Examples

These examples assume:

```matlab
client = fiscalai.FiscalAIClient(NormalizeTypes=true);
```

## Companies

```matlab
companies = client.companiesList(PageNumber=1, PageSize=1000);
allCompanies = client.companiesAll(PageSize=1000, MaxPages=5);
profile = client.companyProfile(CompanyKey="NASDAQ_MSFT");
catalog = fiscalai.FiscalAIClient.endpointCatalog();
```

## Financial Statements

```matlab
income = client.standardizedFinancials( ...
    "income-statement", CompanyKey="NASDAQ_MSFT", ...
    PeriodType="annual", ReturnType="timetable");

cash = client.asReportedFinancials( ...
    "cash-flow-statement", CompanyKey="NASDAQ_MSFT", ...
    PeriodType="quarterly");
```

## Ratios And Valuation

```matlab
ratios = client.ratiosList(ReturnType="table");
pe = client.companyRatios( ...
    CompanyKey="NASDAQ_MSFT", RatioId="ratio_price_to_earnings", ...
    ReturnType="timetable");

screen = fiscalai.workflows.valuationScreen( ...
    client, "NASDAQ_MSFT", ...
    RatioIds=["ratio_price_to_earnings" "ratio_price_to_sales"]);
```

## Bulk Workflows And Exports

```matlab
profiles = fiscalai.workflows.companyProfiles( ...
    client, ["NASDAQ_MSFT" "NASDAQ_AAPL"]);
prices = fiscalai.workflows.pricePanel( ...
    client, ["NASDAQ_MSFT" "NASDAQ_AAPL"], StartDate="2025-01-01");

manifest = fiscalai.workflows.exportTables( ...
    struct("Profiles", profiles, "Prices", prices), ...
    "output/bulk-export", Prefix="bulk");
```

## Market Data

```matlab
prices = client.stockPrices( ...
    CompanyKey="NASDAQ_MSFT", StartDate="2025-01-01", ...
    EndDate="2025-12-31", ReturnType="timetable");
intraday = client.intradayStockPrices(CompanyKey="NASDAQ_MSFT");
splits = client.stockSplits(CompanyKey="NASDAQ_MSFT");
```

## Filings And Assets

```matlab
filings = client.companyFilings(CompanyKey="NASDAQ_MSFT");
client.filingPdf(filings.filingId(1), CompanyKey="NASDAQ_MSFT", ...
    OutputFile="latest-filing.pdf");
client.companyLogo(CompanyKey="NASDAQ_MSFT", Variant="logo", ...
    OutputFile="msft-logo.png");
```

## News And Earnings

```matlab
news = client.companyNews(CompanyKey="NASDAQ_MSFT", Importance=3);
calendar = client.earningsCalendar(Tickers="MSFT", PageSize=25);
summary = client.earningsSummary(CompanyKey="NASDAQ_MSFT");
```
