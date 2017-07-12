clear;

% read wavs, set fs
fsi = 48000;
[s1, fss] = audioread('./data/sample1.wav');
s2 = audioread('./data/sample2.wav');

% make signals the same length
ldiff = length(s2) - length(s1);
if ldiff < 0
    s2 = [s2; zeros(-1 * ldiff, 1)];
elseif ldiff > 0
    s1 = [s1; zeros(ldiff, 1)];
end

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
dftp = length(s1) + length(is1m1) - 1;

% initialize matrices
S = zeros(2, dftp);
H = zeros(2, 2, dftp);
C = zeros(2, dftp);

% DFT, set matrices
S(1, :) = fft(s1, dftp);
S(2, :) = fft(s2, dftp);
H(1, 1, :) = fft(is1m1, dftp);
H(1, 2, :) = fft(is1m2, dftp);
H(2, 1, :) = fft(is2m1, dftp);
H(2, 2, :) = fft(is2m2, dftp);

% C(1, :) = squeeze(H(1, 1, :)).' .* S(1, :) ...
%     + squeeze(H(2, 1, :)).' .* S(2, :);
% C(2, :) = squeeze(H(1, 2, :)).' .* S(1, :) ...
%     + squeeze(H(2, 2, :)).' .* S(2, :);

% convolution
for i = 1: dftp
    C(:, i) = H(:, :, i).' * S(:, i);
end

% ISTFT, obtain signals
c1 = real(ifft(C(1, :), dftp)).';
c2 = real(ifft(C(2, :), dftp)).';

% write signals
audiowrite('./data/output2_1_1.wav', c1, fss);
audiowrite('./data/output2_1_2.wav', c2, fss);