
% number of trade
n_trade = length(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,1)~=0,1));
n_trade_burn_in = n_trade - burn_in_period;

% spread
sprd = bid_ask_stor_mat(:,2) - bid_ask_stor_mat(:,1);
avg_sprd_buin_in = mean(sprd(burn_in_period:length(sprd)))

