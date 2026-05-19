function profiles = companyProfiles(client, companies, options)
%companyProfiles Fetch company profiles for multiple identifiers.

    arguments
        client (1,1) fiscalai.FiscalAIClient
        companies (1,:) string
        options.Identifier (1,1) string {mustBeMember(options.Identifier, ...
            ["CompanyKey", "Ticker"])} = "CompanyKey"
    end

    if isempty(companies)
        profiles = table();
        return
    end

    profileRows = cell(1, numel(companies));
    for idx = 1:numel(companies)
        requestArgs = {char(options.Identifier), companies(idx), ...
            "ReturnType", "struct"};
        profile = client.companyProfile(requestArgs{:});
        row = struct2table(profile, AsArray=true);
        row = textColumnsToString(row);
        row.Lookup = companies(idx);
        row = movevars(row, "Lookup", Before=1);
        profileRows{idx} = row;
    end

    profiles = profileRows{1};
    for idx = 2:numel(profileRows)
        profiles = [profiles; profileRows{idx}]; %#ok<AGROW>
    end
end

function output = textColumnsToString(input)
    output = input;
    names = string(output.Properties.VariableNames);
    for idx = 1:numel(names)
        value = output.(names(idx));
        if ischar(value) || iscellstr(value) || isstring(value)
            output.(names(idx)) = string(value);
        end
    end
end
