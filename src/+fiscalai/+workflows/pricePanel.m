function panel = pricePanel(client, companies, options)
%pricePanel Fetch daily stock prices for multiple companies.

    arguments
        client (1,1) fiscalai.FiscalAIClient
        companies (1,:) string
        options.Identifier (1,1) string {mustBeMember(options.Identifier, ...
            ["CompanyKey", "Ticker"])} = "CompanyKey"
        options.StartDate = []
        options.EndDate = []
        options.Latest = []
    end

    if isempty(companies)
        panel = table();
        return
    end

    priceTables = cell(1, numel(companies));
    for idx = 1:numel(companies)
        requestArgs = {char(options.Identifier), companies(idx), ...
            "StartDate", options.StartDate, ...
            "EndDate", options.EndDate, ...
            "Latest", options.Latest, ...
            "ReturnType", "timetable"};
        prices = client.stockPrices(requestArgs{:});
        priceTable = timetable2table(prices, ConvertRowTimes=true);
        priceTable.Company = repmat(companies(idx), height(priceTable), 1);
        priceTable = movevars(priceTable, "Company", Before=1);
        priceTables{idx} = priceTable;
    end

    panel = priceTables{1};
    for idx = 2:numel(priceTables)
        panel = [panel; priceTables{idx}]; %#ok<AGROW>
    end
end
