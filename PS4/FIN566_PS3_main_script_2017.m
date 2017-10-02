%-------------------------------------------------%
%
%           FIN566 PS#3 Main Script
%
%               Version 7
%               9/20/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=0;

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
Matlab_trading_simulations_folder = pwd
%Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';


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

% watch_interval
watch_interval=2322;

% Number of time-steps
t_max=watch_interval+1000;

% Number of background traders
num_bgt=10;  %  dont change this 

% Quantity ranges
max_quantity=1; % dont change this 

max_potential_quantity_robot1=max_quantity;

% Price range
max_price=1000; % dont change this 
min_price=1;  % dont change this 

% Price-choice flexibility relative to last order price
price_flex=1;  % dont change this 

% Probability that 'last_order_price' resets to robot1's orders' prices
prob_last_order_price_sets_to_price_robot_1=0;  % dont change this 

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.01;%0.011;

% Burn-in period
burn_in_period=1322;    % dont change this 

% theta trgger value 
mm_trigger_value = 0.06;

end


%% %*******Creating Data-Storage Structures***********

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


%% %******* Running the Simulation***********

t=1;
order_id=0;
last_order_price=floor((max_price+min_price)/2);


while t<=t_max
    
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

% for question 2, robot1 only trad after watch_interval
% if (robot1_participation_draw==1)&&(t>burn_in_period)&&(robot1_participate_indic==1)
if (robot1_participation_draw==1)&&(t>watch_interval)&&(robot1_participate_indic==1)

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

%% ----------------
% Number of Transactions
number_of_trades=nnz(transaction_price_volume_stor_mat(:,1));

transaction_price_volume_stor_mat((number_of_trades+1):end,:)=[];

post_burn_in_transactions_start=find((transaction_price_volume_stor_mat(:,1)>burn_in_period),1,'first');
number_of_post_burn_in_transactions=number_of_trades-post_burn_in_transactions_start;

% %%---------------
% Bid-Ask Spread
bid_ask_spread_stor_vec=bid_ask_stor_mat(:,2)-bid_ask_stor_mat(:,1);
mean_bid_ask_spread=mean(bid_ask_spread_stor_vec((burn_in_period+1):end));


% %%---------------
% Tracking P&L, Cash, and Inventory
aggressor_changes_in_net_cash=(-1)*transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4).*transaction_price_volume_stor_mat(:,3);
aggressor_changes_in_net_inventory=transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4);

passor_changes_in_net_cash=(-1)*aggressor_changes_in_net_cash;
passor_changes_in_net_inventory=(-1)*aggressor_changes_in_net_inventory;

positions_changes_mat=[transaction_price_volume_stor_mat(:,1),aggressor_changes_in_net_cash,aggressor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,7),passor_changes_in_net_cash,passor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,6),transaction_price_volume_stor_mat(:,3)];

% %%
robot_account_id=2-robot1_participate_indic;
z=robot_account_id;

robot_z_aggressor_indic=(transaction_price_volume_stor_mat(:,7)==z);
robot_z_passor_indic=(transaction_price_volume_stor_mat(:,6)==z);
robot_z_indic=(robot_z_aggressor_indic|robot_z_passor_indic);

robot_z_aggressive_trades=positions_changes_mat(robot_z_aggressor_indic,[1:3,7]);
robot_z_passive_trades=positions_changes_mat(robot_z_passor_indic,[1,5,6,7]);

robot_z_positions_change_history=[robot_z_aggressive_trades;robot_z_passive_trades];
robot_z_positions_change_history=sortrows(robot_z_positions_change_history,1);
robot_z_mark_to_market_prices=positions_changes_mat(robot_z_indic,8);

cum_robot_z_positions=cumsum(robot_z_positions_change_history(:,2:3),1);
[b,m,n]=unique(robot_z_positions_change_history(:,1),'last');

