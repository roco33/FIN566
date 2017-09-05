%-------------------------------------------------%
%
%        FIN566 PS1 Main Script TEMPLATE
%
%             Adam D. Clark-Joseph
%   University of Illinois at Urbana-Champaign
%
%                Version 2
%                8/18/2017
%
%
%-------------------------------------------------%


%% %*****Startup Tasks***********
clear

%*****Setting the appropriate path 
%(This will need to be modified on each student's code)

%'Home'    
%Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';
Matlab_trading_simulations_folder='C:\Users\roco33\Documents\MATLAB\FIN566\PS1';
%Matlab_trading_simulations_folder='C:\Users\roco3\Documents\MATLAB\FIN566\PS1';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)


%% %*****Designating the Matching-Engine Script's Name*****
%(This will need to be modified on each student's code)
matching_engine_algo='FIN566_PS1_entry_only_matching_subscript';


%% %*****Designating the Orderbook-Construction Script's Name*****
%(This will need to be modified on each student's code)
orderbook_construction_code='FIN566_PS1_orderbook_depth_construction_subscript';


%% %*****Designating the Background-Trader Control-Script Name*****
%(This will need to be modified on each student's code) 

% %Can change this to get different varieties of background traders.
background_trader_commands='bgt_behavior_uniform_price';

%% %*****Designating Post-Simulation Output-Analysis Script's Name*****
%(This will need to be modified on each student's code)
sim_output_analysis_code='FIN566_PS1_post_sim_output_analysis_subscript';



%% %*******Setting Model Parameters***********

% Number of time-steps
t_max=6322;

% Number of background traders
num_bgt=10;

% Quantity ranges
max_quantity=100;

% Price range
max_price=20;
min_price=1;

% Burn-in period
burn_in_period=3322;


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
%transaction_price_volume_stor_mat=zeros(t_max,7);
transaction_price_volume_stor_mat = [];
    % As a peculiarity of how I wrote my code, it is convenient to put a
    % row of ones at the top of "transaction_price_volume_stor_mat"
    % initially, and then remove it at the very end.
%transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];

    % Note: there will not necessarily be t_max transactions that occur,
    % but there cannot be more than t_max. If we used a system other than
    % price-time priority (and maximum order-size was greater than 1), 
    % t_max might not be an upper bound on the number of transactions. 


%% %******* Running the Simulation***********

t=1;
order_id=0;

tic;

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
    %   sell_lob_depth
    %   LOB
    
%-----------------------------------------------------------
%increasing the time increment
%-----------------------------------------------------------
t=t+1;


end

process_time = toc;

%transaction_price_volume_stor_mat(1,:)=[]; %Removing the row of ones 

%% ----------------

eval(sim_output_analysis_code)

%%



