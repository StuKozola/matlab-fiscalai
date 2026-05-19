function [results, coverageResult] = runCoverage(reportFolder)
%runCoverage Run unit tests and generate an HTML coverage report.

    arguments
        reportFolder (1,1) string = fullfile( ...
            fileparts(fileparts(mfilename("fullpath"))), "coverage-report")
    end

    projectRoot = fileparts(fileparts(mfilename("fullpath")));
    addpath(fullfile(projectRoot, "src"));

    if isfolder(reportFolder)
        rmdir(reportFolder, "s");
    end

    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport
    import matlab.unittest.plugins.codecoverage.CoverageResult

    suite = [ ...
        testsuite(fullfile(projectRoot, "tests", "FiscalAIClientTest.m")), ...
        testsuite(fullfile(projectRoot, "tests", "FiscalAIWorkflowTest.m"))];
    coverageFormat = CoverageResult;
    runner = TestRunner.withTextOutput;
    runner.addPlugin(CodeCoveragePlugin.forFolder( ...
        fullfile(projectRoot, "src"), ...
        IncludingSubfolders=true, ...
        Producing=[coverageFormat, CoverageReport(reportFolder)]));

    results = runner.run(suite);
    assertSuccess(results);
    coverageResult = coverageFormat.Result;
    disp(coverageResult)
end
