clear;
H = [0.9, 0.4; -0.3, 1];
[y, fs] = audioread('./data/output1_1.wav');
x = H \ y';
sound(x, fs);