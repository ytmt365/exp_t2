clear;
fsi = 48000;
[s1, fss] = audioread('./data/sample1.wav');
s2 = audioread('./data/sample2.wav');

ldiff = length(s2) - length(s1);
if ldiff < 0
    s2 = [s2; zeros(-1 * ldiff, 1)];
elseif ldiff > 0
    s1 = [s1; zeros(ldiff, 1)];
end

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

c1 = conv(s1, is1m1) + conv(s2, is2m1);
c2 = conv(s1, is1m2) + conv(s2, is2m2);

audiowrite('./data/output2_1_1_conv.wav', c1, fss);
audiowrite('./data/output2_1_2_conv.wav', c2, fss);