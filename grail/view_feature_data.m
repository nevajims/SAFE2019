clear;
fname='n:\grail\matlab\reflection-coefficients\sym_head_crack_ref_coef.mat';
load(fname);

max_feats=1;

tx_modes=       [3,5,7,8,10,  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
rx_modes=       [3,5,7,8,10,  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
receive_modes=  [3,5,7,8,10];

start_index=1;
end_index=size(notch_depths,2);
ref_index=6;%end_index;

notch_index=2;

feat_matrix=zeros(end_index-start_index+1,length(tx_modes));

for notch_count=start_index:end_index;
    temp=rc(receive_modes,:,notch_count);
    for ii=1:length(tx_modes);
    	feat_matrix(notch_count-start_index+1,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
    end;
end;

dot_products=zeros(1,size(feat_matrix,1));
norm_dot_products=zeros(1,size(feat_matrix,1));
ref_vec=feat_matrix(ref_index,:);
for ii=1:size(feat_matrix,1);
    norm_dot_products(ii)=ref_vec * feat_matrix(ii,:)' / sqrt(ref_vec * ref_vec') / sqrt(feat_matrix(ii,:) * feat_matrix(ii,:)');
    dot_products(ii)=ref_vec * feat_matrix(ii,:)' / (ref_vec * ref_vec');
end;

subplot(2,1,1);
plot(notch_depths(notch_index,start_index:end_index),norm_dot_products,'r.-');
axis([0,max(notch_depths(notch_index,start_index:end_index)),0,1]);

subplot(2,1,2);
plot(notch_depths(notch_index,start_index:end_index),dot_products,'r.-');
axis([0,max(notch_depths(notch_index,start_index:end_index)),0,max(dot_products)]);
