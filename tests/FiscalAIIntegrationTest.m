classdef FiscalAIIntegrationTest < matlab.unittest.TestCase
    %FiscalAIIntegrationTest Live Fiscal.ai smoke tests.

    methods (TestClassSetup)
        function addProjectPaths(testCase)
            projectRoot = FiscalAIIntegrationTest.projectRoot();
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, "src"), IncludingSubfolders=true));
        end
    end

    methods (Test, TestTags = {'Integration'})
        function testLiveCompanyProfile(testCase)
            client = FiscalAIIntegrationTest.liveClient(testCase);

            profile = client.companyProfile(CompanyKey="NASDAQ_MSFT", ReturnType="struct");

            testCase.verifyEqual(string(profile.ticker), "MSFT");
            testCase.verifyNotEmpty(profile.name);
        end

        function testLiveReferenceLists(testCase)
            client = FiscalAIIntegrationTest.liveClient(testCase);

            ratios = client.ratiosList(ReturnType="table");
            metrics = client.allStandardizedMetricsList(ReturnType="struct");

            testCase.verifyGreaterThan(height(ratios), 0);
            testCase.verifyNotEmpty(metrics);
        end

        function testLiveMarketData(testCase)
            client = FiscalAIIntegrationTest.liveClient(testCase);

            prices = client.stockPrices(CompanyKey="NASDAQ_MSFT", Latest=true, ReturnType="struct");

            testCase.verifyNotEmpty(prices);
        end
    end

    methods (Static, Access = private)
        function client = liveClient(testCase)
            try
                client = fiscalai.FiscalAIClient( ...
                    EnvFile=fullfile(FiscalAIIntegrationTest.projectRoot(), ".env"));
            catch exception
                testCase.assumeTrue(false, "No Fiscal.ai API key available: " + exception.message);
            end
        end

        function projectRoot = projectRoot()
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
        end
    end
end
