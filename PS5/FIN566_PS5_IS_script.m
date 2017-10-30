%-------------------------------------------------%
%
%     FIN566 PS#5 Implementation Shortfall Script
%
%               Version 4
%               10/17/2017
%
%            First Version: 10/9/2014
%
%-------------------------------------------------%

% This script needs to be run as a subscript of 'FIN566_PS5_main_script...'

% %% Implementation Shortfall Stuff
% Number of Transactions
number_of_trades=nnz(transaction_price_volume_stor_mat(:,1));

% Clean out all the rows with 0
transaction_price_volume_stor_mat((number_of_trades+1):end,:)=[];

% Find the index where post burn period starts
post_burn_in_transactions_start=find((transaction_price_volume_stor_mat(:,1)>burn_in_period),1,'first');
% Find the number of transactions in burn in transaction
number_of_post_burn_in_transactions=number_of_trades-post_burn_in_transactions_start;

% %% ---------------
% Calculate the mid-point price 
bid_ask_midpoint_stor_vec=mean(bid_ask_stor_mat,2);
TWAP=mean(bid_ask_midpoint_stor_vec((burn_in_period+1):end));

% Post burn in transaction 
PBI_transaction_price_volume_stor_mat=transaction_price_volume_stor_mat(post_burn_in_transactions_start:end,:);
% price_i * quantity_i / total quantity
VWAP=(PBI_transaction_price_volume_stor_mat(:,3)'*PBI_transaction_price_volume_stor_mat(:,4))/sum(PBI_transaction_price_volume_stor_mat(:,4));

% %% -------------------
% time, aggressor sign, price, executed quantity, passor order_id,passor_account_id, aggressor_account_id
transaction_price_volume_stor_mat;

% Find robot1 orders
robot1_transaction_data_mat=transaction_price_volume_stor_mat(((transaction_price_volume_stor_mat(:,6)==1)|(transaction_price_volume_stor_mat(:,7)==1)),:);

% robot1 trading cost = sum(price * quantity), robot1 trading volume = sum(volume), trading cost per share
robot1_actual_trading_cost=robot1_transaction_data_mat(:,3)'*robot1_transaction_data_mat(:,4);
robot1_trading_volume=sum(robot1_transaction_data_mat(:,4));
robot1_actual_trading_cost_per_share=robot1_actual_trading_cost/robot1_trading_volume;

% benchmark cost = benchmark price * quantity , cost per share = benchmark cost/trading volume
robot1_trading_times=robot1_transaction_data_mat(:,1);
bam_benchmark_prices=bid_ask_midpoint_stor_vec(robot1_trading_times-1);
bam_benchmark_cost=bam_benchmark_prices'*robot1_transaction_data_mat(:,4);
bam_benchmark_cost_per_share=bam_benchmark_cost/robot1_trading_volume;

% Find +50 benchmark, benchmark cost = benmark price * volume, benchmark cost per share 
robot1_trading_times_plus50=robot1_trading_times+50;
robot1_trading_times_plus50=min(robot1_trading_times_plus50,(t_max-1));
bamplus50_benchmark_prices=bid_ask_midpoint_stor_vec(robot1_trading_times_plus50);
bamplus50_benchmark_cost=bamplus50_benchmark_prices'*robot1_transaction_data_mat(:,4);
bamplus50_benchmark_cost_per_share=bamplus50_benchmark_cost/robot1_trading_volume;

%
robot1_IS_vs_bam=robot1_actual_trading_cost_per_share-bam_benchmark_cost_per_share;
robot1_IS_vs_bamplus50=robot1_actual_trading_cost_per_share-bamplus50_benchmark_cost_per_share;
robot1_IS_vs_TWAP=robot1_actual_trading_cost_per_share-TWAP;
robot1_IS_vs_VWAP=robot1_actual_trading_cost_per_share-VWAP;

%
bid_ask_spread_stor_vec=bid_ask_stor_mat(:,2)-bid_ask_stor_mat(:,1);
mean_bid_ask_spread=mean(bid_ask_spread_stor_vec((burn_in_period+1):end));
mean_bid_ask_spread_when_robot1_entered_orders=mean(bid_ask_spread_stor_vec(robot1_trading_times-1));

%
IS_bam_bam50_TWAP_VWAP=[robot1_IS_vs_bam;...
 robot1_IS_vs_bamplus50;...
 robot1_IS_vs_TWAP;...
 robot1_IS_vs_VWAP];

half_mean_bid_ask_spread=mean_bid_ask_spread/2;
half_mean_bid_ask_spread_when_robot1_entered_orders=mean_bid_ask_spread_when_robot1_entered_orders/2;


%IS_bam_bam50_TWAP_VWAP

