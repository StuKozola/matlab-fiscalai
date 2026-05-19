%financialStatementWorkflow Analyze standardized income statement data.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);
income = client.standardizedIncomeStatement( ...
    CompanyKey="NASDAQ_MSFT", PeriodType="annual", Currency="USD");

data = sortrows(income.data, "reportDate", "descend");
metrics = ["reportDate", "fiscalYear", "income_statement_total_revenues", ...
    "income_statement_operating_profit", "income_statement_diluted_eps"];
metrics = intersect(metrics, string(data.Properties.VariableNames), "stable");

disp(data(1:min(5, height(data)), metrics))
