function [ transformation ] = moCreateTransformation( topologyFrom, indicesFrom, topologyTo, indicesTo )

    % line to line
    if topologyFrom == 1 && topologyTo == 1
        
        if indicesFrom(1) == indicesTo(1) && indicesFrom(2) == indicesTo(2)
            transformation = 1;
        elseif indicesFrom(2) == indicesTo(1) && indicesFrom(1) == indicesTo(2)
            transformation = -1;
        else
            disp(['ERROR! Could not find a connection from line with node indices ', num2str(indicesFrom), ' to line with node indices ', num2str(indicesTo), '.']);
        end
        
    % quad to line
    elseif topologyFrom == 2 && topologyTo == 1
        
        if sum(indicesFrom([1 2]) == indicesTo)==2            % edge 1
            transformation = [ 1 0; 0 -1 ];
        elseif sum(indicesFrom([2 1]) == indicesTo)==2       
            transformation = [ -1 0; 0 -1 ];
            
        elseif sum(indicesFrom([3 4]) == indicesTo)==2        % edge 2
            transformation = [ 1 0; 0 1 ];
        elseif sum(indicesFrom([4 3]) == indicesTo)==2
            transformation = [ -1 0; 0 1 ];
            
        elseif sum(indicesFrom([1 3]) == indicesTo)==2        % edge 3
            transformation = [ 0 1; -1 0 ];
        elseif sum(indicesFrom([3 1]) == indicesTo)==2
            transformation = [ 0 -1; -1 0 ];
        
        elseif sum(indicesFrom([2 4]) == indicesTo)==2        % edge 4
            transformation = [ 0 1; 1 0 ];
        elseif sum(indicesFrom([4 2]) == indicesTo)==2
            transformation = [ 0 -1; 1 0 ];
        
        else
            disp(['ERROR! Could not find a connection from quad with node indices ', num2str(indicesFrom), ' to line with node indices ', num2str(indicesTo), '.']);
        end    
    
    % line to quad
    elseif topologyFrom == 1 && topologyTo == 2
        
        if sum(indicesTo([1 2]) == indicesFrom)==2            % edge 1
            transformation = [ 1 0; 0 -1 ]';
        elseif sum(indicesTo([2 1]) == indicesFrom)==2       
            transformation = [ -1 0; 0 -1 ]';
            
        elseif sum(indicesTo([3 4]) == indicesFrom)==2        % edge 2
            transformation = [ 1 0; 0 1 ]';
        elseif sum(indicesTo([4 3]) == indicesFrom)==2
            transformation = [ -1 0; 0 1 ]';
            
        elseif sum(indicesTo([1 3]) == indicesFrom)==2        % edge 3
            transformation = [ 0 1; -1 0 ]';
        elseif sum(indicesTo([3 1]) == indicesFrom)==2
            transformation = [ 0 -1; -1 0 ]';
        
        elseif sum(indicesTo([2 4]) == indicesFrom)==2        % edge 4
            transformation = [ 0 1; 1 0 ]';
        elseif sum(indicesTo([4 2]) == indicesFrom)==2
            transformation = [ 0 -1; 1 0 ]';
        
        else
            disp(['ERROR! Could not find a connection from quad with node indices ', num2str(indicesFrom), ' to line with node indices ', num2str(indicesTo), '.']);
        end    
        
    % quad to quad
    elseif topologyFrom == 2 && topologyTo == 2

        if sum(indicesFrom==indicesTo)==4
           transformation = [1 0; 0 1];
        else
            disp(['ERROR! Quad-quad transformations are not yet implemented for arbitrary orientations.']);
        end
        
    % hex to line
    elseif topologyFrom == 3 && topologyTo == 1
        
            disp(['ERROR! Hex-line transformations are not yet implemented']);
            
    % hex to quad
    elseif topologyFrom == 3 && topologyTo == 2
        
            disp(['ERROR! Hex-quad transformations are not yet implemented']);

    % hex to hex
    elseif topologyFrom == 3 && topologyTo == 1
        
            disp(['ERROR! Hex-hex transformations are not yet implemented']);
          
    % unknown topologies
    else
        
        disp(['ERROR! Function createTransformation cannot handle the given topologies (', num2str(topologyFrom), ' and ', num2str(topologyTo), ').']);
        
    end
    

end

