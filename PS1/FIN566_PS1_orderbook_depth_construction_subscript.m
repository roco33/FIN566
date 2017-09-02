%   best_bid
%   best_ask
%   depth_at_best_bid
%   depth_at_best_ask
%
%   bid_ask_stor_mat
%   bid_ask_depth_stor_mat
%
%   buy_lob_depth
%   sell_lob_depth
%   LOB

live_buy = live_buy_orders_list(live_buy_orders_list(:,7) == 1,:);
live_sell = live_sell_orders_list(live_sell_orders_list(:,7) == 1,:);

if isempty(live_buy)
    best_bid = 0;
else 
    best_bid = max(live_buy(:,3));
end

if isempty(live_sell)
    best_ask = 0;
else 
    best_ask = min(live_sell(:,3));
end

depth_best_bid = sum(live_buy(live_buy(:,3) == best_bid,4));
depth_best_ask = sum(live_sell(live_sell(:,3) == best_ask,4));

bid_ask_stor_mat(t,:) = [best_bid, best_ask];
bid_ask_depth_mat(t,:) = [depth_best_bid, depth_best_ask];

