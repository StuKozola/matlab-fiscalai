% companySnapshotWorkflow Pull financials, ratios, prices, and earnings in one call.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);

snapshot = fiscalai.workflows.companySnapshot( ...
    client, CompanyKey="NASDAQ_MSFT", ...
    RatioIds=["ratio_price_to_sales", "ratio_price_to_earnings"], ...
    PriceStartDate="2025-01-01", PriceEndDate="2025-12-31");

disp(snapshot.Profile.name)
disp(snapshot.IncomeStatement(:, 1:min(5, width(snapshot.IncomeStatement))))
disp(snapshot.ValuationRatios)
