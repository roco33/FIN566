disp(['The total number of trades is ' num2str(size(...
    transaction_price_volume_stor_mat,1)) 's']);
disp(['Process time is ' num2str(process_time) 's']);

spread = bid_ask_stor_mat(:,2) - bid_ask_stor_mat(:,1);
plot(spread);

disp(['The average pread after burn-in period ' num2str(mean(spread(...
    burn_in_period:length(spread))))]);

buy_stack = zeros(length(buy_price), max(buy_number));
for s = 1:size(buy_stack,1)
    buy_stack(s,1:buy_number(s)) = live_buy(live_buy(:,3) == ...
        buy_price(s),4)';
end

sell_stack = zeros(length(sell_price), max(sell_number));
for u = 1:size(sell_stack,1)
    sell_stack(u,1:sell_number(u)) = live_sell(live_sell(:,3) == ...
        sell_price(u),4)';
end

acc_id = 5; %robot z: 2-11
robot_z = zeros(t_max,3); % cash, profit, inventory
transaction_z_a = transaction_price_volume_stor_mat(...
    transaction_price_volume_stor_mat(:,6) == acc_id,[1 2 3 4]);
transaction_z_p = transaction_price_volume_stor_mat(...
    transaction_price_volume_stor_mat(:,7) == acc_id,[1 2 3 4]);
transaction_z_p = transaction_z_p .* repmat([1 -1 1 1], ...
    size(transaction_z_p,1),1);
transaction_z = [transaction_z_a; transaction_z_p];




