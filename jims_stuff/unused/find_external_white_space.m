function  white_space_pixel_list  =  find_external_white_space(image_matrix);
% this is the main function
first_ind = [1,1];

if  image_matrix(first_ind(1),first_ind(2)) == 0;                        % first pixel must be white otherwise abort (this is temp)
    
pixels_done_list = [];    
white_pixel_list = []; 

white_pixel_list = add_pixels_to_list(first_ind , white_pixel_list);     % adds a list of pixels if they are not there al    
still_pixs =1;

while (still_pixs == 1)

[current_pixel , still_pixs] = find_current_pixel(white_pixel_list , pixels_done_list);       
%current_pixel

neighbouring_white_pixels = find_neighbouring_white_pixels(current_pixel,image_matrix);

white_pixel_list = add_pixels_to_list(neighbouring_white_pixels,white_pixel_list);  

pixels_done_list = add_done_pixel_to_list(current_pixel , pixels_done_list);


end %while (still_pixs == 1)

white_space_pixel_list = white_pixel_list;
end  % if  a(current_ind_temp(1),current_ind_temp(2)) == 0;  % first pixel must be white otherwise abort



%---------------------------------------------------------------------------------------------------
function [current_pixel,still_pixs] = find_current_pixel(white_pixel_list,pixels_done_list);       
%go through the pixel list until the firt one that is not in done list

continue_loop = 1;
current_pix_ind = 0;

while(continue_loop == 1);
current_pix_ind = current_pix_ind + 1;

if (current_pix_ind <= size(white_pixel_list,1))
% now go through the entire --  pixels_done_list to see if it is already done
% if yes- carry on in loop -  if no then exit and assign current pix 

pixel_used = 0;
for index = 1 :  size(pixels_done_list,1)
if white_pixel_list(current_pix_ind,1)==pixels_done_list(index,1) && white_pixel_list(current_pix_ind,2)==pixels_done_list(index,2)
pixel_used = 1;
end    
end %for index = 1 :  size(pixels_done_list,1)

if pixel_used == 0
continue_loop = 0;
current_pixel = white_pixel_list(current_pix_ind,:);
still_pixs = 1;
end

else
continue_loop = 0;
still_pixs    = 0;
end % if (current_pix_ind <= size(white_pixel_list,1))
    
end %while    
   
end % function
%---------------------------------------------------------------------------------------------------


%---------------------------------------------------------------------------------------------------
function neighbouring_white_pixels = find_neighbouring_white_pixels(current_pixel,image_matrix);
relative_pos_list = [-1,-1;-1,0;-1,1;0,-1;0,1;1,-1;1,0;1,1]; 
% check the position is valid

no_rows = size(image_matrix ,1);
no_cols = size(image_matrix ,2);
neighbouring_white_pixels = [];

for index = 1:size(relative_pos_list,1)
current_neighbour = current_pixel + relative_pos_list(index,:); 

if current_neighbour(1)>=1 && current_neighbour(1) <= no_rows && current_neighbour(2)>=1 && current_neighbour(2) <= no_cols 
%i.e. the pixel is in the image

if  image_matrix(current_neighbour(1),current_neighbour(2))==0  % i.e. it is a white pixel
neighbouring_white_pixels= [neighbouring_white_pixels;current_neighbour]; 
end %if  image_matricx(current_neighbour(1),current_neighbour(2))==0

end %if current_neighbour(1)>=1 && current_neighbour(1) <= no_rows && current_neighbour(2)>=1 && current_neighbour(2) <= no_cols 

% check the position is valid    
   
end %for index = 1:size(relative_pos_list,1)    
% neighbouring_white_pixels = [];
end % function
%---------------------------------------------------------------------------------------------------


%---------------------------------------------------------------------------------------------------
function white_pixel_list = add_pixels_to_list(neighbouring_white_pixels,white_pixel_list);  
% go through the neighbouring_white_pixels and add the ones which arn't doubles


for index = 1:size(neighbouring_white_pixels,1)
   
in_list = 0;

for index_2 = 1: size(white_pixel_list,1)
    
if  white_pixel_list(index_2,1) == neighbouring_white_pixels(index,1)   &&    white_pixel_list(index_2,2) == neighbouring_white_pixels(index,2)
in_list = 1;
end %if
    
end %index_2 = 1: size(white_pixel_list,1)

if in_list == 0
white_pixel_list = [white_pixel_list;neighbouring_white_pixels(index,:)];
% disp(  num2str(size(white_pixel_list,1)))

end %
    
end %index = 1:size(neighbouring_white_pixels,1)    
  
end % function
%---------------------------------------------------------------------------------------------------



%---------------------------------------------------------------------------------------------------
function pixels_done_list = add_done_pixel_to_list(current_pixel,pixels_done_list);
    
    pixels_done_list = [pixels_done_list ; current_pixel(1),current_pixel(2)];
    
end % function
%---------------------------------------------------------------------------------------------------

end % main function


% find_external_white_space
% start in the top left corner -  is it white -  if not keep moving right
% once the first external white space is found:
% add its indices to the collection of in_pixels
% checked list
% check all 8 neighbouring -  add all white ones to the checking list (if
% not allready there) 
% for each one: 
% is it white
% if yes is it already in the colection?
% if no add it to the collection
