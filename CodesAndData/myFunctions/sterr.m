function out = sterr(in, dim)

% check if its column or row
if nargin < 2
    if iscolumn(in)
        in = in';
        dim = 1;
    elseif isvector(in)
        dim = 2;
    elseif ismatrix(in)
        dim = 1;
    else
        error('Check input size')
    end
end


% check size
sz = size(in);

if isvector(in) % if its a vector

    s = std(in, 'omitnan');
    L = length(in);

elseif ismatrix(in)  % if its a matrix
    s = std(in, 0, dim, 'omitnan');
    L = sz(dim);

end

out = s/sqrt(L);

return

