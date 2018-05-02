function my_spectrogram(sig_in, sfrq, flen, fsft, fp)
if ~exist('sfrq', 'var') || isempty(sfrq)
    sfrq = 16000;
end
if ~exist('flen', 'var') || isempty(flen)
    flen = 2 ^ nextpow2(0.042 * sfrq);
end
if ~exist('fsft', 'var') || isempty(fsft)
    fsft = ceil(0.001 * sfrq);
end
if ~exist('fp', 'var') || isempty(fp)
    fp = 1024;
end

if flen / 2 + 1 == size(sig_in, 1) || flen / 2 + 1 == size(sig_in, 2)
    if flen / 2 + 1 == size(sig_in, 1)
        sig_in = sig_in.';
    end
    nsGram = max(20 * log10(abs(sig_in)), -60);
else
    fprintf('\tSignal length: \t%d (%.2f [s])\n', ...
        length(sig_in), length(sig_in) / sfrq);
    wnd = hanning(flen);
    fp = fp * 2;
    siglen = length(sig_in);
    nFrame = floor((siglen - flen) / fsft);
    Gram = zeros(nFrame, fp / 2 + 1);
    
    id = 1;
    ist = 1;
    while ist + flen < siglen
        tma = fft(sig_in(ist: ist + flen - 1) .* wnd, fp);
        Gram(id, :) = tma(1: fp / 2 + 1);
        id = id + 1;
        ist = ist + fsft;
    end
    
    nsGram = max(20 * log10(abs(Gram)), -60);
    % nmax = max(max(nsGram));
    % nsGram = (nsGram - (nmax - 100)) / 100;
    % nsGram = max(nsGram, 0);
end

colormap(jet);
x = 1: size(nsGram, 1);
y = 1: size(nsGram, 2);
x = x * fsft / sfrq;
y = y * sfrq / fp;
% image(x, y, nsGram(1: size(nsGram), :).' * 64);
image(x, y, nsGram(1: size(nsGram), :).', 'CDataMapping', 'scaled');
axis('xy');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;
% c = colorbar;
% c.Label.String = 'Magnitude [dB]';

fprintf(['\tFrame length: \t%d (%.1f [ms])\n' ...
    '\tFrame shift: \t%d\n', ...
    '\tS. frequency: \t%d [Hz]\n' ...
    '\tDFT point: \t\t%d\n'], ...
    flen, flen / sfrq * 1000, fsft, sfrq, fp);