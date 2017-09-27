%-------------------------------------------------%
%
%           FIN566 PS#3 Main Script TEMPLATE
%
%               Version 6
%               9/13/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=1;

% %% %*****Independence Commands*********** (Uncomment to run this script independently)
% clear  
% run_main_script_independently_indic=1; 


% %% %*****Startup Tasks***********

if run_main_script_independently_indic==1 
   'Alert: script is running independently, using locally specified parameter values'
    
clear

%*****Setting the appropriate path 
%(This will need to be modified on each student's code)

%'Home'        
% Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';
Matlab_trading_simulations_folder= pwd;


p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)

% %% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='FIN566_PS2_entry_only_matching_subscript';


% %% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


% %% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_mm_at_best';%'robot1_algo_mm_at_best';%'robot1_algo_mm_better_price';%


% %% %*****Designating the Background-Trader Control-Script Name*****
   %(This can be modified to get different varieties of background traders)
background_trader_commands='bgt_behavior_rw_price';



% %% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=1;

% Number of time-steps
t_max=11322;

% Number of background traders
num_bgt=10;

% Quantity ranges
max_quantity=1;

max_potential_quantity_robot1=max_quantity;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=1;

% Probability that 'last_order_price' resets to robot1's orders' prices
prob_last_order_price_sets_to_price_robot_1=1;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=1;%0.011,0.064;

% Burn-in period
burn_in_period=1322;

end


% %% %*******Creating Data-Storage Structures***********

% Storing live orders
    % account_id, buy/sell, price, quantity, time, order_id, alive_indicator
live_buy_orders_list=zeros(t_max,7);
live_sell_orders_list=zeros(t_max,7);

% Storing historical liquidity statistics
    % bid statistic, ask statistic
bid_ask_stor_mat=zeros(t_max,2);
bid_ask_depth_stor_mat=zeros(t_max,2);

% Storing transaction information
    % time, aggressor sign, price, executed quantity, passor order_id,passor_account_id, aggressor_account_id
transaction_price_volume_stor_mat=zeros(t_max,7);
transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];

% Storing robot1's inventory and inventory changes
robot1_cum_net_inventory=0;
robot1_inventory_stor_vec=zeros(t_max,1);

% Marking the times when robot1 places an order
robot1_order_entry_times=zeros(t_max,1);

% Recording the prices and sign (stored as price_robot_j*buy_sell_robot_j)
robot1_order_prices_signed=zeros(t_max,1);

% Storing the underlying FV price ("last_order_price") and the actual
% price at which each order is entered
last_order_price_stor_vec=zeros(t_max,1);
entered_order_price_stor_vec=zeros(t_max,1);


% %% %******* Running the Simulation***********

t=1;
order_id=0;
last_order_price=floor((max_price+min_price)/2);


while t<t_max
    
%-----------------------------------------------------------
% Generate a random new limit order
%-----------------------------------------------------------
order_id=order_id+1;

% Randomly select a background trader other than robot1
robot_j_acct_id=randi(num_bgt)+1; %Note that this random account id will be strictly greater than 1

eval(background_trader_commands);
    %Outputs from 'background_trader_commands' must include the following: 
    %
    %   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
    %   price_robot_j (price of the order)
    %   quantity_robot_j (quantity of the order)
    %   alive_indicator_robot_j (a 0/1 indicator variable of whether the order is still "live" and hence should be included in the updated orderbook)

entered_order_price_stor_vec(t)=price_robot_j;

%--------------------------------------------------------------------
%   Determine randomly (with given prob.) whether last_order_price resets
%--------------------------------------------------------------------

 test_for_last_order_price_choice_j=rand(1);
 
    if test_for_last_order_price_choice_j<prob_last_order_price_resets
        last_order_price=price_robot_j; 
    end

%-----------------------------------------------------------
% Process the new order through the matching-engine script
%-----------------------------------------------------------
eval(matching_engine_algo);
    %'matching_engine_algo' updates the following variables:
    %
    %   live_buy_orders_list
    %   live_sell_orders_list
    %
    %   transaction_price_volume_stor_mat
    %
    %   robot1_cum_net_inventory
robot1_inventory_stor_vec(t)=robot1_cum_net_inventory;

%-----------------------------------------------------------
% Constructing orderbook depth
%-----------------------------------------------------------
eval(orderbook_construction_code);
    %'orderbook_construction_code' updates/outputs the following variables:
    %
    %   best_bid
    %   best_ask
    %   depth_at_best_bid
    %   depth_at_best_ask
    %
    %   bid_ask_stor_mat
    %   bid_ask_depth_stor_mat
    %
    %   buy_lob_depth
    %   buy_lob_depth
    %   LOB
  last_order_price_stor_vec(t)=last_order_price;
%-----------------------------------------------------------
%increasing the time increment
%-----------------------------------------------------------
t=t+1;


%------------------------------------------------------
%------------------------------------------------------
% Now the intelligent algorithmic trader, robot1, gets his shot to act.  In
% this version, robot1 can only place orders (of his specification), or
% not. Cancellation and modification are not accommodated in this version.
% They will be incorporated into future versions.
%------------------------------------------------------
%------------------------------------------------------

% Robot1 specifies his orders using the same buy/sell, price, and quantity
% parameters as everyone else. The difference is that Robot1 can condition
% his orders on the state of the orderbook, etc., in flexible ways.

parent_script_only_price=last_order_price;

% Robot1 only gets the opportunity to act as often (on average) as each
% background trader.  This can be trivially changed in future versions.
robot1_participation_draw=randi((num_bgt+1));

