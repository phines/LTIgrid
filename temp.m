sec_5_min = 5*60;
L_load=5;

for k = 1:300
    if mod(k,10)==0
        disp(k)
    end
    run_span = [0 sec_5_min] + (k-1)*sec_5_min;
end


