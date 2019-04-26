%NB run RP1 first to get out_dist_data etc 
close all;
load('n:\grail\matlab\features');
max_dist=20;
out_dist_data=out_dist_data/max(max(abs(out_dist_data)));
pinv_feats_to_use=[1,2,18,26,33,38,39];
dot_feats_to_use=[1:size(feat_matrix,1)-1];
dot_feats_to_use=[1,2,18,26,33,38];
min_prob=0.75;


%mode extracted results vs dist
figure;%vs. distance
for count=1:length(plot_mode_indices);
   distplot=subplot(length(plot_mode_indices),1,count);
   hold on;
   if count==1
       title('Mode extracted data');
   end;
   x=out_dist;
   y=abs(out_dist_data(:,plot_mode_indices(count)));
   plot(x,y,'r');
   axis([-max_dist,max_dist,0,1]);
   ylabel('Linear');
   text(max_dist*1.02,0.5,[Int2Str(tx_modes(plot_mode_indices(count))),' to ',Int2Str(rx_modes(plot_mode_indices(count)))]);  
   xlabel('Distance(m)');
end;

%new feature extract using pseudoinverse of RCs calculated in FINEL for a variety of features
pinv_feat_matrix=feat_matrix(pinv_feats_to_use,:);
pinv_feat_type=feat_type(pinv_feats_to_use,:);
pinv_feat_area_loss=feat_area_loss(pinv_feats_to_use,:);

inv_feat_matrix=pinv(pinv_feat_matrix);
feat_data=zeros(size(out_dist_data,1),size(inv_feat_matrix,2));
for feat_count=1:size(inv_feat_matrix,2);
	for ii=1:size(inv_feat_matrix,1);	
      feat_data(:,feat_count)=feat_data(:,feat_count)+abs(out_dist_data(:,ii))*inv_feat_matrix(ii,feat_count);
   end;
end;
%feat_data=abs(feat_data .* (feat_data>0));

figure;
for count=1:size(feat_data,2);
   subplot(size(feat_data,2),1,count);
   hold on;
   if count==1
       title('Pseudo inverse extraction');
   end;
   x=out_dist;
   y=feat_data(:,count);
   plot(x,y,'k');%'r');
   axis([-max_dist,max_dist,0,1]);
	   ylabel('Linear');
   text(max_dist*1.02,0.5,pinv_feat_type(count));  
	xlabel('Distance(m)');
end;
 
%feature extract using dot product approach with FINEL predicitons of RC
dot_feat_matrix=feat_matrix(dot_feats_to_use,:);
dot_feat_type=feat_type(dot_feats_to_use);

feat_data=zeros(size(out_dist_data,1),size(dot_feat_matrix,1));
prob_matrix=zeros(size(out_dist_data,1),size(dot_feat_matrix,1));
for ii=1:size(out_dist_data,1);
   for feat_count=1:size(dot_feat_matrix,1);
      prob_matrix(ii,feat_count)=(abs(out_dist_data(ii,:))*abs(dot_feat_matrix(feat_count,:))')/sqrt(sum(abs(out_dist_data(ii,:)).^2)*sum(abs(dot_feat_matrix(feat_count,:)).^2));
   end;
   [best_prob,best_index]=max(prob_matrix(ii,:));
   if best_prob>min_prob;
      feat_data(ii,best_index)=(abs(out_dist_data(ii,:))*abs(dot_feat_matrix(best_index,:))')/sum(abs(dot_feat_matrix(best_index,:)).^2);
   end;
end;

figure;
for count=1:size(feat_data,2);
   subplot(size(feat_data,2),1,count);
   hold on;
   if count==1
       title('Dot product extraction - probabilities');
   end;
   x=out_dist;
   y=prob_matrix(:,count);
   plot(x,y,'k');%'r');
   axis([-max_dist,max_dist,0,1]);
   ylabel('Linear');
   text(max_dist*1.02,0.5,dot_feat_type(count));  
	xlabel('Distance(m)');
end;

figure;
for count=1:size(feat_data,2);
   subplot(size(feat_data,2),1,count);
   hold on;
   if count==1
       title('Dot product extraction - actual results');
   end;
   x=out_dist;
   y=feat_data(:,count);
   plot(x,y,'k');%'r');
   axis([-max_dist,max_dist,0,1]);
   ylabel('Linear');
   text(max_dist*1.02,0.5,dot_feat_type(count));  
	xlabel('Distance(m)');
end;
