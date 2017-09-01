% sort live orders
live_buy_orders_list = sortrows(live_buy_orders_list, [-7 -3 5]);
live_sell_orders_list = sortrows(live_sell_orders_list, [-7 3 5]);

% generate new order vector
new_order = [robot_j_acct_id, sell_buy, price_robot_j, quantity_robot_j, ...
    t, order_id, alive_indicator_robot_j];

if new_order(2) == 1 % buy order
    i = 1;
    
    % test aggresive or passive
    if live_sell_orders_lists(i,7) == 0 | new_order(3) < ...
            live_sell_orders_lists(i,3)
        %passive order
        live_buy_orders_list(t_max,4) = 0;
        
    else 
        % agggresive order
        while new_order(4) > live_sell_orders_list(i,3)
            new_order(4) = new_order(4) - live_sell_orders_list(i,4);
            if new_order(4) = 0
                break
            end
        end
    
    if live_sell_orders_list(i,7) == 0 % no awaiting orders
        live_buy_orders_list(t_max,:) = new_order;
    end
    
    % if next sell order is larger than new order
    while new_order(4) >= live_sell_orders_list(i,4)
        live_sell_orders_list(i,4) = 0;
        new_order(4) = new_order(4) - live_sell_orders_list(i,4);
        i = i + 1;
        if live_sell_orders_list(i,4) == 0
            % if no awaiting orders
            break
            live_buy_orders_list(t_max, 4) = 0;
        end
    end
    