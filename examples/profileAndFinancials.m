%profileAndFinancials Fetch a profile and standardized financials.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient(EnvFile=fullfile(projectRoot, ".env"));

profile = client.companyProfile(CompanyKey="NASDAQ_MSFT");
financials = client.standardizedIncomeStatement( ...
    CompanyKey="NASDAQ_MSFT", PeriodType=["annual" "quarterly"], Currency="USD");

disp(profile.name)
disp(financials)
