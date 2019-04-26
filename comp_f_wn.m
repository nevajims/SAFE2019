
%comp_f_wn


load unsorted_results_w
load unsorted_results_f
figure
plot(unsorted_results_w{1}.freq , 2 * pi * unsorted_results_w{1}.freq ./ unsorted_results_w{1}.waveno ,'.','color','r');
hold on
plot(unsorted_results_f{1}.freq , 2 * pi * unsorted_results_f{1}.freq ./ unsorted_results_f{1}.waveno ,'o','color','b');
xlabel('Frequency (Hz)')
ylabel('Real Vph  (m/s)')
axis([0, 2E4, 0,1E4 ])



