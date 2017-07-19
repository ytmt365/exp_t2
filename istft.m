function src = istft(f, slen, flen, fsft, wi)
switch wi
    case 1
        wnd = hamming(flen);
    case 2
        wnd = hann(flen);
    otherwise
        error('Valid input is 1 (hamming) or 2 (hann).\n')
end
% check row vector
if size(f, 1) ~= flen
    error('Illigal input.\n');
end
fnum = size(f, 2);
src = zeros((fnum - 1) * fsft + flen, 1);
for id = 1: fnum
    tmpsig = real(ifft(f(:, id), flen)) .* wnd;
    src((id - 1) * fsft + 1: (id - 1) * fsft + flen) = ...
        src((id - 1) * fsft + 1: (id - 1) * fsft + flen) + tmpsig;
end
src = src(flen - fsft + 1: slen + flen - fsft);