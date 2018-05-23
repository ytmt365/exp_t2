function YF = stft(x, flen, fsft, wi)
switch wi
    case 'hamming'
        wnd = hamming(flen);
    case 'hann'
        wnd = hann(flen);
    otherwise
        error('Valid input is ''hamming'' or ''hann''.')
end
% check row vector
if size(x, 1) < size(x, 2)
    error('Illigal input.\n');
end
% pad zeros
x = [zeros(flen - fsft, 1); x; zeros(flen - fsft, 1)];
fnum = ceil((length(x) - flen) / fsft) + 1;
x = [x; zeros((fnum - 1) * fsft + flen - length(x), 1)];
YF = zeros(flen, fnum);

for id = 1: fnum
    tmpsig = x((id - 1) * fsft + 1: (id - 1) * fsft + flen) .* wnd;
    YF(:, id) = fft(tmpsig, flen);
end