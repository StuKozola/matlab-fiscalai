classdef FiscalAIClientTest < matlab.unittest.TestCase
    %FiscalAIClientTest Tests for fiscalai.FiscalAIClient.

    methods (TestClassSetup)
        function addProjectPaths(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, "src"), IncludingSubfolders=true));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, "tests", "helpers"), IncludingSubfolders=true));
        end
    end

    methods (Test)
        function testCompaniesListSendsHeaderAndQuery(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, ...
                '{"pagination":{"page":2},"data":[{"ticker":"MSFT","value":1,"availableDatasets":["financials","stock_prices"]},{"ticker":"AAPL","value":2,"availableDatasets":["financials"]}]}'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.companiesList(PageNumber=2, PageSize=10);

            testCase.verifyEqual(transport.Calls(1).Method, "GET");
            testCase.verifySubstring(transport.Calls(1).Url, "/v2/companies-list");
            testCase.verifySubstring(transport.Calls(1).Url, "pageNumber=2");
            testCase.verifySubstring(transport.Calls(1).Url, "pageSize=10");
            testCase.verifyEqual(transport.Calls(1).Headers.X_Api_Key, "test-key");
            testCase.verifyClass(result.data, "table");
            testCase.verifyEqual(string(result.data.ticker(1)), "MSFT");
            testCase.verifyEqual(string(result.data.availableDatasets{1}{2}), "stock_prices");
        end

        function testCompanyProfileUsesIdentifierParams(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, '{"name":"Microsoft","ticker":"MSFT"}'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.companyProfile(CompanyKey="NASDAQ_MSFT", ReturnType="struct");

            testCase.verifySubstring(transport.Calls(1).Url, "/v2/company/profile");
            testCase.verifySubstring(transport.Calls(1).Url, "companyKey=NASDAQ_MSFT");
            testCase.verifyEqual(string(result.ticker), "MSFT");
        end

        function testConstructorReadsApiKeyFromEnvFile(testCase)
            previousValue = getenv("FISCALAI_API_KEY");
            setenv("FISCALAI_API_KEY", "");
            testCase.addTeardown(@() setenv("FISCALAI_API_KEY", previousValue));
            envFile = tempname + ".env";
            writelines(["# local test file"; "FISCALAI_TEST_API_KEY = ""env-file-key"""], envFile);
            testCase.addTeardown(@() delete(envFile));
            transport = MockTransport(FiscalAIClientTest.response(200, '{"ticker":"MSFT"}'));
            client = fiscalai.FiscalAIClient( ...
                SecretName="FISCALAI_TEST_API_KEY", EnvFile=envFile, Transport=@transport.send);

            client.companyProfile(CompanyKey="NASDAQ_MSFT");

            testCase.verifyEqual(transport.Calls(1).Headers.X_Api_Key, "env-file-key");
        end

        function testFinancialStatementEndpointAndCsvPeriod(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, ...
                '{"data":[{"periodType":"Annual","revenue":10},{"periodType":"Quarterly","revenue":3}]}'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.standardizedIncomeStatement( ...
                CompanyKey="NASDAQ_MSFT", PeriodType=["annual" "quarterly"], ...
                Currency="USD", IncludeReportingTemplates=true);

            testCase.verifySubstring(transport.Calls(1).Url, "/v1/company/financials/income-statement/standardized");
            testCase.verifySubstring(transport.Calls(1).Url, "periodType=annual%2Cquarterly");
            testCase.verifySubstring(transport.Calls(1).Url, "currency=USD");
            testCase.verifySubstring(transport.Calls(1).Url, "includeReportingTemplates=true");
            testCase.verifyClass(result.data, "table");
        end

        function testStandardizedMetricsListEncodesPath(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, ...
                '[{"metricId":"revenue"},{"metricId":"ebitda"}]'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.standardizedMetricsList("standard", "income-statement");

            testCase.verifySubstring(transport.Calls(1).Url, ...
                "/v1/standardized-metrics-list/standard/income-statement");
            testCase.verifyClass(result, "table");
            testCase.verifyEqual(string(result.metricId(2)), "ebitda");
        end

        function testGenericRequestUsesCustomQuery(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, '[{"id":1},{"id":2}]'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.request("/v1/custom", Query=struct("customParam", "a b"));

            testCase.verifySubstring(transport.Calls(1).Url, "/v1/custom");
            testCase.verifySubstring(transport.Calls(1).Url, "customParam=a%20b");
            testCase.verifyClass(result, "table");
        end

        function testBinaryEndpointReturnsBytes(testCase)
            transport = MockTransport(FiscalAIClientTest.binaryResponse(200, uint8([1 2 3])));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            [bytes, metadata] = client.companyLogo(CompanyKey="NASDAQ_MSFT", Variant="logo-dark");

            testCase.verifyEqual(bytes, uint8([1 2 3]));
            testCase.verifySubstring(transport.Calls(1).Url, "/v2/company/logo");
            testCase.verifySubstring(transport.Calls(1).Url, "variant=logo-dark");
            testCase.verifyEqual(metadata.ContentType, "image/png");
        end

        function testEarningsCalendarParams(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, ...
                '[{"ticker":"MSFT","date":"2026-03-15"},{"ticker":"AAPL","date":"2026-03-16"}]'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            result = client.earningsCalendar( ...
                Tickers=["NASDAQ_MSFT" "NASDAQ_AAPL"], DateSort="date:desc", PageSize=50);

            testCase.verifySubstring(transport.Calls(1).Url, "/v1/calendar/earnings");
            testCase.verifySubstring(transport.Calls(1).Url, "tickers=NASDAQ_MSFT%2CNASDAQ_AAPL");
            testCase.verifySubstring(transport.Calls(1).Url, "dateSort=date%3Adesc");
            testCase.verifyEqual(height(result), 2);
        end

        function testRateLimitMapsToError(testCase)
            transport = MockTransport(FiscalAIClientTest.response(429, '{"error":"Rate limit exceeded"}'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send, MaxRetries=0);

            testCase.verifyError(@() client.ratiosList(), "fiscalai:RateLimit");
        end

        function testServerErrorRetries(testCase)
            transport = MockTransport([ ...
                FiscalAIClientTest.response(500, '{"error":"Temporary"}'), ...
                FiscalAIClientTest.response(200, '[{"ratioId":"ratio_price_to_earnings"},{"ratioId":"ratio_price_to_sales"}]')]);
            client = fiscalai.FiscalAIClient( ...
                ApiKey="test-key", Transport=@transport.send, MaxRetries=1, RetryPause=0);

            result = client.ratiosList();

            testCase.verifyEqual(numel(transport.Calls), 2);
            testCase.verifyEqual(string(result.ratioId(1)), "ratio_price_to_earnings");
        end

        function testForceTableErrorsForNestedResponse(testCase)
            transport = MockTransport(FiscalAIClientTest.response(200, '{"name":"Microsoft","items":[{"id":1}]}'));
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            testCase.verifyError( ...
                @() client.companyProfile(CompanyKey="NASDAQ_MSFT", ReturnType="table"), ...
                "fiscalai:CannotConvertToTable");
        end
    end

    methods (Static, Access = private)
        function response = response(statusCode, body)
            response = struct("StatusCode", statusCode, "Body", body, "Metadata", struct());
        end

        function response = binaryResponse(statusCode, body)
            response = struct( ...
                "StatusCode", statusCode, ...
                "Body", body, ...
                "Metadata", struct("ContentType", "image/png"));
        end
    end
end
