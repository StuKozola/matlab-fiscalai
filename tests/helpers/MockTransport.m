classdef MockTransport < handle
    %MockTransport Captures FiscalAIClient requests and returns canned responses.

    properties
        Responses struct = struct("StatusCode", {}, "Body", {}, "Metadata", {})
        Calls struct = struct("Method", {}, "Url", {}, "Headers", {}, "Timeout", {})
    end

    methods
        function obj = MockTransport(responses)
            arguments
                responses struct = struct("StatusCode", {}, "Body", {}, "Metadata", {})
            end

            obj.Responses = responses;
        end

        function response = send(obj, method, url, headers, timeout)
            call = struct( ...
                "Method", string(method), ...
                "Url", string(url), ...
                "Headers", headers, ...
                "Timeout", timeout);
            obj.Calls(end + 1) = call;

            if isempty(obj.Responses)
                response = struct("StatusCode", 200, "Body", "{}", "Metadata", struct());
                return
            end

            responseIndex = min(numel(obj.Calls), numel(obj.Responses));
            response = obj.Responses(responseIndex);
        end
    end
end
