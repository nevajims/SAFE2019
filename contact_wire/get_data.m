a      = dir('*.png')             ;
b      = {a.name}                 ;
choice = listdlg('ListString',b)  ;

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

data_file_name  = [b{index}(1: length(b{index})-4),'.mat']       ;
disp(data_file_name)
save (data_file_name , 'data')                                   ;    

end %for index = 1:length(choice)