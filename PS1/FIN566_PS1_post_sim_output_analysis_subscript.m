disp(['The total number of trades is ' num2str(size(...
    transaction_price_volume_stor_mat,1))]);
disp(['Process time is ' num2str(process_time) 's']);

spread = bid_ask_stor_mat(:,2) - bid_ask_stor_mat(:,1);

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
    transaction_price_volume_stor_mat(:,6) == acc_id & ...
    transaction_price_volume_stor_mat(:,6) ~= ...
    transaction_price_volume_stor_mat(:,7),[1 2 3 4]);
transaction_z_p = transaction_price_volume_stor_mat(...
    transaction_price_volume_stor_mat(:,7) == acc_id,[1 2 3 4]);
transaction_z_p = transaction_z_p .* repmat([1 -1 1 1], ...
    size(transaction_z_p,1),1);
transaction_z = [transaction_z_a; transaction_z_p];

trade_period = unique(transaction_price_volume_stor_mat(:,1));
price_mat = [1 0];

for y = 2:t_max
    if ismember(y,trade_period)
        trade_price = transaction_price_volume_stor_mat(...
            transaction_price_volume_stor_mat(:,1) == y,3);
        price_mat = [price_mat; y trade_price(length(...
            trade_price))];
    else
        price_mat = [price_mat; y price_mat(y-1,2)];
    end
end


robot_z_acc = [];
robot_z_period = unique(transaction_z(:,1));
for x = 1:t_max
    if ismember(x,robot_z_period)
        time_x_transaction = transaction_z(transaction_z(:,1) == ...
            x, [2 3 4]);
        time_x_transaction = [x * ones(size(time_x_transaction,1),1), ...
            time_x_transaction(:,1) .* time_x_transaction(:,2), ...
            time_x_transaction(:,1) .* time_x_transaction(:,2) .* ...
            time_x_transaction(:,3) * (-1)];
    else 
        time_x_transaction = [x 0 0];
    end
    robot_z_acc = [robot_z_acc; time_x_transaction];
end

z_acc = [1 0 0];
for t1 = 2:t_max
    z_acc = [z_acc; t1 z_acc(t1-1,[2 3]) + robot_z_acc(t1-1, [2 3])];
end

z_acc(:,2) = z_acc(:,2) .* price_mat(:,2);

z_acc = [z_acc, z_acc(:,2) .* price_mat(:,2) + z_acc(:,3)];

subplot(3,2,1),plot(spread);
subplot(3,2,2),bar(LOB,'stack');
subplot(3,2,3),plot(z_acc(:,2));
subplot(3,2,4),plot(z_acc(:,3));
subplot(3,2,5),plot(z_acc(:,4));