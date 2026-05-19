%ratioScreeningWorkflow Compare valuation ratios for several companies.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);
companyKey = "NASDAQ_MSFT";
ratioIds = ["ratio_price_to_earnings"; "ratio_price_to_sales"; "ratio_ev_to_ebitda"];
screen = table( ...
    ratioIds, ...
    NaT(numel(ratioIds), 1), ...
    NaN(numel(ratioIds), 1), ...
    VariableNames=["RatioId", "ReportDate", "LatestValue"]);

ratios = client.companyRatios(CompanyKey=companyKey, PeriodType="annual");
data = sortrows(ratios.data, "reportDate", "descend");
for idx = 1:numel(ratioIds)
    screen.ReportDate(idx) = data.reportDate(1);
    screen.LatestValue(idx) = data.(ratioIds(idx))(1);
end

disp(sortrows(screen, "LatestValue"))
