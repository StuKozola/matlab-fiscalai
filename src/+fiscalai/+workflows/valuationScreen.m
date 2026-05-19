function screen = valuationScreen(client, companies, options)
%valuationScreen Build a latest-ratio screen for a set of companies.

    arguments
        client (1,1) fiscalai.FiscalAIClient
        companies (1,:) string
        options.Identifier (1,1) string {mustBeMember(options.Identifier, ...
            ["CompanyKey", "Ticker"])} = "CompanyKey"
        options.RatioIds (1,:) string = [ ...
            "ratio_price_to_earnings", ...
            "ratio_price_to_sales", ...
            "ratio_ev_to_ebitda"]
        options.PeriodType = "annual"
        options.Currency = []
    end

    variableTypes = ["string", "string", "datetime", "double"];
    variableNames = ["Company", "RatioId", "ReportDate", "LatestValue"];
    screen = table(Size=[0 numel(variableNames)], ...
        VariableTypes=variableTypes, VariableNames=variableNames);

    for company = companies
        for ratioId = options.RatioIds
            requestArgs = {
                char(options.Identifier), company, ...
                "RatioId", ratioId, ...
                "PeriodType", options.PeriodType, ...
                "Currency", options.Currency, ...
                "ReturnType", "timetable"};
            response = client.companyRatios(requestArgs{:});
            series = response.data;
            latest = latestRatioRow(series, ratioId);
            screen(end + 1, :) = {company, ratioId, latest.ReportDate, latest.LatestValue}; %#ok<AGROW>
        end
    end
end

function latest = latestRatioRow(series, ratioId)
    if istimetable(series)
        series = sortrows(series);
        latestIndex = height(series);
        reportDate = series.Properties.RowTimes(latestIndex);
    else
        series = sortrows(series, "reportDate");
        latestIndex = height(series);
        reportDate = series.reportDate(latestIndex);
    end

    ratioName = matlab.lang.makeValidName(ratioId);
    value = series.(ratioName)(latestIndex);
    latest = struct("ReportDate", reportDate, "LatestValue", value);
end
