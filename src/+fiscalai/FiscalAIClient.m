classdef FiscalAIClient
    %FiscalAIClient Client for the Fiscal.ai REST API.

    properties (SetAccess = private)
        BaseUrl (1,1) string = "https://api.fiscal.ai"
        SecretName (1,1) string = "FISCALAI_API_KEY"
        EnvFile (1,1) string = ".env"
        Timeout (1,1) double {mustBePositive} = 30
        MaxRetries (1,1) double {mustBeNonnegative, mustBeInteger} = 2
        RetryPause (1,1) double {mustBeNonnegative} = 0.5
        ReturnType (1,1) string {mustBeMember(ReturnType, ["auto", "struct", "table"])} = "auto"
    end

    properties (Access = private)
        ApiKey (1,1) string = ""
        Transport = []
    end

    methods
        function obj = FiscalAIClient(options)
            %FiscalAIClient Create a Fiscal.ai API client.
            arguments
                options.ApiKey (1,1) string = ""
                options.SecretName (1,1) string = "FISCALAI_API_KEY"
                options.EnvFile (1,1) string = ".env"
                options.BaseUrl (1,1) string = "https://api.fiscal.ai"
                options.Timeout (1,1) double {mustBePositive} = 30
                options.MaxRetries (1,1) double {mustBeNonnegative, mustBeInteger} = 2
                options.RetryPause (1,1) double {mustBeNonnegative} = 0.5
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["auto", "struct", "table"])} = "auto"
                options.Transport = []
            end

            obj.BaseUrl = strip(options.BaseUrl, "right", "/");
            obj.SecretName = options.SecretName;
            obj.EnvFile = options.EnvFile;
            obj.Timeout = options.Timeout;
            obj.MaxRetries = options.MaxRetries;
            obj.RetryPause = options.RetryPause;
            obj.ReturnType = options.ReturnType;
            obj.Transport = options.Transport;
            obj.ApiKey = obj.resolveApiKey(options.ApiKey, options.SecretName, options.EnvFile);

            if strlength(obj.ApiKey) == 0
                error("fiscalai:MissingApiKey", ...
                    "Provide ApiKey, set MATLAB Vault secret %s, set environment variable FISCALAI_API_KEY, or add it to %s.", ...
                    options.SecretName, options.EnvFile);
            end
        end

        function data = request(obj, path, options)
            %request Send a GET request to any Fiscal.ai API path.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                path (1,1) string
                options.Query (1,1) struct = struct()
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson(path, options.Query, obj.effectiveReturnType(options.ReturnType));
        end

        function data = companiesList(obj, options)
            %companiesList Get the paged list of available companies.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.PageNumber = []
                options.PageSize = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            params = obj.queryStruct( ...
                "pageNumber", options.PageNumber, ...
                "pageSize", options.PageSize);
            data = obj.getJson("/v2/companies-list", params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = companyProfile(obj, options)
            %companyProfile Get a company profile.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v2/company/profile", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = legacyCompaniesList(obj, options)
            %legacyCompaniesList Get companies from the deprecated v1 endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/companies-list", struct(), obj.effectiveReturnType(options.ReturnType));
        end

        function data = legacyCompanyProfile(obj, options)
            %legacyCompanyProfile Get a company profile from the deprecated v1 endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/profile", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = asReportedIncomeStatement(obj, options)
            %asReportedIncomeStatement Get as-reported income statement data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.asReported("income-statement", options);
        end

        function data = asReportedBalanceSheet(obj, options)
            %asReportedBalanceSheet Get as-reported balance sheet data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.asReported("balance-sheet", options);
        end

        function data = asReportedCashFlowStatement(obj, options)
            %asReportedCashFlowStatement Get as-reported cash flow data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.asReported("cash-flow-statement", options);
        end

        function data = standardizedIncomeStatement(obj, options)
            %standardizedIncomeStatement Get standardized income statement data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.IncludeReportingTemplates = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.standardized("income-statement", options);
        end

        function data = standardizedBalanceSheet(obj, options)
            %standardizedBalanceSheet Get standardized balance sheet data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.IncludeReportingTemplates = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.standardized("balance-sheet", options);
        end

        function data = standardizedCashFlowStatement(obj, options)
            %standardizedCashFlowStatement Get standardized cash flow data.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.IncludeReportingTemplates = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.standardized("cash-flow-statement", options);
        end

        function data = standardizedMetricsList(obj, templateType, statementType, options)
            %standardizedMetricsList Get standardized metrics for a template and statement.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                templateType (1,1) string
                statementType (1,1) string
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            path = "/v1/standardized-metrics-list/" + ...
                obj.encodePathSegment(templateType) + "/" + obj.encodePathSegment(statementType);
            data = obj.getJson(path, struct(), obj.effectiveReturnType(options.ReturnType));
        end

        function data = allStandardizedMetricsList(obj, options)
            %allStandardizedMetricsList Get the complete standardized metrics list.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/standardized-metrics-list", struct(), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = ratiosList(obj, options)
            %ratiosList Get the list of supported ratios.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/ratios-list", struct(), obj.effectiveReturnType(options.ReturnType));
        end

        function data = companyRatios(obj, options)
            %companyRatios Get all ratio time series for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.RatioId = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            params = obj.withPeriodCurrency(obj.identifierParams(options), options);
            params = obj.addQueryParam(params, "ratioId", options.RatioId);
            data = obj.getJson("/v1/company/ratios", params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = dailyRatios(obj, ratioId, options)
            %dailyRatios Get daily values for one ratio.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                ratioId (1,1) string
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            params = obj.addQueryParam(obj.identifierParams(options), "currency", options.Currency);
            path = "/v1/company/ratios/daily/" + obj.encodePathSegment(ratioId);
            data = obj.getJson(path, params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = sharesOutstanding(obj, options)
            %sharesOutstanding Get latest shares outstanding.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/shares-outstanding", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = adjustedMetrics(obj, options)
            %adjustedMetrics Get adjusted metrics for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/adjusted-metrics", ...
                obj.withPeriodCurrency(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = adjustedNumbers(obj, options)
            %adjustedNumbers Get adjusted numbers alias endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/adjusted-numbers", ...
                obj.withPeriodCurrency(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = segmentsAndKpis(obj, options)
            %segmentsAndKpis Get segments and KPIs for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v2/company/segments-and-kpis", ...
                obj.withPeriodCurrency(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = legacySegmentsAndKpis(obj, options)
            %legacySegmentsAndKpis Get segments and KPIs from the v1 endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.PeriodType = []
                options.Currency = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/segments-and-kpis", ...
                obj.withPeriodCurrency(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = stockSplits(obj, options)
            %stockSplits Get stock split history for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/stock-splits", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = stockPrices(obj, options)
            %stockPrices Get daily stock prices for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.StartDate = []
                options.EndDate = []
                options.Latest = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v2/company/stock-prices", obj.withDateRange(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = legacyStockPrices(obj, options)
            %legacyStockPrices Get daily stock prices from the v1 endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.StartDate = []
                options.EndDate = []
                options.Latest = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/stock-prices", obj.withDateRange(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = intradayStockPrices(obj, options)
            %intradayStockPrices Get intraday stock prices for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.StartDate = []
                options.EndDate = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/stock-prices/intraday", ...
                obj.withDateRange(obj.identifierParams(options), options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = companyFilings(obj, options)
            %companyFilings Get global company filings.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v2/company/filings", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function data = secFilings(obj, options)
            %secFilings Get filings from the deprecated v1 SEC endpoint.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/filings", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end

        function [bytes, metadata] = filingImage(obj, filingId, pageNumber, options)
            %filingImage Download an image for one filing page.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                filingId (1,1) string
                pageNumber (1,1) double {mustBePositive, mustBeInteger}
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.OutputFile = []
            end

            path = "/v1/filing/" + obj.encodePathSegment(filingId) + ...
                "/page/" + pageNumber + "/image";
            [bytes, metadata] = obj.getBinary(path, obj.identifierParams(options), options.OutputFile);
        end

        function [bytes, metadata] = filingPdf(obj, filingId, options)
            %filingPdf Download a filing PDF.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                filingId (1,1) string
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.OutputFile = []
            end

            path = "/v1/filing/" + obj.encodePathSegment(filingId) + "/pdf";
            [bytes, metadata] = obj.getBinary(path, obj.identifierParams(options), options.OutputFile);
        end

        function [bytes, metadata] = companyLogo(obj, options)
            %companyLogo Download a company logo asset.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.Variant = "icon"
                options.OutputFile = []
            end

            params = obj.addQueryParam(obj.identifierParams(options), "variant", options.Variant);
            [bytes, metadata] = obj.getBinary("/v2/company/logo", params, options.OutputFile);
        end

        function data = companyNews(obj, options)
            %companyNews Get company news.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.StartDate = []
                options.EndDate = []
                options.EventType = []
                options.Importance = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            params = obj.withDateRange(obj.identifierParams(options), options);
            params = obj.addQueryParam(params, "eventType", options.EventType);
            params = obj.addQueryParam(params, "importance", options.Importance);
            data = obj.getJson("/v1/company/news", params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = earningsCalendar(obj, options)
            %earningsCalendar Get earnings calendar events.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Tickers = []
                options.Date = []
                options.DateFrom = []
                options.DateTo = []
                options.Importance = []
                options.Page = []
                options.PageSize = []
                options.Isin = []
                options.Cusip = []
                options.DateSort = []
                options.Updated = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            params = obj.queryStruct( ...
                "tickers", options.Tickers, ...
                "date", options.Date, ...
                "dateFrom", options.DateFrom, ...
                "dateTo", options.DateTo, ...
                "importance", options.Importance, ...
                "page", options.Page, ...
                "pageSize", options.PageSize, ...
                "isin", options.Isin, ...
                "cusip", options.Cusip, ...
                "dateSort", options.DateSort, ...
                "updated", options.Updated);
            data = obj.getJson("/v1/calendar/earnings", params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = earningsSummary(obj, options)
            %earningsSummary Get the latest earnings summary for a company.
            arguments
                obj (1,1) fiscalai.FiscalAIClient
                options.Ticker = []
                options.MicCode = []
                options.Exchange = []
                options.CompanyKey = []
                options.Cusip = []
                options.Isin = []
                options.Figi = []
                options.Cik = []
                options.ReturnType (1,1) string {mustBeMember(options.ReturnType, ["default", "auto", "struct", "table"])} = "default"
            end

            data = obj.getJson("/v1/company/earnings-summary", obj.identifierParams(options), ...
                obj.effectiveReturnType(options.ReturnType));
        end
    end

    methods (Access = private)
        function data = asReported(obj, statementType, options)
            params = obj.withPeriodCurrency(obj.identifierParams(options), options);
            path = "/v1/company/financials/" + obj.encodePathSegment(statementType) + "/as-reported";
            data = obj.getJson(path, params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = standardized(obj, statementType, options)
            params = obj.withPeriodCurrency(obj.identifierParams(options), options);
            params = obj.addQueryParam(params, "includeReportingTemplates", options.IncludeReportingTemplates);
            path = "/v1/company/financials/" + obj.encodePathSegment(statementType) + "/standardized";
            data = obj.getJson(path, params, obj.effectiveReturnType(options.ReturnType));
        end

        function data = getJson(obj, path, params, returnType)
            response = obj.send("GET", path, params);
            obj.throwForStatus(response);
            body = obj.decodeJson(response.Body);
            data = obj.convertResponse(body, returnType);
        end

        function [bytes, metadata] = getBinary(obj, path, params, outputFile)
            response = obj.send("GET", path, params);
            obj.throwForStatus(response);
            bytes = uint8(response.Body);
            metadata = response.Metadata;

            if ~obj.isEmptyValue(outputFile)
                fid = fopen(outputFile, "wb");
                if fid < 0
                    error("fiscalai:FileOpenFailed", "Unable to open output file: %s", string(outputFile));
                end
                cleaner = onCleanup(@() fclose(fid));
                fwrite(fid, bytes, "uint8");
                clear cleaner
            end
        end

        function response = send(obj, method, path, params)
            url = obj.buildUrl(path, params);
            headers = struct("X_Api_Key", obj.ApiKey);
            attempts = obj.MaxRetries + 1;
            lastError = [];

            for attempt = 1:attempts
                try
                    if isempty(obj.Transport)
                        response = obj.defaultTransport(method, url, headers);
                    else
                        response = obj.Transport(method, url, headers, obj.Timeout);
                    end
                    response = obj.normalizeResponse(response);
                    if ~obj.shouldRetry(response.StatusCode) || attempt == attempts
                        return
                    end
                catch exception
                    lastError = exception;
                    if attempt == attempts
                        rethrow(exception)
                    end
                end
                pause(obj.RetryPause * 2^(attempt - 1));
            end

            rethrow(lastError)
        end

        function response = defaultTransport(obj, method, url, headers)
            import matlab.net.URI
            import matlab.net.http.HeaderField
            import matlab.net.http.RequestMessage
            import matlab.net.http.RequestMethod
            import matlab.net.http.field.AcceptField

            requestHeaders = [ ...
                HeaderField("X-Api-Key", headers.X_Api_Key), ...
                AcceptField("*/*")];
            request = RequestMessage(RequestMethod(method), requestHeaders);
            options = matlab.net.http.HTTPOptions( ...
                ConnectTimeout=obj.Timeout, ...
                DecodeResponse=true, ...
                ConvertResponse=false);
            raw = request.send(URI(url), options);

            body = [];
            if isa(raw.Body, "matlab.net.http.MessageBody") && ~isempty(raw.Body.Data)
                body = raw.Body.Data;
            elseif isa(raw.Body.Payload, "uint8")
                body = raw.Body.Payload;
            end

            response = struct( ...
                "StatusCode", double(raw.StatusCode), ...
                "Body", body, ...
                "Metadata", struct("StatusLine", string(raw.StatusLine), "Headers", raw.Header));
        end

        function url = buildUrl(obj, path, params)
            path = string(path);
            if startsWith(path, "http://") || startsWith(path, "https://")
                base = path;
            else
                if ~startsWith(path, "/")
                    path = "/" + path;
                end
                base = obj.BaseUrl + path;
            end

            query = obj.encodeQuery(params);
            if strlength(query) > 0
                delimiter = "?";
                if contains(base, "?")
                    delimiter = "&";
                end
                url = base + delimiter + query;
            else
                url = base;
            end
        end

        function query = encodeQuery(obj, params)
            fields = string(fieldnames(params));
            parts = strings(0, 1);
            for idx = 1:numel(fields)
                name = fields(idx);
                value = params.(name);
                if obj.isEmptyValue(value)
                    continue
                end
                value = obj.queryValue(value);
                parts(end + 1, 1) = obj.urlEncode(name) + "=" + obj.urlEncode(value); %#ok<AGROW>
            end
            query = strjoin(parts, "&");
        end

        function params = identifierParams(obj, options)
            params = obj.queryStruct( ...
                "ticker", options.Ticker, ...
                "micCode", options.MicCode, ...
                "exchange", options.Exchange, ...
                "companyKey", options.CompanyKey, ...
                "cusip", options.Cusip, ...
                "isin", options.Isin, ...
                "figi", options.Figi, ...
                "cik", options.Cik);
        end

        function params = withPeriodCurrency(obj, params, options)
            params = obj.addQueryParam(params, "periodType", options.PeriodType);
            params = obj.addQueryParam(params, "currency", options.Currency);
        end

        function params = withDateRange(obj, params, options)
            params = obj.addQueryParam(params, "startDate", options.StartDate);
            params = obj.addQueryParam(params, "endDate", options.EndDate);
            if isfield(options, "Latest")
                params = obj.addQueryParam(params, "latest", options.Latest);
            end
        end

        function params = queryStruct(obj, varargin)
            params = struct();
            for idx = 1:2:numel(varargin)
                params = obj.addQueryParam(params, varargin{idx}, varargin{idx + 1});
            end
        end

        function params = addQueryParam(obj, params, name, value)
            if obj.isEmptyValue(value)
                return
            end
            params.(matlab.lang.makeValidName(name)) = value;
        end

        function value = effectiveReturnType(obj, returnType)
            if returnType == "default"
                value = obj.ReturnType;
            else
                value = returnType;
            end
        end

        function output = convertResponse(obj, body, returnType)
            if returnType == "struct"
                output = body;
                return
            end

            if returnType == "table"
                output = obj.forceTable(body);
                return
            end

            output = obj.autoConvert(body);
        end

        function output = autoConvert(obj, body)
            if isstruct(body) && isfield(body, "data") && obj.hasMetricValues(body.data)
                body.data = obj.metricDataToTable(body.data);
                output = body;
            elseif isstruct(body) && isfield(body, "data") && obj.isFlatStruct(body.data)
                body.data = struct2table(body.data);
                output = body;
            elseif isstruct(body) && isfield(body, "data") && obj.isStructCell(body.data)
                body.data = obj.cellStructToTable(body.data);
                output = body;
            elseif obj.isStructCell(body)
                output = obj.cellStructToTable(body);
            elseif obj.isTableConvertible(body)
                output = struct2table(body);
            else
                output = body;
            end
        end

        function output = forceTable(obj, body)
            if isstruct(body) && isfield(body, "data") && obj.hasMetricValues(body.data)
                output = obj.metricDataToTable(body.data);
            elseif isstruct(body) && isfield(body, "data") && obj.isFlatStruct(body.data)
                output = struct2table(body.data);
            elseif isstruct(body) && isfield(body, "data") && obj.isStructCell(body.data)
                output = obj.cellStructToTable(body.data);
            elseif obj.isStructCell(body)
                output = obj.cellStructToTable(body);
            elseif obj.isFlatStruct(body)
                output = struct2table(body);
            else
                error("fiscalai:CannotConvertToTable", ...
                    "The response is nested or irregular and cannot be converted to a table.");
            end
        end

        function tf = isTableConvertible(obj, value)
            tf = obj.isFlatStruct(value) && ~isscalar(value);
        end

        function tf = isFlatStruct(obj, value)
            if ~(isstruct(value) && ~isempty(value))
                tf = false;
                return
            end
            names = fieldnames(value);
            tf = ~isempty(names);
            for idx = 1:numel(value)
                tf = tf && isequal(names, fieldnames(value(idx)));
                for nameIdx = 1:numel(names)
                    fieldValue = value(idx).(names{nameIdx});
                    tf = tf && ~obj.isNestedValue(fieldValue);
                end
            end
        end

        function tf = isNestedValue(obj, value)
            if isstruct(value)
                tf = true;
            elseif iscell(value)
                tf = any(cellfun(@(item) obj.isNestedValue(item), value(:)));
            else
                tf = false;
            end
        end

        function tf = isStructCell(~, value)
            tf = iscell(value) && ~isempty(value) && all(cellfun(@(item) isstruct(item) && isscalar(item), value(:)));
        end

        function output = cellStructToTable(~, value)
            allNames = strings(0, 1);
            for idx = 1:numel(value)
                allNames = [allNames; string(fieldnames(value{idx}))]; %#ok<AGROW>
            end
            allNames = unique(allNames, "stable");
            variableNames = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(allNames));
            cells = cell(numel(value), numel(allNames));
            for rowIdx = 1:numel(value)
                for nameIdx = 1:numel(allNames)
                    name = allNames(nameIdx);
                    if isfield(value{rowIdx}, name)
                        cells{rowIdx, nameIdx} = value{rowIdx}.(name);
                    else
                        cells{rowIdx, nameIdx} = [];
                    end
                end
            end
            output = cell2table(cells, VariableNames=cellstr(variableNames));
        end

        function tf = hasMetricValues(~, value)
            tf = isstruct(value) && ~isempty(value) && ...
                (isfield(value, "metricValues") || isfield(value, "metricsValues"));
        end

        function output = metricDataToTable(obj, value)
            rows = cell(numel(value), 1);
            metricNames = strings(0, 1);
            for rowIdx = 1:numel(value)
                row = struct();
                names = string(fieldnames(value(rowIdx)));
                for nameIdx = 1:numel(names)
                    name = names(nameIdx);
                    fieldValue = value(rowIdx).(name);
                    if name == "metricValues" || name == "metricsValues"
                        [row, metricNames] = obj.addMetricFields(row, fieldValue, metricNames);
                    elseif ~obj.isNestedValue(fieldValue)
                        row.(matlab.lang.makeValidName(name)) = fieldValue;
                    end
                end
                rows{rowIdx} = row;
            end

            metricNames = unique(metricNames, "stable");
            for rowIdx = 1:numel(rows)
                for metricIdx = 1:numel(metricNames)
                    metricName = metricNames(metricIdx);
                    if ~isfield(rows{rowIdx}, metricName)
                        rows{rowIdx}.(metricName) = NaN;
                    end
                end
            end
            output = struct2table(vertcat(rows{:}));
        end

        function [row, metricNames] = addMetricFields(obj, row, metrics, metricNames)
            names = string(fieldnames(metrics));
            for idx = 1:numel(names)
                matlabName = string(matlab.lang.makeValidName(names(idx)));
                row.(matlabName) = obj.metricScalarValue(metrics.(names(idx)));
                metricNames(end + 1, 1) = matlabName; %#ok<AGROW>
            end
        end

        function value = metricScalarValue(~, metricValue)
            if isstruct(metricValue) && isfield(metricValue, "value")
                value = metricValue.value;
            elseif isnumeric(metricValue) || islogical(metricValue) || ischar(metricValue) || isstring(metricValue)
                value = metricValue;
            else
                value = NaN;
            end
        end

        function body = decodeJson(~, rawBody)
            if isempty(rawBody)
                body = struct();
                return
            end
            if isstring(rawBody) || ischar(rawBody)
                text = string(rawBody);
            elseif isa(rawBody, "uint8")
                text = native2unicode(rawBody(:).', "UTF-8");
            else
                body = rawBody;
                return
            end
            body = jsondecode(char(text));
        end

        function throwForStatus(obj, response)
            code = double(response.StatusCode);
            if code >= 200 && code < 300
                return
            end

            message = obj.errorMessage(response.Body);
            switch code
                case 400
                    id = "fiscalai:BadRequest";
                case 401
                    id = "fiscalai:Unauthorized";
                case 403
                    id = "fiscalai:Forbidden";
                case 404
                    id = "fiscalai:NotFound";
                case 429
                    id = "fiscalai:RateLimit";
                case 500
                    id = "fiscalai:ServerError";
                otherwise
                    id = "fiscalai:HttpError";
            end
            error(id, "Fiscal.ai request failed with HTTP %d: %s", code, message);
        end

        function message = errorMessage(obj, body)
            message = "Unknown error";
            try
                decoded = obj.decodeJson(body);
                if isstruct(decoded) && isfield(decoded, "error")
                    message = string(decoded.error);
                elseif isstruct(decoded) && isfield(decoded, "message")
                    message = string(decoded.message);
                elseif isstruct(decoded) && isfield(decoded, "errors") && ~isempty(decoded.errors)
                    message = string(decoded.errors(1).message);
                end
            catch
                if isstring(body) || ischar(body)
                    message = string(body);
                elseif isa(body, "uint8")
                    message = string(native2unicode(body(:).', "UTF-8"));
                end
            end
        end

        function response = normalizeResponse(~, response)
            if ~isfield(response, "Metadata")
                response.Metadata = struct();
            end
            if ~isfield(response, "Body")
                response.Body = [];
            end
            response.StatusCode = double(response.StatusCode);
        end

        function tf = shouldRetry(~, statusCode)
            tf = any(double(statusCode) == [429 500 502 503 504]);
        end
    end

    methods (Static, Access = private)
        function apiKey = resolveApiKey(apiKey, secretName, envFile)
            if strlength(apiKey) > 0
                return
            end

            apiKey = "";
            if strlength(secretName) > 0 && exist("getSecret", "file") == 2
                try
                    secretValue = getSecret(secretName);
                    if ~isempty(secretValue)
                        apiKey = string(secretValue);
                        return
                    end
                catch
                end
            end

            envValue = getenv("FISCALAI_API_KEY");
            if ~isempty(envValue)
                apiKey = string(envValue);
                return
            end

            if strlength(envFile) > 0
                apiKey = fiscalai.FiscalAIClient.readApiKeyFromEnvFile(secretName, envFile);
            end
        end

        function apiKey = readApiKeyFromEnvFile(secretName, envFile)
            apiKey = "";
            if ~isfile(envFile)
                return
            end

            lines = string(splitlines(fileread(envFile)));
            pattern = "^" + regexptranslate("escape", secretName) + "\s*=\s*(.*)$";
            for idx = 1:numel(lines)
                line = strtrim(lines(idx));
                if startsWith(line, "#") || strlength(line) == 0
                    continue
                end
                tokens = regexp(char(line), char(pattern), "tokens", "once");
                if ~isempty(tokens)
                    apiKey = string(regexprep(strtrim(tokens{1}), "^([""'])(.*)\1$", "$2"));
                    return
                end
            end
        end

        function encoded = encodePathSegment(value)
            encoded = fiscalai.FiscalAIClient.urlEncode(string(value));
        end

        function encoded = urlEncode(value)
            encoded = string(java.net.URLEncoder.encode(char(string(value)), "UTF-8"));
            encoded = replace(encoded, "+", "%20");
        end

        function value = queryValue(value)
            if isstring(value)
                value = strjoin(value, ",");
            elseif ischar(value)
                value = string(value);
            elseif iscellstr(value)
                value = strjoin(string(value), ",");
            elseif islogical(value)
                if isscalar(value)
                    value = lower(string(value));
                else
                    value = strjoin(lower(string(value)), ",");
                end
            elseif isnumeric(value)
                value = strjoin(string(value), ",");
            elseif isdatetime(value)
                value = strjoin(string(value, "yyyy-MM-dd"), ",");
            else
                value = string(value);
            end
        end

        function tf = isEmptyValue(value)
            tf = isempty(value);
            if tf
                return
            end
            if isstring(value)
                tf = all(strlength(value) == 0);
            elseif ischar(value)
                tf = strlength(string(value)) == 0;
            end
        end
    end
end
