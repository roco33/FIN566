mispriced_order_ind = robot1_order_prices_signed > 10.5 | (robot1_order_prices_signed > -10.5 & robot1_order_prices_signed < 0);
mispriced_order = robot1_order_prices_signed(mispriced_order_ind);
mispriced_rate = length(mispriced_order) / sum(robot1_order_entry_times)

mispriced_order_id = find(mispriced_order_ind);
robot1_transaction_order_id = robot1_transaction(:,5);
mispriced_order_exe_ind = ismember(mispriced_order_id,robot1_transaction_order_id);
n_mispriced_order_exe = sum(mispriced_order_exe_ind);
mispriced_order_exe_rate = n_mispriced_order_exe / length(mispriced_order)

fairpriced_order_ind = (robot1_order_prices_signed < 10.5 & robot1_order_prices_signed >0) | robot1_order_prices_signed < -10.5;
fairpriced_order = robot1_order_prices_signed(fairpriced_order_ind);
fairpriced_order_id = find(fairpriced_order_ind);
fairprice_order_exe_ind = ismember(fairpriced_order_id, robot1_transaction_order_id);
n_fairprice_order_exe = sum(fairprice_order_exe_ind);
fairprice_order_exe_rate = n_fairprice_order_exe / length(fairpriced_order)