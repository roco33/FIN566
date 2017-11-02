%-------------------------------------------------%
%
%    FIN566 PS#6 Part 2 Robot1 Algorithm (MM)
%
%              
%               10/29/2017
%
%            First Version: 11/16/2013
%
%-------------------------------------------------%

%-------------------------------------------------%

% 

robot1_order_size=10;

message_type=1;
quantity_robot_j=robot1_order_size;

% set order buy/sell
buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);


%set order price
if buy_sell_robot_j==1
    price_robot_j=best_bid;
   
elseif buy_sell_robot_j==-1
    price_robot_j=best_ask;
    
end


% set alive and FAK
alive_indicator_robot_j=1;
FAK_indic=0;










