function area=calc_area_triangle(x1,y1,x2,y2,x3,y3);
%calc side lengths
a=sqrt((x1-x2)^2+(y1-y2)^2);
b=sqrt((x3-x2)^2+(y3-y2)^2);
c=sqrt((x1-x3)^2+(y1-y3)^2);
gamma=acos((a^2+b^2-c^2)/(2*a*b));
h=b*sin(gamma);
area=0.5*a*h;