%-------------------------------------------------%
%
%           FIN566 PS#3 Meta Meta Script
%
%               Version 5
%               9/25/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%


%% %*****Startup Tasks***********
clear

%*****Setting the appropriate path 
%(This will need to be modified on each student's code)

%'Home'    
Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)


%% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='FIN566_PS2_entry_only_matching_subscript';


%% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


%% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_mm_at_best';%'robot1_algo_mm_at_best_IC';%'robot1_algo_mm_better_price';%


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
prob_last_order_price_resets=0.064;

% Burn-in period
burn_in_period=1322;


%% %*****Designating the Main Simulation Script's Name*****
main_simulation_script='FIN566_PS3_main_script_2017';


%% %*****Designating the Meta-Servant Script's Name*****
meta_servant_script='FIN566_PS3_meta_script_servant';


%% %******Simulation Parameters***********
num_simulation_runs=50;

% %% %******Bootstrap Parameters***********
bootstrap_column_index_choice_vec=5;%[2,4,5,6,9,10,12,13,14];%[1,3,7,8,11];%
num_bootstrap_samples=50000;
confidence_level=0.05;


%% %******* Running the Servant Script***********
initial_prob_last_order_price_resets=prob_last_order_price_resets;
which_side_is_the_true_value=-1;
increment=initial_prob_last_order_price_resets/2;

%%
for l=1:6
    tic
    prob_last_order_price_resets=prob_last_order_price_resets+which_side_is_the_true_value*increment
    
    eval(meta_servant_script)
    bootstrap_CI_results_mat(3:4)
    
    CI_LB=bootstrap_CI_results_mat(3);
    
    if CI_LB<0
      which_side_is_the_true_value=-1;
    else
       which_side_is_the_true_value=1;
    end
    
    increment=increment/2;
    
    toc
end

