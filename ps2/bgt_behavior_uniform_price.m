% Background-Trader Behavior Child Script
%
% Prices are drawn from a uniform distribution over integers in the closed
% interval [min_price,max_price]
%
% buy/sell direction is symmetric and i.i.d. 
%
% Quantity is drawn from a uniform distribution over integers in the closed
% interval [1,max_quantity]

buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

price_robot_j=randi([min_price,max_price]);

quantity_robot_j=randi(max_quantity);

alive_indicator_robot_j=1;