if (robot1_participation_draw==1)&&(t>burn_in_period)&&(robot1_participate_indic==1)

order_id=order_id+1;

robot_j_acct_id=1;%DON'T change this! It identifies that the order belongs to robot1

%------------------------------------------------------------------
% Run the separate script that controls robot1 to generate his order
%------------------------------------------------------------------
eval(robot1_commands);
    %Outputs from 'robot1_commands' must include the following: 
    %   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
    %   price_robot_j (price of the order)
    %   quantity_robot_j (quantity of the order)
    
entered_order_price_stor_vec(t)=price_robot_j;

%-----------------------------------------------------------
% Screening robot1's order and possibly updating last_order_price
%-----------------------------------------------------------

%This section of code reject an order from robot1 if the price is outside
%the range permitted by the matching algorithm. This code also corrects
%"last_order_price" if it somehow got changed by the "robot1_commands"
%script (that should only ever happen by mistake).

last_order_price=parent_script_only_price;
    
if (price_robot_j<=max_price)&&(price_robot_j>=min_price)
    test_for_last_order_price_choice=rand(1);
    if test_for_last_order_price_choice<prob_last_order_price_sets_to_price_robot_1
        last_order_price=price_robot_j; 
    end
else
    price_robot_j=last_order_price;
    quantity_robot_j=0;
end

if quantity_robot_j==0
    alive_indicator_robot_j=0;
end

%-----------------------------------------------------------
% Storing some stats about robot1's order
%-----------------------------------------------------------
robot1_order_entry_times(t)=alive_indicator_robot_j;
robot1_order_prices_signed(t)=alive_indicator_robot_j*price_robot_j*buy_sell_robot_j;

%-----------------------------------------------------------
% Process robot1's order through the matching-engine script
%-----------------------------------------------------------
eval(matching_engine_algo);

robot1_inventory_stor_vec(t)=robot1_cum_net_inventory;

%-----------------------------------------------------------
% Constructing orderbook depth
%-----------------------------------------------------------
eval(orderbook_construction_code);

last_order_price_stor_vec(t)=last_order_price;

%-----------------------------------------------------------
%increasing the time increment
%-----------------------------------------------------------
t=t+1;

end


end

transaction_price_volume_stor_mat(1,:)=[];
robot1_inventory_stor_vec(end) = robot1_inventory_stor_vec(end-1) + robot1_inventory_changes(end);
% %%----------------
% Number of Transactions
% 
number_of_post_burn_in_transactions = length(transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,1)>burn_in_period,1));


% %%---------------
% Bid-Ask Spread
%
mean_bid_ask_spread = mean(bid_ask_stor_mat([burn_in_period:end],2) - bid_ask_stor_mat([burn_in_period:end],1));


% %%---------------
% Tracking P&L, Cash, and Inventory

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
cash_chg = - price .* inv_chg;

cash_pos = zeros(t_max,1);
for j = 1:t_max
	try 
		cash_pos(j) = cash_pos(j-1) + cash_chg(j);
	catch ME
		cash_pos(j) = 0;
	end
end

trading_profit = cash_pos + robot1_inventory_stor_vec .* price;
robot_z_total_trading_profit = trading_profit(length(trading_profit));
robot_z_total_trading_volume = sum(abs(robot1_inventory_changes)); 

robot_z_final_inventory_position= robot1_inventory_stor_vec(end)*price(end);
robot_z_final_cash_position = cash_pos(end);

robot_z_max_inventory_position_dollars = max(abs(robot1_inventory_stor_vec) .* price);
robot_z_max_inventory_position_shares = max(abs(robot1_inventory_stor_vec));

% %%-----------------------------
% Time-to-Execution Statistics

robot1_transaction = transaction_price_volume_stor_mat(transaction_price_volume_stor_mat(:,6) == 1,:);
tte = robot1_transaction(:,1) - robot1_transaction(:,5);
mean_TtE = mean(tte);
median_TtE = median(tte);
std_TtE = std(tte);


% %%-----------------------------
% Percentage-of-Orders-Executed Statistics

fraction_of_robot_1_orders_executed = length(tte) / sum(robot1_order_entry_times);


% %%-----------------------------
% Percentage-of-Orders-Mispriced Statistics

mispriced_order_ind = robot1_order_prices_signed > last_order_price_stor_vec | (robot1_order_prices_signed > - last_order_price_stor_vec & robot1_order_prices_signed < 0);
mispriced_order = robot1_order_prices_signed(mispriced_order_ind);

fraction_of_robot1_orders_placed_mispriced = length(mispriced_order) / sum(robot1_order_entry_times);


% %%-----------------------------------
% % Estimating prob_last_order_price_resets

est_prob_last_order_price_resets = sum(robot1_order_prices_signed == last_order_price_stor_vec)/sum(robot1_order_entry_times);


% %%-----------------------------------
% % Collecting all of the key results
algo_performance_stor_vec=[number_of_post_burn_in_transactions;
    mean_bid_ask_spread;
    robot_z_max_inventory_position_dollars;
    robot_z_max_inventory_position_shares;
    robot_z_total_trading_profit;
    robot_z_total_trading_volume;
    robot_z_final_inventory_position;
    robot_z_final_cash_position;
    mean_TtE;
    median_TtE;
    std_TtE;
    fraction_of_robot_1_orders_executed;
    fraction_of_robot1_orders_placed_mispriced;
    est_prob_last_order_price_resets
	];
 
% %%-----------------------------------
% % Storing the key results 
% % (Do not use if running the script independently)
% meta_comparison_mat=[meta_comparison_mat, algo_performance_stor_vec];



