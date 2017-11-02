%-------------------------------------------------%
%
%           FIN566 PS#6 Part 2 
%          Main Script TEMPLATE
%
%               10/29/2017
%
%            First Version: 11/1/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.

run_main_script_independently_indic=0;

% % %*****Independence Commands*********** (Uncomment to run this script independently)
% clear
% run_main_script_independently_indic=1; 
% l=1;
% %tic


% %% %*****Startup Tasks***********

if run_main_script_independently_indic==1
   'Alert: script is running independently, using locally specified parameter values'
    
%*****Setting the appropriate path 
    %(This will need to be modified on each individual computer)
    %(I just need to uncomment the appropriate path file)
    
'Home MBP'
Matlab_trading_simulations_folder='/Users/adamclarkjoseph/Dropbox (A_D_A_M)/Projects/Teaching_Fall_2017/FIN566_MSFE_2017/FIN566_2017_Code_Library';

p=path;
path(p,Matlab_trading_simulations_folder);

cd(Matlab_trading_simulations_folder)



% %% %*****Designating the Matching-Engine Script's Name*****
matching_engine_algo='Enter_cancel_mod_matching_subscript_battlebots';


% %% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


% %% %*****Designating the Intelligent Robots' Control-Script Names*****
number_of_smart_robots=2;  

robot1_commands='robot1_algo_mm_PS6b_2017';%
robot2_commands='robot2_algo_aggressor_PS6b_2017';%

smart_robot_commands_cell=cell(number_of_smart_robots,1);

smart_robot_commands_cell{1}=robot1_commands;
smart_robot_commands_cell{2}=robot2_commands;


% %% %*****Designating the Background-Trader Control-Script Name*****
background_trader_commands='bgt_behavior_rw_price_FAK_ECM';



% %% %*******Setting Model Parameters***********

% Number of time-steps
t_max=16322;

% Burn-in period
burn_in_period=1322;

% Number of background traders
num_bgt=50;

% Combined smart_robots' activity fraction of the total activity
smart_robot_activity_fraction=.2;

% Quantity ranges
max_quantity=19;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=2;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.03;

plopr_intercept=0.025;
plopr_ordersize_param=0.05;
perm_price_impact_slope_coeff=plopr_ordersize_param*((1-plopr_intercept)/max_quantity);

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

ao_sign_stor_vec=zeros(t_max,1);

% Storing robot1's inventory and inventory changes
smart_robot_cum_net_inventory=zeros(1,number_of_smart_robots);

smart_robot_order_entry_times=zeros(t_max,1);

% Storing the underlying FV price ("last_order_price") and the actual
% price at which each order is entered
last_order_price_stor_vec=zeros(t_max,1);
entered_order_price_stor_vec=zeros(t_max,1);
entered_order_quantity_stor_vec=zeros(t_max,1);


% %% %*******Creating Blank State-Variables that Algos Can Use***********
state_variable_1=0;
state_variable_2=0;
state_variable_3=0;
state_variable_4=0;
state_variable_5=0;
state_variable_6=0;
state_variable_7=0;
state_variable_8=0;
state_variable_9=0;
state_variable_10=0;


% %% %******* Running the Simulation***********

t=1;
order_id=0;
last_order_price=floor((max_price+min_price)/2);

%tic


while t<=t_max
    
%-----------------------------------------------------------------------
% Possibly generate a random new limit order from a background trader
%-----------------------------------------------------------------------
background_trader_gets_to_act_test=rand(1);

if background_trader_gets_to_act_test>smart_robot_activity_fraction

% Randomly select a background trader other than a smart robot
robot_j_acct_id=randi(num_bgt)+number_of_smart_robots; %Note that this random account id will be strictly greater than number_of_smart_robots

message_type=1;

order_id=t;

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
    %   smart_robot_cum_net_inventory

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

ao_sign_stor_vec(t)=AO_indic_with_sign;

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
% Now a smart robot gets a potential shot to act
%------------------------------------------------------
%------------------------------------------------------

% %Each smart robot gets to participate the same amount on average, and the
% total expected fraction of activity by smart robots is controlled by the
% parameter smart_robot_activity_fraction
smart_robot_participation_draw=randi(number_of_smart_robots);

smart_robot_gets_to_act_test=rand(1);

