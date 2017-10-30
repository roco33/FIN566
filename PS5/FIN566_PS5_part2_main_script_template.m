%-------------------------------------------------%
%
%     FIN566 PS#5 Part 2 Main Script Template
%
%               Version 5
%               10/17/2017
%
%            First Version: 10/17/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=0;

%*****Independence Commands*********** (Uncomment to run this script independently)
%clear
run_main_script_independently_indic=1; 
% tic


% %% %*****Startup Tasks***********

if run_main_script_independently_indic==1
   'Alert: script is running independently, using locally specified parameter values'
    
%*****Setting the appropriate path 
    %(This will need to be modified on each individual computer)

Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';

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



% %% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=0;

% Number of time-steps
t_max=1322;

% Burn-in period
burn_in_period=1322;

% Number of background traders
num_bgt=50;

% Quantity ranges
max_quantity=3;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=3;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.03;

plopr_intercept=0.8;
plopr_ordersize_param=0.8;
perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);

% Scaling of PLOPR if the order was placed by robot1
plopr_scaling_robot1=1;

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
entered_order_quantity_stor_vec=zeros(t_max,1);


% %% %******* Running the Simulation***********

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
    %   FAK_indic (a 0/1 indicator of whether the order should remain in the orderbook after any immediate matches are made) 
    
entered_order_price_stor_vec(t)=price_robot_j;
entered_order_quantity_stor_vec(t)=quantity_robot_j;

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

%--------------------------------------------------------------------
%   Determine randomly (with given prob.) whether last_order_price resets
%--------------------------------------------------------------------
if (number_of_execution_records>start_of_time_t_num_execu_recs)
    
    prob_last_order_price_resets=plopr_intercept+perm_price_impact_slope_coeff*entered_order_quantity_stor_vec(t);
    
    test_for_last_order_price_choice_j=rand(1);
 
    if test_for_last_order_price_choice_j<prob_last_order_price_resets
        last_order_price=price_robot_j; 
    end
end

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
% Now robot1 gets his shot to act
%------------------------------------------------------
%------------------------------------------------------

% %Robot1 hypothetically could participate every other period. The decision
% about when robot1 participates and when he doesn't is now determined by
% the robot1 algorithm.

if (t>burn_in_period)&&(robot1_participate_indic==1)

    parent_script_only_price=last_order_price;

    robot_j_acct_id=1;%DON'T change this! It identifies that the order belongs to robot1

%------------------------------------------------------------------
% Run the separate script that controls robot1 to generate his order
%------------------------------------------------------------------
    eval(robot1_commands);
        %Outputs from 'robot1_commands' must include the following: 
        %   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
        %   price_robot_j (price of the order)
        %   quantity_robot_j (quantity of the order)
        %   FAK_indic (a 0/1 indicator of whether the order should remain in the orderbook after any immediate matches are made) 
        %   alive_indicator_robot_j
    
%-----------------------------------------------------------
% Screening robot1's order and possibly updating last_order_price
%-----------------------------------------------------------
%This section of code rejects an order from robot1 if the price is outside
%the range permitted by the matching algorithm. This part of the code also
%sets alive_indicator=0 if quantity=0.

if (price_robot_j>max_price)||(price_robot_j<min_price)
    quantity_robot_j=0;
    alive_indicator_robot_j=0;
end

if quantity_robot_j==0
    alive_indicator_robot_j=0;
end

%Now correct "last_order_price" if it somehow got changed by 
%the "robot1_commands" script (that should only ever happen by mistake):
last_order_price=parent_script_only_price;

%-----------------------------------------------------------
% Process robot1's order if it was valid (alive_indic==1)
%-----------------------------------------------------------

if (alive_indicator_robot_j==1)
    
    order_id=order_id+1;
    
    %-----------------------------------------------------------
    % Storing some stats about robot1's order
    %-----------------------------------------------------------
    entered_order_price_stor_vec(t)=price_robot_j;
    entered_order_quantity_stor_vec(t)=quantity_robot_j;

    robot1_order_entry_times(t)=alive_indicator_robot_j;
    robot1_order_prices_signed(t)=alive_indicator_robot_j*price_robot_j*buy_sell_robot_j;

    %-----------------------------------------------------------
    % Process robot1's order through the matching-engine script
    %-----------------------------------------------------------
    eval(matching_engine_algo);

    robot1_inventory_stor_vec(t)=robot1_cum_net_inventory;
    
    %--------------------------------------------------------------------
    % Determine randomly (with given prob.) whether last_order_price resets
    %--------------------------------------------------------------------
    if (number_of_execution_records>start_of_time_t_num_execu_recs)
    
        prob_last_order_price_resets=plopr_intercept+perm_price_impact_slope_coeff*entered_order_quantity_stor_vec(t);
        prob_last_order_price_resets=plopr_scaling_robot1*prob_last_order_price_resets;
        
        test_for_last_order_price_choice_j=rand(1);
 
        if test_for_last_order_price_choice_j<prob_last_order_price_resets
            last_order_price=last_order_price+buy_sell_robot_j; 
        end
    end

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


end

transaction_price_volume_stor_mat(1,:)=[];

% ----------------
bar(LOB(400:600,1),LOB(400:600,2:3))
sum(LOB(:,2:3))
max(LOB(:,2:3))

%% Implementation Shortfall Stuff
IS_script='FIN566_PS5_IS_script'; %You need to write this

eval(IS_script) 

