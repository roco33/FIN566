%-------------------------------------------------%
%
%           FIN580 PS#3 Meta Script TEMPLATE
%
%               Version 5
%               9/16/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%


%% %*****Startup Tasks***********
clear

%*****Setting the appropriate path 
%(This will need to be modified on each student's code)

%'Home'    
% Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';
Matlab_trading_simulations_folder = pwd;

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)


%% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='FIN566_PS2_entry_only_matching_subscript';


%% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


%% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_mm_at_best';%'robot1_algo_mm_at_best';%'robot1_algo_mm_better_price';%


%% %*****Designating the Background-Trader Control-Script Name*****
   %(This can be modified to get different varieties of background traders)
background_trader_commands='bgt_behavior_rw_price';


%% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=1;

% Number of time-steps
t_max=2322;

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
prob_last_order_price_sets_to_price_robot_1=0;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.0005;

% Burn-in period
burn_in_period=1322;


%% %*****Designating the Main Simulation Script's Name*****
main_simulation_script='FIN566_PS3_main_script';


%% %*******Creating Data-Storage Structures***********
meta_comparison_mat=[];


%% %******* Running the [Meta-] Simulation***********

num_simulation_runs=50;

for w=1:num_simulation_runs
    
    eval(main_simulation_script)

end

%
% algo_performance_stor_vec=[number_of_post_burn_in_transactions;
%                            mean_bid_ask_spread;
%                            robot_z_max_inventory_position_dollars;
%                            robot_z_max_inventory_position_shares;
%                            robot_z_total_trading_profit;
%                            robot_z_total_trading_volume;
%                            robot_z_final_inventory_position;
%                            robot_z_final_cash_position;
%                            mean_TtE;
%                            median_TtE;
%                            std_TtE;
%                            fraction_of_robot_1_orders_executed;
%                            fraction_of_robot1_orders_placed_mispriced;
%                            est_prob_last_order_price_resets];
%
% meta_comparison_mat(:,w)=algo_performance_stor_vec;



%% %*****Bootstrap analysis using "meta_comparison_mat"****








