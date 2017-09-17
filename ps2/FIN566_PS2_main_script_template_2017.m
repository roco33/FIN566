%-------------------------------------------------%
%
%            FIN566 PS#2 Main Script TEMPLATE
%
%             Adam D. Clark-Joseph
%   University of Illinois at Urbana-Champaign
%
%                 9/1/2017
%
%
%-------------------------------------------------%


%% %*****Startup Tasks***********
clear

%*****Setting the appropriate path 
%(This will need to be modified on each student's code)

%'Home'    

% from desktop
%Matlab_trading_simulations_folder='C:\Users\roco3\Documents\MATLAB\FIN566\ps2';

% from laptop
Matlab_trading_simulations_folder='C:\Users\roco33\Documents\MATLAB\FIN566\PS2';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)



%% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='FIN566_PS2_entry_only_matching_subscript';


%% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


%% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_uprice_passive';

%% %*****Designating the Background-Trader Control-Script Name*****
background_trader_commands='bgt_behavior_uniform_price';


%% %*******Setting Model Parameters***********

% Number of time-steps
t_max=11322;

% Number of background traders
num_bgt=10;

% Quantity ranges
max_quantity=1;

max_potential_quantity_robot1=max_quantity;

% Price range
max_price=20;
min_price=1;

% Burn-in period
burn_in_period=1322;


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

    % As a peculiarity of how I wrote my code, it is convenient to put a
    % row of ones at the top of "transaction_price_volume_stor_mat"
    % initially, and then remove it at the very end.
transaction_price_volume_stor_mat=[ones(1,7);transaction_price_volume_stor_mat];

% Storing robot1's inventory and past inventory
robot1_cum_net_inventory=0;
robot1_inventory_stor_vec=zeros(t_max,1);

% Marking the times when robot1 places an order
robot1_order_entry_times=zeros(t_max,1);

% Recording the prices and sign (stored as price_robot_j*buy_sell_robot_j)
robot1_order_prices_signed=zeros(t_max,1);



%% %******* Running the Simulation***********

t=1;
order_id=0;

tic

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
    %   robot1_cum_net_inventory <<<===THIS IS NEW!
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

% Robot1 only gets the opportunity to act as often (on average) as each
% background trader.  This can be trivially changed in future versions.
robot1_participation_draw=randi((num_bgt+1));

%robot1 only gets to participate after the burn-in period ends, and even
%then, only when his account_ID is drawn
if (robot1_participation_draw==1)&&(t>burn_in_period) 
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
    %   alive_indicator_robot_j (a 0/1 indicator variable of whether the order is still "live" and hence should be included in the updated orderbook)



%-----------------------------------------------------------
% Screening robot1's order 
%-----------------------------------------------------------

%This section of code reject an order from robot1 if the price is outside
%the range permitted by the matching algorithm. 
    
if (price_robot_j<=max_price)&&(price_robot_j>=min_price)
    quantity_robot_j=quantity_robot_j;
else
    price_robot_j=min_price;  %arbitrary choice--just want some valid price to avoid glitches
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

%-----------------------------------------------------------
%increasing the time increment
%-----------------------------------------------------------
t=t+1;

end


end
toc

transaction_price_volume_stor_mat(1,:)=[]; %Removing the row of ones 

%% ----------------

%Now use the results to conduct the analysis requested in the problem set.







