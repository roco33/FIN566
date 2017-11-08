%-------------------------------------------------%
%
%           FIN566 PS#6 Part 2 
%          Meta Script TEMPLATE
%
%               10/29/2017
%
%            First Version: 11/18/2013
%
%-------------------------------------------------%

clear
    
%*****Setting the appropriate path 
    %(This will need to be modified on each individual computer)
    %(I just need to uncomment the appropriate path file)

'Home MBP'
Matlab_trading_simulations_folder=pwd;
%'/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)



% %% %*****Designating the Main Script's Name*****
main_script='FIN66_PS6b_main_script_template';

% %% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='Enter_cancel_mod_matching_subscript_battlebots';

% %% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


% %% %*****Designating the Intelligent Robots' Control-Script Names*****
number_of_smart_robots=2;  

robot1_commands='robot1_algo_mm_PS6b_2017_template';%
robot2_commands='robot2_algo_aggressor_PS6b_2017_template';%

smart_robot_commands_cell=cell(number_of_smart_robots,1);

smart_robot_commands_cell{1}=robot2_commands;
smart_robot_commands_cell{2}=robot2_commands;
% smart_robot_commands_cell{3}=robot2_commands;
% smart_robot_commands_cell{4}=robot2_commands;
% smart_robot_commands_cell{5}=robot2_commands;


% %% %*****Designating the Background-Trader Control-Script Name*****
background_trader_commands='bgt_behavior_rw_price_FAK_ECM';



% %% %*******Setting Model Parameters***********

% Number of time-steps
t_max=6322;

% Burn-in period
burn_in_period=1322;

% Number of background traders
num_bgt=50;

% Combined smart_robots' activity fraction of the total activity
smart_robot_activity_fraction=.4;

% Quantity ranges
max_quantity=19;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=1;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.03;

plopr_intercept=0.01;
plopr_ordersize_param=0.03;
perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);


% %% %*******Creating Data-Storage Structures***********
number_of_simulation_runs=100;

meta_profits_comparison_matrix=zeros(number_of_simulation_runs,number_of_smart_robots);
meta_volume_comparison_matrix=zeros(number_of_simulation_runs,number_of_smart_robots);

% %% %******* Running the Simulation***********

for l=1:number_of_simulation_runs
    l
    tic
    eval(main_script)
    toc
end

meta_profits_per_share_comparison_matrix=meta_profits_comparison_matrix./meta_volume_comparison_matrix;

meta_profits_comparison_vec_mean=mean(meta_profits_comparison_matrix);
meta_profits_comparison_vec_SE=(var(meta_profits_comparison_matrix)/number_of_simulation_runs).^0.5;
meta_volume_comparison_vec_mean=mean(meta_volume_comparison_matrix);
meta_volume_comparison_vec_SE=(var(meta_volume_comparison_matrix)/number_of_simulation_runs).^0.5;
meta_profits_per_share_comparison_vec_mean=mean(meta_profits_per_share_comparison_matrix);
meta_profits_per_share_comparison_vec_SE=(var(meta_profits_per_share_comparison_matrix)/number_of_simulation_runs).^0.5;

meta_performance_comparison_matrix=[(1:number_of_smart_robots); meta_volume_comparison_vec_mean; meta_volume_comparison_vec_SE;...
                                                                meta_profits_comparison_vec_mean;meta_profits_comparison_vec_SE;...
                                                                meta_profits_per_share_comparison_vec_mean;meta_profits_per_share_comparison_vec_SE];
meta_label_array=['robot_account_id_num        ';...
                  'total_trading_volume_mean   ';...
                  'total_trading_volume_SE     ';...
                  'total_trading_profit_mean   ';...
                  'total_trading_profit_SE     ';...
                  'per_share_profit_mean       ';...
                  'per_share_profit_SE         '];
    
labeled_meta_performance_comparison_matrix=[meta_label_array,num2str(meta_performance_comparison_matrix)]

    
    
    



