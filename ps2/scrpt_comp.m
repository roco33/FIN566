
% number of trade
n_trade = length(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,1)~=0,1));
n_trade_burn_in = n_trade - burn_in_period;
disp(['The number of trade is ', num2str(n_trade_burn_in)]);

% spread
sprd = bid_ask_stor_mat(:,2) - bid_ask_stor_mat(:,1);
avg_sprd_buin_in = mean(sprd(burn_in_period:length(sprd)));
disp(['The average spread is ', num2str(avg_sprd_buin_in)]);

% robot 1 inventory position
max_inv_rob1 = max(robot1_inventory_stor_vec);
disp(['The maximum inventory position in shares is ', num2str(max_inv_rob1)]);

price = zeros(t_max,1);
for i = 1:t_max
	if ismember(i, transaction_price_volume_stor_mat(:,1))
		price(i) = transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,1) == i,3);
	else 
		try
			price(i) = price(i - 1);
		catch ME 
			price(i) = 0;
		end
	end
end 

inv_pos_0 = [0; robot1_inventory_stor_vec(1:length(robot1_inventory_stor_vec)-1)];
inv_pos_1 = robot1_inventory_stor_vec;
inv_chg = inv_pos_1 - inv_pos_0;
cash_chg = - inv_chg .* price;
cash_pos = zeros(t_max,1);
for j = 1:t_max
	try 
		cash_pos(j) = cash_pos(j-1) + cash_chg(j);
	catch ME
		cash_pos(j) = 0;
	end
end

blnc = cash_pos + robot1_inventory_stor_vec .* price;

prft = blnc(2:length(blnc)) - blnc(1:length(blnc)-1);
disp(['The final profit for robot1 is ', num2str(blnc(length(blnc)))]);

% robot 1 trading volume
n_act_order = size(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,6) == 1),1);
n_pass_order = size(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,7) == 1),1);
n_self_cross = size(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,6) == 1 & transaction_price_volume_stor_mat(:,7) == 1),1);
n_trade_robot1 = n_act_order + n_pass_order - n_self_cross;

disp(['Robot1 total trading volume is ', num2str(n_trade_robot1)]);

% time-to-execution
robot1_transaction = transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,6) == 1,:);
tte = robot1_transaction(:,1) - robot1_transaction(:,5);
disp(['Mean time-to-execution ', num2str(mean(tte))]);
disp(['Median time-to-execution ', num2str(median(tte))]);
disp(['Standard deviation ', num2str(std(tte))]);
hist(tte)

rate_exe_order = length(tte) / sum(robot1_order_entry_times);
disp([num2str(rate_exe_order * 100), '% of orders are executed'])



