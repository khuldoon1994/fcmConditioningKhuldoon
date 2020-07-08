function [ B ] = moComposeNonlinearBMatrix(dNdX, F)

  if(size(dNdX,1)==1)
  
    B = F(1,1)*dNdX;
  
  elseif(size(dNdX,1)==2)
  
    nShapes=size(dNdX,2);
    
    B=zeros(3,2*nShapes);
    
    B(1,(1:2:2*nShapes)) = F(1,1)*dNdX(1,:);
    B(2,(1:2:2*nShapes)) = F(1,2)*dNdX(2,:);
    B(3,(1:2:2*nShapes)) = F(1,1)*dNdX(2,:) + F(1,2)*dNdX(1,:);
    B(1,(2:2:2*nShapes)) = F(2,1)*dNdX(1,:);
    B(2,(2:2:2*nShapes)) = F(2,1)*dNdX(2,:);
    B(3,(2:2:2*nShapes)) = F(2,1)*dNdX(2,:) + F(2,2)*dNdX(1,:);
    
  elseif(size(dNdX,1)==3)
    
    nShapes=size(dNdX,2);
    
    B=zeros(3,2*nShapes);
    
%     B(1,(1:3:2*nShapes)) = dNdX(1,:);
%     B(2,(2:3:2*nShapes)) = dNdX(2,:);
%     B(3,(3:3:2*nShapes)) = dNdX(3,:);
%     
%     B(4,(2:2:2*nShapes)) = dNdX(1,:);
%     B(4,(3:2:2*nShapes)) = dNdX(2,:);
%     
%     B(5,(3:2:2*nShapes)) = dNdX(2,:);
%     B(5,(1:2:2*nShapes)) = dNdX(3,:);
%     
%     B(6,(1:2:2*nShapes)) = dNdX(3,:);
%     B(6,(2:2:2*nShapes)) = dNdX(1,:);
    error('ERROR! Not implemented in 3D.');
    
  else
    disp('ERROR! Cannot handle shape function in more than three dimensions.');
  end

end