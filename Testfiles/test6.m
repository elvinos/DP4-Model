day={'Sun','Mon','Tues','Wed','Thu','Fri','Sat'};
d=1;
for n = 1:7*4
   
    if rem((n+6)/7,1) == 0
        d=1;
    end
       if cell2str(day(d)) == 'Sun' || cell2str(day(d)) == 'Sat'
           disp('weekend')
       end
end
