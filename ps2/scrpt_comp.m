
% number of trade
n_trade = length(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,1)~=0,1));
n_trade_burn_in = n_trade - burn_in_period;


