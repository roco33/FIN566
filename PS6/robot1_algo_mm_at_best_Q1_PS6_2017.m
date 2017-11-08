robot1_order_size = 1;
FAK_indic=0;

% new orders
if robot1_inventory_stor_vec(t) == 0
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

% modification orders & new order 
% if net inventory is positive, then cancle all buy orders and set passive sell
elseif robot1_inventory_stor_vec(t) > 0
	if (ismember(1,live_buy_orders_list(:,1))
		message_type = 2;
		order_index = find(live_buy_orders_list(:,1),1);
		order_id = live_buy_orders_list(order_index,6);
		quantity_robot_j = 0;
	else
		message_type = 1;% new order
		alive_indicator_robot_j = 1;% alive order
		quantity_robot_j = robot1_order_size;
		buy_sell_robot_j = -1;% sell order
		price_robot_j = best_ask;% best ask price
	end
	
% if net inventory is negative, then cancle all sell orders and set passive buy
elseif robot1_inventory_stor_vec(t) < 0
	message_type = 1;% new order
	alive_indicator_robot_j = 1;% alive order
	quantity_robot_j = robot1_order_size;
	buy_sell_robot_j = 1;% buy order
	price_robot_j = best_bid;% best bid price

end
