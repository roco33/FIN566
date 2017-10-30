%-------------------------------------------------%
%
%           FIN566 PS#5 Part 1 Main Script
%
%               Version 2
%               10/17/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=0;

%*****Independence Commands*********** (Uncomment to run this script independently)
clear
run_main_script_independently_indic=1; 



% %% %*****Startup Tasks***********

if run_main_script_independently_indic==1
   %'Alert: script is running independently, using locally specified parameter values'
    
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
robot1_commands='robot1_algo_aggressive_execution_simple';%'robot1_algo_aggressive_execution_simple';%robot1_algo_passive_execution_PS5_Q2_2017


% %% %*****Designating the Background-Trader Control-Script Name*****
   %(This can be modified to get different varieties of background traders)
background_trader_commands='bgt_behavior_rw_price_FAK';



%% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=1;

% Number of time-steps
t_max=6322;

% set 1 for question 2
robot1_enters_one_order_after_tmax_indic=1;

% Number of background traders
num_bgt=50;

% Quantity ranges
max_quantity=5;

max_potential_quantity_robot1=max_quantity;%can be set to something else

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=1;

% Probability that 'last_order_price' resets to robot1's orders' prices
prob_last_order_price_sets_to_price_robot_1=0;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.02;

% Burn-in period
burn_in_period=1322;

% PS5 Q2 parameters
at_best_indic=0;
one_better_indic=0;
one_worse_indic=1;
all_aggressive_indic=0;

goal_inventory_level=500;



end


% %% %*******Creating Data-Storage Structures***********

% Storing live orders
    % account_id, buy/sell, price, quantity, time, order_id, alive_indicator
live_buy_orders_list=zeros(t_max,7);
live_sell_orders_list=zeros(t_max,7);

% Storing historical liquidity statistics
    % bid statistic, ask statistic
bid_ask_stor_mat=zeros((t_max+robot1_enters_one_order_after_tmax_indic),2);
bid_ask_depth_stor_mat=zeros((t_max+robot1_enters_one_order_after_tmax_indic),2);

% Storing transaction information
    % time, aggressor sign, price, executed quantity, passor order_id,passor_account_id, aggressor_account_id
transaction_price_volume_stor_mat=zeros((t_max+robot1_enters_one_order_after_tmax_indic),7);
transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];

% Storing robot1's inventory and inventory changes
robot1_cum_net_inventory=0;
robot1_inventory_stor_vec=zeros((t_max+robot1_enters_one_order_after_tmax_indic),1);

% Marking the times when robot1 places an order
robot1_order_entry_times=zeros((t_max+robot1_enters_one_order_after_tmax_indic),1);

% Recording the prices and sign (stored as price_robot_j*buy_sell_robot_j)
robot1_order_prices_signed=zeros((t_max+robot1_enters_one_order_after_tmax_indic),1);

% Storing the underlying FV price ("last_order_price") and the actual
% price at which each order is entered
last_order_price_stor_vec=zeros((t_max+robot1_enters_one_order_after_tmax_indic),1);
entered_order_price_stor_vec=zeros((t_max+robot1_enters_one_order_after_tmax_indic),1);


%% %******* Running the Simulation***********

t=1;
order_id=0;
last_order_price=floor((max_price+min_price)/2);


while t<=t_max+1
if t <=t_max    
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
end


%------------------------------------------------------
%------------------------------------------------------
% Now robot1, gets his shot to act
%------------------------------------------------------
%------------------------------------------------------


parent_script_only_price=last_order_price;

% Robot1 only gets the opportunity to act as often (on average) as each
% background trader.  
robot1_participation_draw=randi((num_bgt+1));

% But we may specify that robot1 gets one final order after everyone else
if (t>=t_max)&&(robot1_enters_one_order_after_tmax_indic==1)
    robot1_participation_draw=1;%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--THIS IS SOMETHING NEW FOR PS#5 Q4
end


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
    %   FAK_indic (a 0/1 indicator of whether the order should remain in the orderbook after any immediate matches are made) 
    
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

if t==(t_max+1)
    bid_ask_stor_mat(end,:)=[];
    bid_ask_depth_stor_mat(end,:)=[];
end

%% Implementation Shortfall Stuff
IS_script='FIN566_PS5_IS_script'; %You need to write this

eval(IS_script) 
%%

disp 'Question 2 output'

if at_best_indic==1
    disp 'at best'
elseif one_better_indic==1
    disp 'one better'
elseif one_worse_indic==1
    disp 'one worse'
elseif all_aggressive_indic==1
    disp 'all aggressive'
end

disp('IS        bam        bam50         TWAP        VWAP')
disp(IS_bam_bam50_TWAP_VWAP')

%%

