%-------------------------------------------------%
%
%    FIN566 PS#6 Part 2 Robot2 Algorithm (Aggressor)
%
%              
%               10/29/2017
%
%            First Version: 11/16/2013
%
%-------------------------------------------------%
robot2_order_size=7;

% set alive and FAK
message_type=1;
FAK_indic=1;

%set price, quantity, and direction
quantity_robot_j=robot2_order_size;

price_robot_j=last_order_price;

if price_robot_j>=best_ask
    buy_sell_robot_j=1;
elseif price_robot_j<=best_bid
    buy_sell_robot_j=-1;
else
    buy_sell_robot_j=1;
    quantity_robot_j=0;
end


%-------------------------------------------------%












   