% This is an algorithm for "robot1" that will interact with the market

% In this script, robot_1 places a market BUY order for quantity
% "max_potential_quantity_robot1"
% (Can alter code so that robot_1 chooses a random direction, or always sells)
% (Can also alter code to specify some other order quantity, if desired)

alive_indicator_robot_j=1;

FAK_indic=1;

% set order buy/sell
buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

% MAKING IT A BUY
buy_sell_robot_j=1;

%set order price
if buy_sell_robot_j==1
    price_robot_j=max_price;
   
else
    price_robot_j=min_price;
    
end

% set order quantity
quantity_robot_j=max_potential_quantity_robot1;
   