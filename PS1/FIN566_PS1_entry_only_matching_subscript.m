if buy_sell_robot_j == 1
    live_buy_orders_list(t,:) = [robot_j_acct_id, buy_sell_robot_j, ...
        price_robot_j, quantity_robot_j, t, order_id, ...
        alive_indicator_robot_j];
else live_sell_orders_list(t,:) = [
        
    ]

