a      = dir('*.tif')             ;
b      = {a.name}                 ;
choice = listdlg('ListString',b)  ;

for index = 1:length(choice)
    
temp_1 = imread(b{choice(index)})*50 ;
temp_2 = im2bw(temp_1)            ;
temp_3 = bwperim(temp_2)          ;
temp_4 = bwlabel(temp_3)          ;
[y,x] = find(temp_4==2)               ;

x_=x;
y_=-y;

x_=x_-min(x_);
y_=y_-min(y_);

data.x_ = x_;
data.y_ = y_;
file_name = b{index}(1:size(b{index},2)-4);

% file_name = 'bat2';

save ([file_name,'.mat'],'data')
    
end %for index = 1:length(choice)

