%stockPrices Fetch daily stock prices for a date range.

addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

client = fiscalai.FiscalAIClient();

prices = client.stockPrices( ...
    CompanyKey="NASDAQ_MSFT", ...
    StartDate="2025-01-01", ...
    EndDate="2025-12-31");

if isstruct(prices) && isfield(prices, "data") && istable(prices.data)
    disp(head(prices.data))
else
    disp(prices)
end
