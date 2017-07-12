clear;
[x1, fs] = audioread('./data/src1.wav');
x2 = audioread('./data/src2.wav');
x = [x1, x2]';
H = [0.9, 0.4; -0.3, 1];
y = H * x;
sound(y, fs);
audiowrite('./data/output1_1.wav', y', fs);