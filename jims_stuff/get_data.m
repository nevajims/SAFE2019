
function get_data(file_type,do_plot)


a      = dir(['*.', file_type])             ;
b      = {a.name}                 ;
choice = listdlg('ListString',b)  ;
disp('here')
% currently only works if you do all

for index = 1:length(choice)
   
disp(b{choice(index)})

temp_1 = imread(b{choice(index)}) ;
temp_2 = im2bw(temp_1)            ;
temp_3 = bwperim(temp_2)          ;
temp_4 = bwlabel(temp_3)          ;

[y,x] = find(temp_4==2)           ;

x_   =   x           ;
y_   =  -y           ;
x_   =   x_-min(x_)  ;
y_   =   y_-min(y_)  ;

data.x_ = x_;
data.y_ = y_;

data_file_name  = [b{choice(index)}(1: length(b{choice(index)})-4),'.mat']       ;

disp(data_file_name)
save (data_file_name , 'data');

if do_plot == 1
figure    
plot(data.x_ , data.y_ , '.')
title(data_file_name)
end %if do_plot == 1


end %for index = 1:length(choice)


end