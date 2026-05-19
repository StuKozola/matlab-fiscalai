% bulkCompanyWorkflow Fetch profiles, prices, and export them as CSV files.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);

companies = "NASDAQ_MSFT";
profiles = fiscalai.workflows.companyProfiles(client, companies);
prices = fiscalai.workflows.pricePanel( ...
    client, companies, StartDate="2025-01-01", EndDate="2025-12-31");

exportFolder = fullfile(projectRoot, "output", "bulk-company-workflow");
manifest = fiscalai.workflows.exportTables( ...
    struct("Profiles", profiles, "Prices", prices), exportFolder, ...
    Prefix="bulk");

disp(profiles(:, ["Lookup" "ticker" "name" "sector"]))
disp(prices(1:min(5, height(prices)), :))
disp(manifest)
