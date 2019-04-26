function [name_, check_ok]    = get_mode_name_cylinder(all_headers , colum);

name_text = all_headers{colum}{1};

if size(name_text,1) ~= 0
name_ = name_text;
check_ok = 1;
else
check_ok = 0;
disp('problem with name')
end

end
