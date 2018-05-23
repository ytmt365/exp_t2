function y = istft(XF, flen, fsft, wi, slen)
switch wi
    case 'hamming'
        wnd = hamming(flen);
    case 'hann'
        wnd = hann(flen);
    otherwise
        error('Valid input is ''hamming'' or ''hann''.')
end
% check row vector
if size(XF, 1) ~= flen
    error('Illigal input.\n');
end
fnum = size(XF, 2);
y = zeros((fnum - 1) * fsft + flen, 1);
for id = 1: fnum
    tmpsig = real(ifft(XF(:, id), flen)) .* wnd;
    y((id - 1) * fsft + 1: (id - 1) * fsft + flen) = ...
        y((id - 1) * fsft + 1: (id - 1) * fsft + flen) + tmpsig;
end
if nargin == 5
    y = y(flen - fsft + 1: slen + flen - fsft);
else
    y = y(flen - fsft + 1: end);
end