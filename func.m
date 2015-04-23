% defining functions in a file and local functions within functions

function [sum, diff] = func(a,b)
sum = mysum(a,b);
diff = mydiff(a,b);
end

function c = mysum(a,b)
c = a+b;
end

function c = mydiff(a,b)
c = a-b;
end


