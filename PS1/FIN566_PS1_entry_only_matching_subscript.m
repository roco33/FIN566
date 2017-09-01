% select live orders, list.alive == 1
live_buy = live_buy_orders_list(live_buy_orders_list(:,7) == 1, :);
live_sell = live_sell_orders_list(live_sell_orders_list(:,7) == 7,: );

% sort live orders by price and arriving time
% descending in price, ascending in time for bids
bid_order = sortrows(live_buy, [-3 5]);
% ascending in price and time for asks
ask_order = sortrows(live_sell, [3 5]); 

% test the new order is a agressive order or passive order
if buy_sell_robot_j == 1 % buy order
    
    % aggresive order
    if price_robot_j >= min(ask_order(:, 3)) & ~isempty(ask_order)
        i = 1;
        exe_order = [];
        
% if the new order is larger than the best ask order        
        while quantity_robot_j >= ask_order(i, 4) 
            quantity_robot_j = quantity_robot_j - ask_order(i,4);
            exe_order = [exe_order; ask_order(i,6)];
            i = i + 1;
            try
                ask_order(i,4);
            catch
                break
            end
        end
        
%take out all exectuted orders        
        live_sell_orders_list(exe_order, 7) = 0; % alive = 0
        live_sell_orders_list(exe_order, 4) = 0; % remaining quantity = 0
        
% the new order is smaller than the best ask order   
        if quantity_robot_j > 0
            live_sell_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
                price_robot_j, quantity_robot_j, t, order_id, ...
                alive_indicator_robot_j]; 
        elseif quantity_robot_j > 0
            live_sell_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
                price_robot_j, quantity_robot_j, t, order_id, 1]; 
        else
            last_transection = bid_order(i, 6);
            live_buy_orders_list(last_transection,4) = live_buy_orders_list...
                (last_transection,4) - quantity_robot_j;
        end
        
    % passive order
    else live_sell_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
        price_robot_j, quantity_robot_j, t,order_id, ...
        alive_indicator_robot_j];
    end
    
elseif buy_sell_robot_j == -1 % sell order
    
    % aggresive order
    if price_robot_j <= max(bid_order(:, 3)) & ~isempty(bid_order)
        i = 1;
        exe_order = [];
% if the new order is larger than the best ask order
        while quantity_robot_j >= bid_order(i, 4)
            quantity_robot_j = quantity_robot_j - bid_order(i,4);
            exe_order = [exe_order; bid_order(i,6)];
            i = i + 1;
            try
                bid_order(i,4);
            catch
                break % no awaiting orders
            end
        end
        
        live_buy_orders_list(exe_order, 7) = 0;
        live_buy_orders_list(exe_order, 4) = 0;
        
        if quantity_robot_j >= 0
            live_buy_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
                price_robot_j, quantity_robot_j, t, order_id, ...
                alive_indicator_robot_j]; 
        else
            last_transection = bid_order(i, 6);
            live_buy_orders_list(last_transection,4) = live_buy_orders_list...
                (last_transection,4) - quantity_robot_j;
        end
    
    % passive order
    else live_buy_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
        price_robot_j, quantity_robot_j, t, order_id, ...
        alive_indicator_robot_j];        
    end
    
end
        
