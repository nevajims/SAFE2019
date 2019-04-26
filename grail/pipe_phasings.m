clear;
close all;

% Assumming that we are operating at 42 kHz
% the L02 velocity is 5.5 m/ms and the L01 velocity is 1.5 m/ms
% note that this combination happens to be good
%wavelengths=[-0.4,0.4];%-0.17,0.17,0.4];
wavelengths=[-5.5/42, 5.5/42, -1.5/42, 1.5/42 ];%-0.17,0.17,0.4];
ring_positions=[-0.0175,0.0175];%0.0,0.05]*1.2;

cFreq = 50.0;
rSpacing = 0.016;
vGood = 3.26;
vBad = 1.9;
ring_positions=[-1.5 * rSpacing,-0.5*rSpacing,0.5*rSpacing,1.5*rSpacing]*1;
wavelengths=[-vGood/cFreq, vGood/cFreq, -vBad/cFreq, vBad/cFreq ];%-0.17,0.17,0.4];


%wavelengths=[0.2,-0.2];
%ring_positions=[-0.025,0.025]*1;

%same tx and rx weightings
wavenumbers=2*pi ./ wavelengths;
prop_matrix=zeros(length(ring_positions),length(wavelengths));
for ii=1:size(prop_matrix,1);
    for jj=1:size(prop_matrix,2);
        prop_matrix(ii,jj)=exp(i*wavenumbers(jj)*ring_positions(ii));
    end;
end;

inv_prop_matrix=pinv(prop_matrix);
disp(['Condition number for basic method: ',num2str(cond(prop_matrix))]);

time_trace_weights=zeros(length(ring_positions)^2,length(wavelengths));
tx_pos=zeros(length(ring_positions),1);
rx_pos=zeros(length(ring_positions),1);
tt_count=1;
for ii=1:length(ring_positions);
    for jj=1:length(ring_positions);
        tx_pos(tt_count)=ii;
        rx_pos(tt_count)=jj;
        for m_count=1:length(wavelengths);
            time_trace_weights(tt_count,m_count)=inv_prop_matrix(m_count,ii)*inv_prop_matrix(m_count,jj);
        end;
        tt_count=tt_count+1;
    end;
end;

time_trace_weights
%[tx_pos,rx_pos,time_trace_weights]

test_wavelengths=linspace(-2*max(abs(wavelengths)),2*max(abs(wavelengths)),1000);

figure;
for m_count=1:length(wavelengths);
    subplot(length(wavelengths),1,m_count);
    result=zeros(size(test_wavelengths));
    for tt_count=1:length(time_trace_weights);
        dist=ring_positions(tx_pos(tt_count))+ring_positions(rx_pos(tt_count));
        result=result+time_trace_weights(tt_count,m_count)*exp(2*pi*i ./ test_wavelengths *dist);
    end;
    hold on;
    temp=max(abs(result));
    plot(test_wavelengths,abs(result)/temp);
    plot(wavelengths,interp1(test_wavelengths,abs(result),wavelengths,'cubic')/temp,'bo');
    plot(wavelengths(m_count),interp1(test_wavelengths,abs(result),wavelengths(m_count),'cubic')/temp,'ro');
end;

%all in one method
wavenumbers=2*pi ./ wavelengths;
prop_matrix=zeros(length(ring_positions)^2,length(wavelengths));
tx_pos=zeros(length(ring_positions),1);
rx_pos=zeros(length(ring_positions),1);
tt_count=1;
for ii=1:length(ring_positions);
    for jj=1:length(ring_positions);
        tx_pos(tt_count)=ii;
        rx_pos(tt_count)=jj;
        for m_count=1:length(wavenumbers);
            prop_matrix(tt_count,m_count)=exp(i*wavenumbers(m_count)*(ring_positions(tx_pos(tt_count))+ring_positions(rx_pos(tt_count))));
        end;
        tt_count=tt_count+1;
    end;
end;

inv_prop_matrix=pinv(prop_matrix);
disp(['Condition number for all in one method: ',num2str(cond(prop_matrix))]);


time_trace_weights=inv_prop_matrix .';
time_trace_weights

test_wavelengths=linspace(-2*max(abs(wavelengths)),2*max(abs(wavelengths)),1000);

figure;
for m_count=1:length(wavelengths);
    subplot(length(wavelengths),1,m_count);
    result=zeros(size(test_wavelengths));
    for tt_count=1:size(time_trace_weights,1);
        dist=ring_positions(tx_pos(tt_count))+ring_positions(rx_pos(tt_count));
        result=result+time_trace_weights(tt_count,m_count)*exp(2*pi*i ./ test_wavelengths *dist);
    end;
    hold on;
    temp=(max(abs(result)));
    plot(test_wavelengths,(abs(result))/temp);
    plot(wavelengths,interp1(test_wavelengths,(abs(result)),wavelengths,'cubic')/temp,'bo');
    plot(wavelengths(m_count),interp1(test_wavelengths,(abs(result)),wavelengths(m_count),'cubic')/temp,'ro');
end;
