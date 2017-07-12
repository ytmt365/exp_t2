%% Preparation
clear;

% set parameters
flen = 4096;
fsft = flen / 4;
mu = 0.15;
gamma = 0.3;
wnd = 1; % hamming
itr = 600;

% read wavs, set fs
% [x1, fss] = audioread('./data/output2_1_1_conv.wav');
% x2 = audioread('./data/output2_1_2_conv.wav');
[x1, fss] = audioread('./src/rec3_1_1.wav');
x2 = audioread('./src/rec3_1_2.wav');
x3 = audioread('./src/rec3_1_3.wav');

% STFT
xf(:, :, 1) = stft(x1, flen, fsft, wnd);
xf(:, :, 2) = stft(x2, flen, fsft, wnd);
xf(:, :, 3) = stft(x3, flen, fsft, wnd);

fnum = size(xf, 2); % set frame size (number of frequency bin)
fp = flen / 2 + 1;
ns = size(xf, 3); % number of sources

%% Initialize W (bad effect point)
% xp: (channel * number of flame * flame length)
xfp = permute(xf, [3, 2, 1]);
% wf = zeros(ns, ns, fp);
% v = zeros(ns, ns, fp);
% for f = 1: fp
%     v(:, :, f) = xp(:, :, f) * xp(:, :, f).' / fnum;
%     [d, u] = eig(v(:, :, f));
%     wf(:, :, f) = 1 ./ sqrt(d) * u';
% end
rng(101, 'twister');
wf = rand(ns, ns, fp) + rand(ns, ns, fp) * 1i;

%% IVA
yf = zeros(size(xfp, 1), size(xfp, 2), fp);
fprintf('\tIVA Iteration:          \n');
tic;
for i = 1: itr
    fprintf('\b\b\b\b\b\b\b\b\b\b%3d / %3d\n', i, itr);
    % (55)
    for f = 1: fp
        yf(:, :, f) = wf(:, :, f) * xfp(:, :, f);
    end
    % (58)
    l2 = sqrt(sum(abs(yf) .^ 2, 3));
    % regularization
    l2(l2 == 0) = eps('double');
    % (57)
    psi = gamma * yf ./ repmat(l2, [1, 1, fp]);
    % (56)
    for f = 1: fp
        wf(:, :, f) = wf(:, :, f) + mu * (eye(ns) - ...
            psi(:, :, f) * yf(:, :, f)' / fnum) * wf(:, :, f);
    end
end

for f = 1: fp
    yf(:, :, f) = wf(:, :, f) * xfp(:, :, f);
end
fprintf('\t\tElapsed Time: %3.2f [s]\n', toc);

%% Projection Back
z = zeros(fp, fnum, ns * ns);
fprintf('\tProjection Back ... ');
for f = 1: fp
    for m = 1: fnum
        z(f, m, :) = reshape(transpose(wf(:, :, f) ...
            \ diag(yf(:, m, f))), [1, 1, ns * ns]);
    end
end
fprintf('Done\n');

%% ISTFT, Obtain Sources
s_out = zeros(length(x1), ns);
for n = 1: ns
    s_out(:, n) = istft(vertcat(z(:, :, 1 + (ns + 1) * (n - 1)), ...
        conj(flipud(z(2: end - 1, :, 1 + (ns + 1) * (n - 1))))), ...
        length(x1), flen, fsft, wnd);
end