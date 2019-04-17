function [ B ] = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives)

  if(size(shapeFunctionGlobalDerivatives,1)==1)
  
    B = shapeFunctionGlobalDerivatives;
  
  elseif(size(shapeFunctionGlobalDerivatives,1)==2)
  
    nShapes=size(shapeFunctionGlobalDerivatives,2);
    
    B=zeros(3,2*nShapes);
    
    B(1,(1:2:2*nShapes))=shapeFunctionGlobalDerivatives(1,:);
    B(2,(2:2:2*nShapes))=shapeFunctionGlobalDerivatives(2,:);
    B(3,(1:2:2*nShapes))=shapeFunctionGlobalDerivatives(2,:);
    B(3,(2:2:2*nShapes))=shapeFunctionGlobalDerivatives(1,:);
    
  elseif(size(shapeFunctionDerivatives,1)==3)
    
    nShapes=size(shapeFunctionDerivatives,2);
    
    B=zeros(3,2*nShapes);
    
    B(1,(1:3:2*nShapes))=shapeFunctionGlobalDerivatives(1,:);
    B(2,(2:3:2*nShapes))=shapeFunctionGlobalDerivatives(2,:);
    B(3,(3:3:2*nShapes))=shapeFunctionGlobalDerivatives(3,:);
    
    B(4,(2:2:2*nShapes))=shapeFunctionGlobalDerivatives(1,:);
    B(4,(3:2:2*nShapes))=shapeFunctionGlobalDerivatives(2,:);
    
    B(5,(3:2:2*nShapes))=shapeFunctionGlobalDerivatives(2,:);
    B(5,(1:2:2*nShapes))=shapeFunctionGlobalDerivatives(3,:);
    
    B(6,(1:2:2*nShapes))=shapeFunctionGlobalDerivatives(3,:);
    B(6,(2:2:2*nShapes))=shapeFunctionGlobalDerivatives(1,:);
    
  else
    disp('ERROR! Cannot handle shape function in more than three dimensions.');
  end

end