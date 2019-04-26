a=[42828:43108];
surface_elements=sort([142 170 171 172 167 164 161 158 137 155 156 157 152 149 146 143 56 86 85 84 83 80 77 74 51 71 70 69 68 65 62 59 173:280]);
lookup=zeros(1,length(a));
element=zeros(1,length(a));
porosity=0.25;
no_elements=ceil(length(a)*porosity)

while sum(lookup)<no_elements
   ele=ceil(rand*length(a));
   if ~lookup(ele)&~ismember(ele,surface_elements)
      lookup(ele)=1;
      element(sum(lookup))=ele;
   end
end
fid=fopen('c:\out.txt','w');
element=element(find(element))
output=a(element);
fprintf(fid,'modify\n');
for count=1:length(output)
   fprintf(fid,'alter material NULL\t%i\t%i\t%i\n',output(count),output(count),output(count));
end

fclose(fid);
   