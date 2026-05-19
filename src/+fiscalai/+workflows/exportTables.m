function manifest = exportTables(data, outputFolder, options)
%exportTables Export tables, timetables, and structs to a folder.

    arguments
        data
        outputFolder (1,1) string
        options.Prefix (1,1) string = "fiscalai"
    end

    if ~isfolder(outputFolder)
        mkdir(outputFolder);
    end

    manifest = exportValue(data, outputFolder, options.Prefix);
end

function manifest = exportValue(value, outputFolder, name)
    if istimetable(value)
        manifest = writeTable(timetable2table(value, ConvertRowTimes=true), ...
            outputFolder, name, "timetable");
    elseif istable(value)
        manifest = writeTable(value, outputFolder, name, "table");
    elseif isFlatScalarStruct(value)
        manifest = writeTable(struct2table(value, AsArray=true), ...
            outputFolder, name, "struct-table");
    elseif isstruct(value) && isscalar(value)
        manifest = table(Size=[0 3], ...
            VariableTypes=["string", "string", "string"], ...
            VariableNames=["Name", "Type", "File"]);
        fields = string(fieldnames(value));
        for idx = 1:numel(fields)
            fieldName = fields(idx);
            fieldValue = value.(fieldName);
            childName = name + "_" + fieldName;
            childManifest = exportValue(fieldValue, outputFolder, childName);
            manifest = [manifest; childManifest]; %#ok<AGROW>
        end
    else
        manifest = writeMat(value, outputFolder, name);
    end
end

function manifest = writeTable(value, outputFolder, name, typeName)
    fileName = fullfile(outputFolder, safeFileName(name) + ".csv");
    writetable(value, fileName);
    manifest = table(string(name), string(typeName), string(fileName), ...
        VariableNames=["Name", "Type", "File"]);
end

function manifest = writeMat(value, outputFolder, name)
    fileName = fullfile(outputFolder, safeFileName(name) + ".mat");
    save(fileName, "value");
    manifest = table(string(name), "mat", string(fileName), ...
        VariableNames=["Name", "Type", "File"]);
end

function name = safeFileName(name)
    name = regexprep(string(name), "[^A-Za-z0-9_-]", "_");
    if strlength(name) == 0
        name = "fiscalai";
    end
end

function tf = isFlatScalarStruct(value)
    tf = isstruct(value) && isscalar(value);
    if ~tf
        return
    end

    fields = string(fieldnames(value));
    for idx = 1:numel(fields)
        fieldValue = value.(fields(idx));
        tf = tf && ~(isstruct(fieldValue) || istable(fieldValue) || istimetable(fieldValue));
    end
end
