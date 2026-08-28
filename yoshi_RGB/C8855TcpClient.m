classdef C8855TcpClient < handle
    properties (Access = private)
        Host
        Port
        TimeoutSeconds
        Client
    end

    methods
        function obj = C8855TcpClient(host, port, timeoutSeconds)
            if nargin < 1 || isempty(host)
                host = '127.0.0.1';
            end
            if nargin < 2 || isempty(port)
                port = 55000;
            end
            if nargin < 3 || isempty(timeoutSeconds)
                timeoutSeconds = 5;
            end

            obj.Host = host;
            obj.Port = port;
            obj.TimeoutSeconds = timeoutSeconds;
            obj.Client = [];
        end

        function connect(obj)
            if ~isempty(obj.Client)
                return;
            end

            obj.Client = tcpclient(obj.Host, obj.Port, 'Timeout', obj.TimeoutSeconds);
            configureTerminator(obj.Client, "LF");
        end

        function disconnect(obj)
            obj.Client = [];
        end

        function delete(obj)
            disconnect(obj);
        end

        function response = ping(obj)
            response = obj.request('PING');
        end

        function response = status(obj)
            response = obj.request('STATUS');
        end

        function response = setDataDir(obj, dataDir)
            if nargin < 2 || strlength(string(dataDir)) == 0
                error('C8855TcpClient:InvalidDataDir', 'The PMT data directory cannot be empty.');
            end
            response = obj.request(sprintf('SETDATADIR %s', char(string(dataDir))));
        end

        function response = setCsvFileName(obj, csvFileName)
            if nargin < 2 || strlength(string(csvFileName)) == 0
                error('C8855TcpClient:InvalidCsvFileName', 'The PMT CSV filename cannot be empty.');
            end
            response = obj.request(sprintf('SETCSVNAME %s', char(string(csvFileName))));
        end

        function response = startAcquisition(obj)
            response = obj.request('START');
        end

        function response = stopAcquisition(obj)
            response = obj.request('STOP');
        end

        function response = turnPmtOn(obj)
            response = obj.request('PMT_ON');
        end

        function response = turnPmtOff(obj)
            response = obj.request('PMT_OFF');
        end

        function response = request(obj, command)
            connect(obj);

            write(obj.Client, uint8([char(command), newline]), 'uint8');
            response = strtrim(readline(obj.Client));

            if startsWith(response, 'ERR ', 'IgnoreCase', true)
                error('C8855TcpClient:ServerError', '%s', extractAfter(string(response), 4));
            end

            if ~startsWith(response, 'OK', 'IgnoreCase', true)
                error('C8855TcpClient:ProtocolError', 'Unexpected response from C8855 server: %s', response);
            end
        end
    end
end
