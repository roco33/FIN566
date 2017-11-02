%-------------------------------------------------%
%
%           FIN580 PS#5 Part 2 Meta Script Template
%
%               Version 4
%               10/17/2017
%
%            First Version: 10/17/2013
%
%-------------------------------------------------%
clear

%*****Setting the appropriate path 
    %(This will need to be modified on each individual computer)
    
Matlab_trading_simulations_folder=pwd;


p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)


% %% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='FIN566_FAK_entry_only_matching_subscript';


% %% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


% %% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_aggressive_execution_PS5_part2_template';%


% %% %*****Designating the Background-Trader Control-Script Name*****
   %(This can be modified to get different varieties of background traders)
background_trader_commands='bgt_behavior_rw_price_FAK';


% %% %*****Designating the Slave-Script Name*****
slave_script='FIN566_PS5_part2_main_script_template';



% %% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=1;

% Number of time-steps
t_max=6322;

% Burn-in period
burn_in_period=1322;

% Number of background traders
num_bgt=50;

% Quantity ranges
max_quantity=9;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=1;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.03;

plopr_intercept=0.01435;%
plopr_ordersize_param=0.01435;%
perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);

% Scaling of PLOPR if the order was placed by robot1
plopr_scaling_robot1=1;

% number of simulation runs
num_sim_runs=50;

% robot1 order every g period
g = 10;%250,25,10

% %% %*******Creating Data-Storage Structures***********

% Meta storage mat
    % robot1_trading_volume, IS_vs_SoD, half_mean_bid_ask_spread_when_robot1_entered_orders
    % "SoD" stands for "Start of Day" (i.e., the benchmark bid-ask midpoint price in the first period that robot_1 trades) 
meta_storage_mat=zeros(num_sim_runs,3);

% %% %*******Running the simulation***********

for d=1:num_sim_runs
    d
    tic
   eval(slave_script);
   
   meta_storage_mat(d,:)=results_stor_vec;
   toc

end

mean(meta_storage_mat(:,1))
mean(meta_storage_mat(:,2:3))


%%  %*******Bootstrapping***********

num_bootstrap_samples=10000;
confidence_level=0.05;

bootstrap_stor_vec=zeros(num_bootstrap_samples,1);

for p=1:num_bootstrap_samples
    
    bootstrap_sample_index=randi(num_sim_runs,[num_sim_runs,1]);
    boostrap_draw=meta_storage_mat(bootstrap_sample_index,2);
    
    bootstrap_stor_vec(p)=mean(boostrap_draw);   
end

bootstrap_stor_vec_sorted=sort(bootstrap_stor_vec);

figure(1)
plot(((1:num_bootstrap_samples)'/num_bootstrap_samples),bootstrap_stor_vec_sorted)

confidence_interval=[bootstrap_stor_vec_sorted(floor(num_bootstrap_samples*confidence_level/2)),bootstrap_stor_vec_sorted((num_bootstrap_samples-floor(num_bootstrap_samples*confidence_level/2)))]