if (t>burn_in_period)&&(smart_robot_gets_to_act_test<smart_robot_activity_fraction)

    parent_script_only_price=last_order_price;

    robot_j_acct_id=smart_robot_participation_draw;%DON'T change this!
    
    smart_robot_commands=smart_robot_commands_cell{robot_j_acct_id};

    terminal_message_indic=0; 
    
    while terminal_message_indic==0 %This ensures that smart_robot can make as 
                                    % many quantity-reducing
                                    % modifications as he wants before he
                                    % enters a new order, but he doesn't
                                    % get to do anything more after
                                    % entering the new order until the next
                                    % period in which he gets to act
        
        %------------------------------------------------------------------
        % Run the separate script that controls robot1 to generate his order
        %------------------------------------------------------------------
        eval(smart_robot_commands);
        %Outputs from 'smart_robot_commands' must include the following:
        %   message_type (whether message is a modification (2) or an entry (1))
        %   order_id  (identifying number for the order, for a modification)
        %   quantity_robot_j (new quantity for the indicated order)
        %If message_type==1, must also include:
        %   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
        %   price_robot_j (price of the order)
        %   FAK_indic (a 0/1 indicator of whether the order should remain in the orderbook after any immediate matches are made)
        %   alive_indicator_robot_j
        
        if message_type==1
            order_id=t;
        end
        
        if message_type==2
            price_robot_j=entered_order_price_stor_vec(order_id);
        end
        
        %-----------------------------------------------------------
        % Screening smart_robot's order and possibly correct last_order_price
        %-----------------------------------------------------------
        %This section of code rejects an order from smart_robot if the price is outside
        %the range permitted by the matching algorithm. This part of the code also
        %sets alive_indicator=0 if quantity=0.
        
        if (price_robot_j>max_price)||(price_robot_j<min_price)
            message_type=3; %This won't get processed by the matching engine
            alive_indicator_robot_j=0;
        end
        
        if quantity_robot_j==0
            alive_indicator_robot_j=0;
        end
        
        if alive_indicator_robot_j==0
            quantity_robot_j=0;
        end
        
        %Now correct "last_order_price" if it somehow got changed by
        %the "smart_robot_commands" script (that should only ever happen by mistake):
        last_order_price=parent_script_only_price;
        
        
        %-----------------------------------------------------------
        % Storing some stats about smart_robot's order
        %-----------------------------------------------------------
        entered_order_price_stor_vec(t)=price_robot_j;
        entered_order_quantity_stor_vec(t)=quantity_robot_j;
        
        smart_robot_order_entry_times(t)=robot_j_acct_id;
        
        %-----------------------------------------------------------
        % Process smart_robot's order through the matching-engine script
        %-----------------------------------------------------------
        eval(matching_engine_algo);
        
        ao_sign_stor_vec(t)=AO_indic_with_sign;
        %-----------------------------------------------------------
        % Constructing orderbook depth
        %-----------------------------------------------------------
        eval(orderbook_construction_code);
        
        last_order_price_stor_vec(t)=last_order_price;
        
    end
    %-----------------------------------------------------------
    %increasing the time increment
    %-----------------------------------------------------------
    t=t+1;

end

end

%toc

transaction_price_volume_stor_mat(1,:)=[];


% %% ----------------
% Number of Transactions
number_of_trades=nnz(transaction_price_volume_stor_mat(:,1));

transaction_price_volume_stor_mat((number_of_trades+1):end,:)=[];

post_burn_in_transactions_start=find((transaction_price_volume_stor_mat(:,1)>burn_in_period),1,'first');
number_of_post_burn_in_transactions=number_of_trades-post_burn_in_transactions_start;

% %%---------------
% Bid-Ask Spread
bid_ask_spread_stor_vec=bid_ask_stor_mat(:,2)-bid_ask_stor_mat(:,1);
mean_bid_ask_spread=mean(bid_ask_spread_stor_vec((burn_in_period+1):end));
bid_ask_midpoint_stor_vec=mean(bid_ask_stor_mat,2);



% %%---------------
% Tracking P&L, Cash, and Inventory
aggressor_changes_in_net_cash=(-1)*transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4).*transaction_price_volume_stor_mat(:,3);
aggressor_changes_in_net_inventory=transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4);

passor_changes_in_net_cash=(-1)*aggressor_changes_in_net_cash;
passor_changes_in_net_inventory=(-1)*aggressor_changes_in_net_inventory;

positions_changes_mat=[transaction_price_volume_stor_mat(:,1),aggressor_changes_in_net_cash,aggressor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,7),passor_changes_in_net_cash,passor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,6),transaction_price_volume_stor_mat(:,3)];

% %%

for z=1:number_of_smart_robots
    
robot_account_id=z;

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


robot_z_total_trading_profit=robot_z_mark_to_market_P_and_L(end);
robot_z_total_trading_volume=sum(abs(robot_z_positions_change_history(:,3)));

robot_z_final_inventory_position=mark_to_market_inventory_value_robot_z(end);
robot_z_final_cash_position=cum_robot_z_positions_history(end,2);

robot_z_max_inventory_position_dollars=max(abs(mark_to_market_inventory_value_robot_z));
robot_z_max_inventory_position_shares=max(abs(cum_robot_z_positions_history(:,3)));

%


% %%-----------------------------------
% % Collecting all of the key results
meta_profits_comparison_matrix(l,z)=robot_z_total_trading_profit;
meta_volume_comparison_matrix(l,z)=robot_z_total_trading_volume;

end
    
    



