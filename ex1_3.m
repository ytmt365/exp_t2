clear;
[x, fs] = audioread('./data/output1_1.wav');
x = x';
rng(101, 'twister');
W = rand(2, 2);
mu = 0.1;
Gamma = 3;
H = [0.9, 0.4; -0.3, 1];
for id = 1: 200
    y = W * x;
    W = W + mu * (eye(2) - 1 / length(y) * tanh(Gamma * y) * y') * W;
end
fprintf('\tWH:\n');
disp(W * H);
% z = zeros(size(W, 1), size(W, 2), length(y));
% for id = 1: length(y)
%     z(:, :, id) = W \ diag(y(:, id));
% end
% zz(:, 1) = squeeze(z(1, 1, :));
% zz(:, 2) = squeeze(z(1, 2, :));
% zz(:, 3) = squeeze(z(2, 1, :));
% zz(:, 4) = squeeze(z(2, 2, :));

ya = [y(1, :), zeros(1, length(y)); zeros(1, length(y)), y(2, :)];
Z = W \ ya;
zz1 = Z(1, 1: end / 2 + 1);
zz2 = Z(1, end / 2 + 1: end);
zz3 = Z(2, 1: end / 2 + 1);
zz4 = Z(2, end / 2 + 1: end);