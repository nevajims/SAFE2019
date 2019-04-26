function path_length =  get_path_length(ordered_complex_p);
% path legth (1) = 0
% path legth (2) = dist(1-2)
% path legth (3) = % path legth (2)+ dist(2-3)
% etc

path_length = zeros(1,length(ordered_complex_p));

for index = 2 : length(ordered_complex_p)
path_length(index) = path_length(index-1)+ abs(ordered_complex_p(index)-ordered_complex_p(index-1));
end %for index = 2 : length(ordered_complex_p)



end %function path_length =  get_path_length = (ordered_complex_p);