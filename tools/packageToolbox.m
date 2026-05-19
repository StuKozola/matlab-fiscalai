function outputFile = packageToolbox(outputFile, options)
%packageToolbox Package matlab-fiscalai as a MATLAB toolbox.

    arguments
        outputFile (1,1) string = fullfile( ...
            fileparts(fileparts(mfilename("fullpath"))), "output", "matlab-fiscalai.mltbx")
        options.Version (1,1) string = "0.3.0"
    end

    projectRoot = fileparts(fileparts(mfilename("fullpath")));
    outputFolder = fileparts(outputFile);
    if ~isfolder(outputFolder)
        mkdir(outputFolder);
    end

    opts = matlab.addons.toolbox.ToolboxOptions( ...
        projectRoot, "matlab-fiscalai");
    opts.ToolboxName = "matlab-fiscalai";
    opts.ToolboxVersion = options.Version;
    opts.Summary = "MATLAB client for the Fiscal.ai REST API";
    opts.Description = "A MATLAB client class, examples, and docs for Fiscal.ai company, financial, filing, market data, news, and earnings endpoints.";
    opts.AuthorName = "StuKozola";
    opts.ToolboxFiles = [
        fullfile(projectRoot, "src")
        fullfile(projectRoot, "examples")
        fullfile(projectRoot, "docs")
        fullfile(projectRoot, "README.md")
        fullfile(projectRoot, "AGENTS.md")];
    opts.ToolboxMatlabPath = fullfile(projectRoot, "src");
    opts.OutputFile = outputFile;

    matlab.addons.toolbox.packageToolbox(opts);
end
