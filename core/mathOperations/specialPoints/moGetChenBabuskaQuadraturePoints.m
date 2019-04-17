function [ points ] = moGetChenBabuskaQuadraturePoints( ng )

    if ng > 11
        ng = 11;
        msg = 'Maximum number of Gauss-Labatto point is 11. Assume ng = 11!';
        warning(msg)
    end

    points=zeros(1,ng);
    
    switch ng
      case  1  
        points(0+1) = 0;
        
	  case 2
		points(0+1) = -1.0;
		points(1+1) = +1.0;
		
	  case 3
		points(0+1) = -1.0;
		points(1+1) = +0.0;
		points(2+1) = +1.0;
	
	  case 4
		points(0+1) = -1.0;
		points(1+1) = -0.4177913013559897;
		points(2+1) = +0.4177913013559897;
		points(3+1) = +1.0;
		
	  case 5
		points(0+1) = -1.0;
		points(1+1) = -0.6209113046899123;
		points(2+1) = +0.0;
		points(3+1) = +0.6209113046899123;
		points(4+1) = +1.0;
		
	  case 6
		points(0+1) = -1.0;
		points(1+1) = -0.7341266671891752;
		points(2+1) = -0.2689070447719729;
		points(3+1) = +0.2689070447719729;
		points(4+1) = +0.7341266671891752;
		points(5+1) = +1.0;
		
	  case 7
		points(0+1) = -1.0;
		points(1+1) = -0.8034402382691066;
		points(2+1) = -0.4461215299911067;
		points(3+1) = +0.0;
		points(4+1) = +0.4461215299911067;
		points(5+1) = +0.8034402382691066;
		points(6+1) = +1.0;
	
	  case 8
		points(0+1) = -1.0;
		points(1+1) = -0.8488719610366557;
		points(2+1) = -0.5674306027472533;
		points(3+1) = -0.1992877299056662;
		points(4+1) = +0.1992877299056662;
		points(5+1) = +0.5674306027472533;
		points(6+1) = +0.8488719610366557;
		points(7+1) = +1.0;
		
	  case 9
		points(0+1) = -1.0;
		points(1+1) = -0.880230852718454;
		points(2+1) = -0.653533479079903;
		points(3+1) = -0.3477879716116667;
		points(4+1) = +0.0;
		points(5+1) = +0.3477879716116667;
		points(6+1) = +0.653533479079903;
		points(7+1) = +0.880230852718454;
		points(8+1) = +1.0;
		
	  case 10
		points(0+1) = -1.0;
		points(1+1) = -0.9027709752917726;
		points(2+1) = -0.7166138606253078;
		points(3+1) = -0.4601498259228992;
		points(4+1) = -0.15856528865764;
		points(5+1) = +0.15856528865764;
		points(6+1) = +0.4601498259228992;
		points(7+1) = +0.7166138606253078;
		points(8+1) = +0.9027709752917726;
		points(9+1) = +1.0;
		
	  case 11
		points(0+1) = -1.0;
		points(1+1) = -0.9195087517942991;
		points(2+1) = -0.764098454567145;
		points(3+1) = -0.546667696174604;
		points(4+1) = -0.2848880010669259;
		points(5+1) = +0.0;
		points(6+1) = +0.2848880010669259;
		points(7+1) = +0.546667696174604;
		points(8+1) = +0.764098454567145;
		points(9+1) = +0.9195087517942991;
		points(10+1) = +1.0;
		 
      otherwise
            msg = 'Maximum number of Gauss-Lobotto point is 11. Assume ng = 11!';
            warning(msg)
    end
end