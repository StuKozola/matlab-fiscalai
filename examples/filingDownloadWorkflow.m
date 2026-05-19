%filingDownloadWorkflow Download the latest available filing PDF.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

client = fiscalai.FiscalAIClient( ...
    EnvFile=fullfile(projectRoot, ".env"), NormalizeTypes=true);
companyKey = "NASDAQ_MSFT";
filings = client.companyFilings(CompanyKey=companyKey);
filings = sortrows(filings, "filingDate", "descend");

latestFilingId = string(filings.filingId{1});
outputFile = fullfile(tempdir, latestFilingId + ".pdf");
client.filingPdf(latestFilingId, CompanyKey=companyKey, OutputFile=outputFile);

fprintf("Downloaded %s\n", outputFile)
