clear;
[x, fs] = audioread('./data/output1_1.wav');
x = x';
rng(101, 'twister');
W = rand(2, 2);
mu = 0.1;
gamma = 3;
H = [0.9, 0.4; -0.3, 1];
for i = 1: 200
    y = W * x;
    W = W + mu * (eye(2) - 1 / length(y) * tanh(gamma * y) * y') * W;
end
fprintf('   WH:\n');
disp(W * H);
z = zeros(size(W, 1), size(W, 2), length(y));
for i = 1: length(y)
    z(:, :, i) = W \ diag(y(:, i));
end
zz(:, 1) = squeeze(z(1, 1, :));
zz(:, 2) = squeeze(z(1, 2, :));
zz(:, 3) = squeeze(z(2, 1, :));
zz(:, 4) = squeeze(z(2, 2, :));