cum_robot_z_positions_history=[robot_z_positions_change_history(m,1),cum_robot_z_positions(m,:),robot_z_mark_to_market_prices(m)];
mark_to_market_inventory_value_robot_z=cum_robot_z_positions_history(:,3).*cum_robot_z_positions_history(:,4);
robot_z_mark_to_market_P_and_L=mark_to_market_inventory_value_robot_z+cum_robot_z_positions_history(:,2);


if sum(robot_z_indic)==0
    robot_z_max_inventory_position_dollars=0;
    robot_z_max_inventory_position_shares=0;
    robot_z_total_trading_profit=0;
    robot_z_total_trading_volume=0;
    robot_z_final_inventory_position=0;
    robot_z_final_cash_position=0;
    mean_TtE=0;
    median_TtE=0;
    std_TtE=0;
    fraction_of_robot_1_orders_executed=0;
    fraction_of_robot1_orders_placed_mispriced=0;
else
%
robot_z_total_trading_profit=robot_z_mark_to_market_P_and_L(end);
robot_z_total_trading_volume=sum(abs(robot_z_positions_change_history(:,3)));

robot_z_final_inventory_position=mark_to_market_inventory_value_robot_z(end);
robot_z_final_cash_position=cum_robot_z_positions_history(end,2);

robot_z_max_inventory_position_dollars=max(abs(mark_to_market_inventory_value_robot_z));
robot_z_max_inventory_position_shares=max(abs(cum_robot_z_positions_history(:,3)));


% %%-----------------------------
% Time-to-Execution Statistics

robot_z_passor_indic=(transaction_price_volume_stor_mat(:,6)==z);
z_passor_transaction_price_volume_stor_mat=transaction_price_volume_stor_mat(robot_z_passor_indic,:);
time_to_execution_robot_z_orders=z_passor_transaction_price_volume_stor_mat(:,1)-z_passor_transaction_price_volume_stor_mat(:,5);

mean_TtE=mean(time_to_execution_robot_z_orders);
median_TtE=median(time_to_execution_robot_z_orders);
std_TtE=std(time_to_execution_robot_z_orders);


% %%-----------------------------
% Percentage-of-Orders-Executed Statistics
robot_1_live_buy_order_indic=(live_buy_orders_list(:,1)==1);
robot_1_live_sell_order_indic=(live_sell_orders_list(:,1)==1);

number_of_robot_1_live_orders_ending=sum(robot_1_live_buy_order_indic)+sum(robot_1_live_sell_order_indic);
number_of_orders_robot_1_placed=sum(robot1_order_entry_times); 

fraction_of_robot_1_orders_executed=(number_of_orders_robot_1_placed-number_of_robot_1_live_orders_ending)/number_of_orders_robot_1_placed;


% %%-----------------------------
% Percentage-of-Orders-Mispriced Statistics
FV=last_order_price_stor_vec;

bids_too_high_indic=(robot1_order_prices_signed>FV);
asks_too_low_indic=(robot1_order_prices_signed<0).*(robot1_order_prices_signed>((-1)*FV));

num_robot_1_buy_orders_placed=sum((robot1_order_prices_signed>0));
num_robot_1_sell_orders_placed=sum((robot1_order_prices_signed<0));

num_bids_too_high_placed=sum(bids_too_high_indic);
num_asks_too_low_placed=sum(asks_too_low_indic);

robot1_num_mispriced_orders_placed=num_bids_too_high_placed+num_asks_too_low_placed;

fraction_of_robot1_orders_placed_mispriced=robot1_num_mispriced_orders_placed/number_of_orders_robot_1_placed;
end

% %% -----------------------------------

% %% -----------------------------------
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
    fraction_of_robot1_orders_placed_mispriced];
 
%%% -----------------------------------
% % Storing the key results 
% % (Do not use if running the script independently)
if run_main_script_independently_indic==0
    meta_comparison_mat(:,w)=algo_performance_stor_vec;
end





