clear;

% read wavs, set fs
fsi = 48000;
[x1, fss] = audioread('./data/output2_1_1_conv.wav');
x2 = audioread('./data/output2_1_2_conv.wav');

% read impulse responses
fid = fopen('./data/IR_S1toM1.dbl', 'rb');
is1m1 = fread(fid, 'double');
fclose(fid);
is1m1 = resample(is1m1, fss, fsi);
fid = fopen('./data/IR_S1toM2.dbl', 'rb');
is1m2 = fread(fid, 'double');
fclose(fid);
is1m2 = resample(is1m2, fss, fsi);
fid = fopen('./data/IR_S2toM1.dbl', 'rb');
is2m1 = fread(fid, 'double');
fclose(fid);
is2m1 = resample(is2m1, fss, fsi);
fid = fopen('./data/IR_S2toM2.dbl', 'rb');
is2m2 = fread(fid, 'double');
fclose(fid);
is2m2 = resample(is2m2, fss, fsi);

% set STFT frame length 
flen = 2 ^ nextpow2(length(is1m1));

% STFT
X1 = stft(x1, flen, flen / 2, 1);
X2 = stft(x2, flen, flen / 2, 1);

% initialize matrices
H = zeros(2, 2, flen);
S1 = zeros(size(X1));
S2 = zeros(size(X2));

% set mixture matrix (2 * 2 * frequency bin)
H(1, 1, :) = fft(is1m1, flen);
H(1, 2, :) = fft(is1m2, flen);
H(2, 1, :) = fft(is2m1, flen);
H(2, 2, :) = fft(is2m2, flen);

% source separation (37)
for i2 = 1: size(X1, 2)
    for i1 = 1: size(X1, 1)
        ts = H(:, :, i1).' \ [X1(i1, i2); X2(i1, i2)];
        S1(i1, i2) = ts(1);
        S2(i1, i2) = ts(2);
    end
end

% ISTFT, obtain sources
s1 = istft(S1, length(x1), flen, flen / 2, 1);
s2 = istft(S2, length(x2), flen, flen / 2, 1);