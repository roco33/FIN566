% This is an algorithm for "robot1" that will interact with the simulated
% market environment.

% In this script, robot_1 simply places a random passive order.  (Just
% slightly more sophisticated than placing a totally random order, because
% robot_1 never places marketable orders here.)

% Given the order direction, robot_1 selects a price uniformly at random
% between the extremal price on the indicated side of the book and 1 dollar
% better than the opposite best (e.g., place a buy order at a price between
% min_price and best_ask-1.


alive_indicator_robot_j=1;

% set order buy/sell
buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

%set order price
if buy_sell_robot_j==1  % if the order is a buy 
    price_robot_j=randi([min_price,(best_ask-1)]); % set the price at least 1 tick lower than the best ask, ?what is min_price
   
else
    price_robot_j=randi([(best_bid+1),max_price]); % if the order is a sell order, set the price at least 1 ticker higher than the best bid, ?what is max_price
    
end

% set order quantity
% quantity is a random interger in between 1 to max_quantity
quantity_robot_j=randi(max_potential_quantity_robot1);
   