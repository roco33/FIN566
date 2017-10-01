%-------------------------------------------------%
%
%           FIN566 PS#3 Meta Script
%
%               Version 6
%               9/26/2017
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


%% %******* Running the [Meta-] Simulation***********

num_simulation_runs=50;

%% %*******Creating Data-Storage Structures***********
meta_comparison_mat=zeros(13,num_simulation_runs);

%%
tic
for w=1:num_simulation_runs
 %tic
  
    eval(main_simulation_script)

 toc
  %w
end
toc

%%
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
%                            fraction_of_robot1_orders_placed_mispriced];
%                            %est_prob_last_order_price_resets];

mean(meta_comparison_mat,2)

%label_meta_comparison_mat=['meta_comparison_mat_',robot1_commands,'_',int2str(num_simulation_runs),'_runs','.mat'];
%save(label_meta_comparison_mat,'meta_comparison_mat','robot1_commands','background_trader_commands','robot1_participate_indic','t_max','num_bgt','max_quantity','max_price','min_price','price_flex','prob_last_order_price_resets','burn_in_period','main_simulation_script','num_simulation_runs');

%%

meta_comparison_mat_col_stor=meta_comparison_mat';

bootstrap_column_index_choice_vec=5;%[2,4,5,6,9,10,12,13];%,14];%[1,3,7,8,11];%
num_bootstrap_samples=50000;
confidence_level=0.05;

bootstrap_CI_results_mat=zeros(length(bootstrap_column_index_choice_vec),4);

lower_cutoff=floor(confidence_level*num_bootstrap_samples/2);
upper_cutoff=num_bootstrap_samples-lower_cutoff;

for h=1:length(bootstrap_column_index_choice_vec)

    bootstrap_column_index=bootstrap_column_index_choice_vec(h);

    bootstrap_samples_stor_vec=zeros(1,num_bootstrap_samples);

    for w=1:num_bootstrap_samples
        sample_indices=randi(num_simulation_runs,[1,num_simulation_runs]);
        sample_values_vec=meta_comparison_mat_col_stor(sample_indices,bootstrap_column_index);    
        bootstrap_samples_stor_vec(w)=mean(sample_values_vec);    
    end

bootstrap_samples_stor_vec_sorted=sort(bootstrap_samples_stor_vec);

bootstrap_CI_lower=bootstrap_samples_stor_vec_sorted(lower_cutoff);
bootstrap_CI_upper=bootstrap_samples_stor_vec_sorted(upper_cutoff);

bootstrap_CI_results_mat(h,:)=[bootstrap_column_index,confidence_level,bootstrap_CI_lower,bootstrap_CI_upper];

end

bootstrap_CI_results_mat

%%
