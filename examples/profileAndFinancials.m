%profileAndFinancials Fetch a profile and standardized financials.

addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

client = fiscalai.FiscalAIClient();

profile = client.companyProfile(CompanyKey="NASDAQ_MSFT");
financials = client.standardizedIncomeStatement( ...
    CompanyKey="NASDAQ_MSFT", PeriodType=["annual" "quarterly"], Currency="USD");

disp(profile.name)
disp(financials)
