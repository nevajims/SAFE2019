clear;
close all;
cd n:\grail\matlab
start_time = 10.0e-3;
end_time = 20e-3;
fname = 'n:\grail\matlab\polmont-analysis\WR140-11#00116=20020303.rla';
%fname = 'n:\grail\matlab\polmont-analysis\WR140-10#00096=20020221.rla';
%fname = 'n:\grail\matlab\polmont-analysis\WR140-8#00044=20020214.rla';
load_exp_data;
trans_rows = [1,1,1,1,  2,2,2,2,    3,3,3,3,3,3,    4,4,4,4,4,4,    5,5,5,5,5,5,    6,6,6,6,6,6,    7,7,7,7,7,7,    8,8,8,8,8,8,    9,9,9,9,    10,10,10,10];
trans_pos = [3,5,8,10,  3,5,8,10,   2,4,6,7,9,11,   2,4,6,7,9,11,   2,4,6,7,9,11,   2,4,6,7,9,11,   2,4,6,7,9,11,   2,4,6,7,9,11,   3,5,8,10,   3,5,8,10];
plot_col = [2,3,4,5,    2,3,4,5,    1,2,3,4,5,6,    1,2,3,4,5,6,    1,2,3,4,5,6,    1,2,3,4,5,6,    1,2,3,4,5,6,    1,2,3,4,5,6,    2,3,4,5,    2,3,4,5];
plot_row = trans_rows;
time_pts=size(in_time_data,1);
fft_pts=2^nextpow2(time_pts);
time_step = in_time(2)-in_time(1);
freq_step = 1/(fft_pts * (in_time(2)-in_time(1)));
freq = ([1:fft_pts/2]-1)*freq_step;
start_index = floor(start_time / time_step);
if start_index<1
    start_index=1;
end;
end_index = floor(end_time / time_step);
if (end_index<0)|(end_index>size(in_time_data,1))
    end_index=size(in_time_data,1);
end;
filter = zeros(size(in_time_data,1),1);
filter(start_index:end_index) = ones(end_index - start_index + 1,1);
time_sums=zeros(time_pts,length(trans_rows));
spec_sums=zeros(fft_pts,length(trans_rows));
for ii=1:size(in_time_data,2);
    in_time_data(:,ii) = in_time_data(:,ii) .* filter;
    disp(ii);
    txi = find((trans_pos==tx_pos(ii)).*(trans_rows==tx_row(ii)));
    rxi = find((trans_pos==rx_pos(ii)).*(trans_rows==rx_row(ii)));
    time_sums(:,txi) = time_sums(:,txi) + in_time_data(:,ii);
    time_sums(:,rxi) = time_sums(:,rxi) + in_time_data(:,ii);
    temp_spec = abs(fft(in_time_data(:,ii),fft_pts));
    spec_sums(:,txi) = spec_sums(:,txi) + temp_spec;
    spec_sums(:,rxi) = spec_sums(:,rxi) + temp_spec;
end;

cent_index = round(15.0e3/freq_step);
norm_val=max(spec_sums(cent_index,:));
norm_val =0.1923;

spec_sums = 20*log10(spec_sums/norm_val);
max_scale = max(max(spec_sums));
min_scale = max_scale - 40.0;

figure;
for ii=1:length(trans_rows);
    subplot(10,6,(plot_row(ii)-1)*6 + plot_col(ii));
    plot(freq/1.0e3,spec_sums(1:fft_pts/2,ii));
    axis([10.0,20.0,min_scale,max_scale]);
    text(11.0,(max_scale+min_scale)*0.75,sprintf('%i,%i',trans_rows(ii),trans_pos(ii)));
end;