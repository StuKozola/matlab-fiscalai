classdef FiscalAIWorkflowTest < matlab.unittest.TestCase
    %FiscalAIWorkflowTest Tests for packaged Fiscal.ai workflows.

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
        function testValuationScreenReturnsLatestRows(testCase)
            transport = MockTransport([
                FiscalAIWorkflowTest.response(200, ...
                '{"data":[{"reportDate":"2025-06-30","metricsValues":{"ratio_price_to_sales":{"value":12}}},{"reportDate":"2024-06-30","metricsValues":{"ratio_price_to_sales":{"value":10}}}]}')
                FiscalAIWorkflowTest.response(200, ...
                '{"data":[{"reportDate":"2025-06-30","metricsValues":{"ratio_price_to_earnings":{"value":25}}},{"reportDate":"2024-06-30","metricsValues":{"ratio_price_to_earnings":{"value":20}}}]}')]);
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            screen = fiscalai.workflows.valuationScreen( ...
                client, "NASDAQ_MSFT", RatioIds=[ ...
                "ratio_price_to_sales", "ratio_price_to_earnings"]);

            testCase.verifyEqual(height(screen), 2);
            testCase.verifyEqual(screen.LatestValue.', [12 25]);
            testCase.verifyEqual(screen.ReportDate(1), datetime("2025-06-30"));
            testCase.verifySubstring(transport.Calls(1).Url, "ratioId=ratio_price_to_sales");
            testCase.verifySubstring(transport.Calls(2).Url, "ratioId=ratio_price_to_earnings");
        end

        function testCompanySnapshotCombinesEndpointData(testCase)
            transport = MockTransport([
                FiscalAIWorkflowTest.response(200, ...
                '{"ticker":"MSFT","exchangeSymbol":"NASDAQ","name":"Microsoft Corporation"}')
                FiscalAIWorkflowTest.metricResponse("income_statement_total_revenues", 281724000000)
                FiscalAIWorkflowTest.metricResponse("balance_sheet_total_assets", 619003000000)
                FiscalAIWorkflowTest.metricResponse("cash_flow_statement_free_cash_flow", 74071000000)
                FiscalAIWorkflowTest.metricResponse("ratio_price_to_sales", 12)
                FiscalAIWorkflowTest.response(200, ...
                '[{"date":"2025-12-31","close_price":483.62}]')
                FiscalAIWorkflowTest.response(200, ...
                '[{"symbol":"MSFT","date":"2025-10-29","epsActual":3.72}]')]);
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            snapshot = fiscalai.workflows.companySnapshot( ...
                client, CompanyKey="NASDAQ_MSFT", RatioIds="ratio_price_to_sales");

            testCase.verifyEqual(string(snapshot.Profile.ticker), "MSFT");
            testCase.verifyClass(snapshot.IncomeStatement, "timetable");
            testCase.verifyClass(snapshot.StockPrices, "timetable");
            testCase.verifyEqual(height(snapshot.ValuationRatios), 1);
            testCase.verifyClass(snapshot.EarningsSummary, "table");
        end

        function testCompanyProfilesCombinesProfileRows(testCase)
            transport = MockTransport([
                FiscalAIWorkflowTest.response(200, ...
                '{"ticker":"MSFT","name":"Microsoft Corporation","sector":"Technology"}')
                FiscalAIWorkflowTest.response(200, ...
                '{"ticker":"AAPL","name":"Apple Inc.","sector":"Technology"}')]);
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            profiles = fiscalai.workflows.companyProfiles( ...
                client, ["NASDAQ_MSFT" "NASDAQ_AAPL"]);

            testCase.verifyEqual(height(profiles), 2);
            testCase.verifyEqual(string(profiles.Lookup.'), ["NASDAQ_MSFT" "NASDAQ_AAPL"]);
            testCase.verifyEqual(string(profiles.ticker.'), ["MSFT" "AAPL"]);
        end

        function testPricePanelCombinesCompanyPrices(testCase)
            transport = MockTransport([
                FiscalAIWorkflowTest.response(200, ...
                '[{"date":"2025-12-31","close_price":483.62}]')
                FiscalAIWorkflowTest.response(200, ...
                '[{"date":"2025-12-31","close_price":250.42}]')]);
            client = fiscalai.FiscalAIClient(ApiKey="test-key", Transport=@transport.send);

            panel = fiscalai.workflows.pricePanel( ...
                client, ["NASDAQ_MSFT" "NASDAQ_AAPL"], Latest=true);

            testCase.verifyEqual(height(panel), 2);
            testCase.verifyEqual(string(panel.Company.'), ["NASDAQ_MSFT" "NASDAQ_AAPL"]);
            testCase.verifyEqual(panel.close_price.', [483.62 250.42], AbsTol=1e-12);
            testCase.verifySubstring(transport.Calls(1).Url, "latest=true");
        end

        function testExportTablesWritesManifestAndFiles(testCase)
            outputFolder = string(tempname);
            mkdir(outputFolder);
            testCase.addTeardown(@() rmdir(outputFolder, "s"));
            snapshot = struct( ...
                "Profile", struct("ticker", "MSFT", "name", "Microsoft"), ...
                "Prices", timetable(483.62, RowTimes=datetime("2025-12-31"), ...
                VariableNames="close_price"));

            manifest = fiscalai.workflows.exportTables( ...
                snapshot, outputFolder, Prefix="snapshot");

            testCase.verifyEqual(height(manifest), 2);
            testCase.verifyTrue(all(isfile(manifest.File)));
            testCase.verifyTrue(any(endsWith(manifest.File, "snapshot_Profile.csv")));
            testCase.verifyTrue(any(endsWith(manifest.File, "snapshot_Prices.csv")));
        end
    end

    methods (Static, Access = private)
        function response = response(statusCode, body)
            response = struct("StatusCode", statusCode, "Body", body, "Metadata", struct());
        end

        function response = metricResponse(metricId, value)
            body = sprintf(['{"data":[{"reportDate":"2025-06-30",' ...
                '"metricsValues":{"%s":{"value":%g}}}]}'], metricId, value);
            response = FiscalAIWorkflowTest.response(200, body);
        end
    end
end
