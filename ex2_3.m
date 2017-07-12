%% Preparation
clear;

% set parameters
flen = 4096;
fsft = flen / 4;
mu = 0.15;
gamma = 0.3;
wnd = 1; % hamming
ns = 2; % number of sources

% read wavs, set fs
[x1, fss] = audioread('./data/output2_1_1_conv.wav');
x2 = audioread('./data/output2_1_2_conv.wav');

% STFT
xf(:, :, 1) = stft(x1, flen, fsft, wnd);
xf(:, :, 2) = stft(x2, flen, fsft, wnd);

% set frame size (number of frequency bin)
fnum = size(xf, 2);
fp = flen / 2 + 1;

%% Initialize W (bad effect point)
% xp: (channel * number of flame * flame length)
xp = permute(xf, [3, 2, 1]);
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
y = zeros(size(xp, 1), size(xp, 2), fp);
fprintf('    IVA Iteration:    \n');
for itr = 1: 200
    fprintf('\b\b\b\b%3d\n', itr);
    % (55)
    for f = 1: fp
        y(:, :, f) = wf(:, :, f) * xp(:, :, f);
    end
    % (58)
    l2 = sqrt(sum(abs(y) .^ 2, 3));
    l2(l2 == 0) = eps('double');
    % (57)
    psi = gamma * y ./ repmat(l2, [1, 1, fp]);
    for f = 1: fp
        % (56)
        wf(:, :, f) = wf(:, :, f) + mu * (eye(ns) - ...
            psi(:, :, f) * y(:, :, f)' / fnum) * wf(:, :, f);
    end
end

for f = 1: fp
    y(:, :, f) = wf(:, :, f) * xp(:, :, f);
end

%% Projection Back
z = zeros(ns, ns, fnum, fp);
for f = 1: fp
    for m = 1: fnum
        z(:, :, m, f) = wf(:, :, f) \ diag(y(:, m, f));
    end
end
z11 = squeeze(z(1, 1, :, :)).';
z12 = squeeze(z(1, 2, :, :)).';
z21 = squeeze(z(2, 1, :, :)).';
z22 = squeeze(z(2, 2, :, :)).';

z11 = vertcat(z11, conj(flipud(z11(2: end - 1, :))));
z22 = vertcat(z22, conj(flipud(z22(2: end - 1, :))));

s1 = istft(z11, length(x1), flen, fsft, 1);
s2 = istft(z22, length(x2), flen, fsft, 1);