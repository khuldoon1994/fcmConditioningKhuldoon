function [ ret ] = moContainsAll( containing, contained )
%containsAll Checks if all elements of contained are present in containing

    for i=1:numel(contained)
       if sum(containing == contained(i)) == 0
           ret = 0;
           return;
       end
    end

    ret = 1;
end

