function [ ret ] = moListsCoincide( listA, listB )

    nEntries = numel(listA);

    if nEntries~=numel(listB)
        ret = false;
        return;
    end
    
    for iEntry = 1:nEntries
      if ~ismember(listA(iEntry), listB)
         ret = false;
         return;
      end
    end
    
    ret = true;
    
end

