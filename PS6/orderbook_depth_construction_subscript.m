%-------------------------------------------------%
%
%        Orderbook Depth Construction Child Script
%
%               Version 1
%               8/5/2013
%
%            First Version: 8/5/2013
%
%-------------------------------------------------%

% This script is intended to be called by parent market-simulation scripts,
% such as "matching_engine_sim_v2f.m"
%
% The purpose of this child script is to compute a summary of the total    
% resting quantity available to buy (sell) at each price-level. 

% The inputs are a list of all the live buy orders and a list of all the live sell
% orders, both sorted according to price-time priority (possibly with some 
% empty rows of zeros at the end. 
%
% The primary outputs are: a vector of the total resting buy depth at each
% price level (buy_lob_depth), and a vector of the total resting sell depth
% at each price level (sell_lob_depth).
%
% These primary outputs are used to construct the following secondary
% outputs: 
%
%       (LOB) A composite summary of depth on each side of the book at each
%   price-level, with the maximum price-level first and the minimum
%   price-level last. The first column lists prices, the second lists buy
%   depth, and the third lists sell depth
%
%       best_bid
%
%       best_ask
%       
%       depth_at_best_bid
%
%       depth_at_best_ask
%
% The best bid/ask prices and depth are stored in matrices from the parent
% script.
%

% %----------------------------------------------------------------------
% Note that the following variables should already exist in the parent
% script:
%
%
%       live_buy_orders_list: dim [t_max, 7]
%       live_sell_orders_list: dim [t_max, 7]
%
%  A row in these lists consists of the following data (for one order): 
%  [account_id, buy/sell, price, quantity, time, order_id, alive_indicator]
%
%
%
%       bid_ask_stor_mat: dim [t_max, 2]
%
%  A row in this list consists of [best_bid_price, best_ask_price], with
%  one row for each order-entry time. Row t gives information about the new
%  state of the book *after* the order entered at time t has been processed
%  through the matching engine.
%
%
%
%       bid_ask_depth_stor_mat: dim [t_max, 2]
%
%  A row in this list consists of [depth_at_best_bid,depth_at_best_ask],
%  with one row for each order-entry time. Row t gives information about 
%  the new state of the book *after* the order entered at time t has been 
%  processed through the matching engine.
%
% %---------------------------------------------------------------------


buy_lob_depth=zeros(max_price,1);
sell_lob_depth=zeros(max_price,1);

num_live_buy_limits=sum(live_buy_orders_list(:,7)); %This is counting the number of orders by summing indicators
num_live_sell_limits=sum(live_sell_orders_list(:,7));

% Recursively add up the resting buy depth at each price-level
if num_live_buy_limits>=1
    for n=1:num_live_buy_limits
        buy_lob_depth(live_buy_orders_list(n,3))=buy_lob_depth(live_buy_orders_list(n,3))+live_buy_orders_list(n,4);
    end
end

% Recursively add up the resting sell depth at each price-level
if num_live_sell_limits>=1
    for n=1:num_live_sell_limits
        sell_lob_depth(live_sell_orders_list(n,3))=sell_lob_depth(live_sell_orders_list(n,3))+live_sell_orders_list(n,4);
    end
end


    % Dealing with the pathological early cases where one side of the book is
    % empty; this is just a modeling artifact
    true_buy_lob_depth_minprice=buy_lob_depth(1);
    true_sell_lob_depth_maxprice=sell_lob_depth(end);

    buy_lob_depth(1)=max(true_buy_lob_depth_minprice,1);
    sell_lob_depth(end)=max(true_sell_lob_depth_maxprice,1);

% Assemble a composite orderbook (with both sides non-empty by construction)
price_index_vector=(max_price:-1:min_price)';
LOB=[price_index_vector,buy_lob_depth(price_index_vector),sell_lob_depth(price_index_vector)];


% Determining select info about the state of the orderbook
best_bid_index=find(LOB(:,2),1,'first');
best_ask_index=find(LOB(:,3),1,'last');

    %Undo the adjustment for pathological empty-book cases
    buy_lob_depth(1)=true_buy_lob_depth_minprice;
    sell_lob_depth(end)=true_sell_lob_depth_maxprice;
    LOB=[price_index_vector,buy_lob_depth(price_index_vector),sell_lob_depth(price_index_vector)];


best_bid=LOB(best_bid_index,1);
best_ask=LOB(best_ask_index,1);

depth_at_best_bid=LOB(best_bid_index,2);
depth_at_best_ask=LOB(best_ask_index,3);


% Store the select info about best bid and ask prices and depth
bid_ask_stor_mat(t,:)=[best_bid,best_ask];
bid_ask_depth_stor_mat(t,:)=[depth_at_best_bid,depth_at_best_ask];









