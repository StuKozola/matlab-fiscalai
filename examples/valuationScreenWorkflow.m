% valuationScreenWorkflow Screen latest valuation ratios for one or more companies.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);

screen = fiscalai.workflows.valuationScreen( ...
    client, "NASDAQ_MSFT", ...
    RatioIds=["ratio_price_to_earnings", "ratio_price_to_sales", ...
    "ratio_ev_to_ebitda"]);

disp(screen)
