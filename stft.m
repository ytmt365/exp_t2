function f = stft(src, flen, fsft, wi)
switch wi
    case 1
        wnd = hamming(flen);
    case 2
        wnd = hann(flen);
    otherwise
        error('Valid input is 1 (hamming) or 2 (hann).\n')
end
% check row vector
if size(src, 1) < size(src, 2)
    error('Illigal input.\n');
end
% pad zeros
src = [zeros(flen - fsft, 1); src; zeros(flen - fsft, 1)];
fnum = ceil((length(src) - flen) / fsft) + 1;
src = [src; zeros((fnum - 1) * fsft + flen - length(src), 1)];
f = zeros(flen, fnum);

for i = 1: fnum
    tmpsig = src((i - 1) * fsft + 1: (i - 1) * fsft + flen) .* wnd;
    f(:, i) = fft(tmpsig, flen);
end