% This is an algorithm for "robot1" that will interact with the simulated 
% market.

% In this script, robot_1 places a passive order at the best price on a
% randomly chosen side of the book.


theta_1 = theta(price_flex, entered_order_price_stor_vec);

if theta_1 < mm_trigger_value

	alive_indicator_robot_j=1;

	% set order buy/sell
	buy_sell_robot_j=randi(2);
	buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

	%set order price
	if buy_sell_robot_j==1
		price_robot_j=best_bid;
	   
	else
		price_robot_j=best_ask;
		
	end

	% set order quantity
	quantity_robot_j=randi(max_potential_quantity_robot1);
	
end