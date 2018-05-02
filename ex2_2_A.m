clear;

% read wavs, set fs
fsi = 48000;
[c1, fss] = audioread('./data/output2_1_1.wav');
c2 = audioread('./data/output2_1_2.wav');

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

% set DFT point
dftp = 2 ^ nextpow2(length(c1) + length(is1m1) - 1);
fprintf('\tDFT point: %d\n', dftp);

% initialize matrices
C = zeros(2, dftp);
H = zeros(2, 2, dftp);
S = zeros(2, dftp);

% DFT, set matrices
C(1, :) = fft(c1, dftp);
C(2, :) = fft(c2, dftp);
H(1, 1, :) = fft(is1m1, dftp);
H(1, 2, :) = fft(is1m2, dftp);
H(2, 1, :) = fft(is2m1, dftp);
H(2, 2, :) = fft(is2m2, dftp);

% source separation (24)
str2 = '';
for id = 1: dftp
    if (mod(id, round(dftp / 100)) == 0 || id == dftp)
        str1 = sprintf('\tprogress: %d%%\n', ceil(id / dftp * 100));
        fprintf([repmat('\b', [1, length(str2)]), '%s'], str1);
        str2 = str1;
    end
    S(:, id) = H(:, :, id).' \ C(:, id);
end

% ISTFT, obtain sources
s1 = real(ifft(S(1, :), dftp)).';
s2 = real(ifft(S(2, :), dftp)).';