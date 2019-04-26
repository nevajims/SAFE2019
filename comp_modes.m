% this is just messing around stuff
%-------------------------------------

point_1 = 1;
point_2 = 2;

perc_error = 100*(data_wn.freq(point_1)-data_wn.freq(point_2))/data_wn.freq(point_1) ;
dot_1 =abs(...
                       dot(data_wn.ms_x(:,point_1), data_wn.ms_x(:,point_1))+...
                       dot(data_wn.ms_y(:,point_1), data_wn.ms_y(:,point_1))+...
                       dot(data_wn.ms_z(:,point_1), data_wn.ms_z(:,point_1)));
dot_2 =abs(...
                       dot(data_wn.ms_x(:,point_1), data_wn.ms_x(:,point_2))+...
                       dot(data_wn.ms_y(:,point_1), data_wn.ms_y(:,point_2))+...
                       dot(data_wn.ms_z(:,point_1), data_wn.ms_z(:,point_2)));
                 
disp(['Perc diff = ',num2str(perc_error) ])                   
disp(['dot_1 = ',num2str(dot_1) ])                   
disp(['dot_2 = ',num2str(dot_2) ])                   




