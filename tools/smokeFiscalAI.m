function results = smokeFiscalAI()
%smokeFiscalAI Run a live Fiscal.ai endpoint smoke test.

    projectRoot = fileparts(fileparts(mfilename("fullpath")));
    addpath(fullfile(projectRoot, "src"));
    client = fiscalai.FiscalAIClient(EnvFile=fullfile(projectRoot, ".env"));

    checks = [
        "endpointCatalog"
        "companiesAll"
        "companyProfile"
        "ratiosList"
        "allStandardizedMetricsList"
        "stockPricesLatest"
        "companyFilings"
        "earningsCalendar"];
    status = strings(size(checks));
    detail = strings(size(checks));

    for idx = 1:numel(checks)
        try
            [status(idx), detail(idx)] = runCheck(client, checks(idx));
        catch exception
            status(idx) = "failed";
            detail(idx) = string(exception.identifier) + ": " + string(exception.message);
        end
    end

    results = table(checks, status, detail, ...
        VariableNames=["Check", "Status", "Detail"]);
    disp(results)
end

function [status, detail] = runCheck(client, checkName)
    switch checkName
        case "endpointCatalog"
            catalog = fiscalai.FiscalAIClient.endpointCatalog();
            status = "passed";
            detail = "rows=" + string(height(catalog));
        case "companiesAll"
            companies = client.companiesAll(PageSize=5, MaxPages=1);
            status = "passed";
            detail = "rows=" + string(height(companies));
        case "companyProfile"
            profile = client.companyProfile(CompanyKey="NASDAQ_MSFT", ReturnType="struct");
            status = "passed";
            detail = "ticker=" + string(profile.ticker);
        case "ratiosList"
            ratios = client.ratiosList(ReturnType="table");
            status = "passed";
            detail = "rows=" + string(height(ratios));
        case "allStandardizedMetricsList"
            metrics = client.allStandardizedMetricsList(ReturnType="struct");
            status = "passed";
            detail = "items=" + string(numel(metrics));
        case "stockPricesLatest"
            prices = client.stockPrices(CompanyKey="NASDAQ_MSFT", Latest=true, ReturnType="struct");
            status = "passed";
            detail = "items=" + countItems(prices);
        case "companyFilings"
            filings = client.companyFilings(CompanyKey="NASDAQ_MSFT");
            status = "passed";
            detail = "items=" + countItems(filings);
        case "earningsCalendar"
            calendar = client.earningsCalendar(Tickers="MSFT", PageSize=5, ReturnType="struct");
            status = "passed";
            detail = "items=" + countItems(calendar);
        otherwise
            status = "skipped";
            detail = "Unknown check";
    end
end

function value = countItems(data)
    if istable(data)
        value = string(height(data));
    else
        value = string(numel(data));
    end
end
