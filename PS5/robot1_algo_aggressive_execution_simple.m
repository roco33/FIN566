% This is an algorithm for "robot1" that will interact with the market

% In this script, robot_1 places a market BUY order for quantity
% "max_potential_quantity_robot1"
% (Can alter code so that robot_1 chooses a random direction, or always sells)
% (Can also alter code to specify some other order quantity, if desired)


alive_indicator_robot_j=1;

if t == t_max+1 && robot1_inventory_stor_vec(t-1) >= 500
	alive_indicator_robot_j=0
end

FAK_indic=1;

% set order buy/sell
buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

% MAKING IT A BUY
buy_sell_robot_j=1;

%set order price
if buy_sell_robot_j==1
    price_robot_j=max_price;
	% at best -------------------------
	% price_robot_j=best_bid;
	%----------------------------------
	% at better------------------------
    % if best_ask - best_bid > 1
		% price_robot_j=best_bid + 1; % set the price at least 1 tick lower than the best ask, ?what is min_price
	% else 
		% price_robot_j = best_ask - 1;
	% end	
	%----------------------------------
	%at 1 worse
	% if min_price < best_bid - 1
		% price_robot_j= best_bid - 1; % set the price at least 1 tick lower than the best ask, ?what is min_price
	% else 
		% price_robot_j = min_price;
	% end
	%---------------------------------
   
else
    price_robot_j=min_price;
	% at best -------------------------
	% price_robot_j=best_ask;
	%----------------------------------
	% at better------------------------
	% if best_ask - best_bid > 1
		% price_robot_j=best_ask - 1; % if the order is a sell order, set the price at least 1 ticker higher than the best bid, ?what is max_price
	% else
		% price_robot_j = best_bid + 1;
	% end
	%----------------------------------
	% at 1 worse-----------------------
	% if max_price > best_ask + 1
		% price_robot_j= best_ask + 1; % if the order is a sell order, set the price at least 1 ticker higher than the best bid, ?what is max_price
	% else
		% price_robot_j = max_price;
	% end
	%-----------------------------------
	
    
end

% set order quantity
if t == t_max+1 && robot1_inventory_stor_vec(t-1) < 500
	price_robot_j=max_price;
	quantity_robot_j=500-robot1_inventory_stor_vec(t-1);
else
	quantity_robot_j=max_potential_quantity_robot1;
end   