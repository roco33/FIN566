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

buy_price = unique(live_buy(:,3));
buy_quantity = [];
buy_number = [];

if ~isempty(buy_price)
    
    for j = 1: length(buy_price)
        buy_quantity = [buy_quantity, sum(live_buy(live_buy(:,3) == ...
            buy_price(j),4))];
        buy_number = [buy_number, length(live_buy(live_buy(:,3) == ...
            buy_price(j),4))];
    end
else
    buy_price = 0;
    buy_quantity = 0;
    buy_number = 0;
end


sell_price = unique(live_sell(:,3));
sell_quantity = [];
sell_number = [];

if ~isempty(sell_price)
    for r = 1: length(sell_price)
        sell_quantity = [sell_quantity, sum(live_sell(live_sell(:,3) == ...
            sell_price(r),4))];
        sell_number = [sell_number, length(live_sell(live_sell(:,3) == ...
            sell_price(r),4))];
    end
else
    sell_price = 0;
    sell_quantity = 0;
    sell_number = 0;
end

best_buy = buy_price(1);
best_sell = sell_price(1);
depth_best_bid = buy_quantity(1);
depth_best_ask = sell_quantity(1);

bid_ask_stor_mat(t,:) = [best_buy, best_sell];
bid_ask_depth_stor_mat(t,:) = [depth_best_bid depth_best_ask];

buy_lob_depth = [buy_number; buy_quantity];
sell_lob_depth = [sell_number; sell_quantity];
