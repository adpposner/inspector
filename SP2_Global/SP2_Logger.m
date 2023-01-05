function SP2_Logger(varargin)
    persistent fh;
    if isempty(fh)
        fh=fopen('logfile.txt','w');
    end
    fprintf(fh,varargin{:});

end