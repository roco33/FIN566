robot1_order_size = 1;
FAK_indic=0;

% buy order
if robot1_inventory_stor_vec[t] == 0
	message_type = 1;
	alive_indicator_robot_j = 1;
	quantity_robot_j = robot1_order_size;

	% randomly choose sides
	buy_sell_robot_j=randi(2);
	buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

	% set order price
	if buy_sell_robot_j == 1
		price_robot_j = best_bid;

	elseif buy_sell_robot_j == -1
		price_robot_j = best_ask;
		
	end

elseif robot1_inventory_stor_vec[t] < 0
	message_type = 2;
	
else 
	message_type = 2;
	
end
