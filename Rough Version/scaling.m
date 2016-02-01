function [e,num] = scaling(num)
%SCALING Summary of this function goes here
%   Detailed explanation goes here
e = 0; k = abs(floor(num / 10));

while(k > 0)
    k = floor(k / 10); e = e + 1;
end

end

