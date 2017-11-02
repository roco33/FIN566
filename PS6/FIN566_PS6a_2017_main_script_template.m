%-------------------------------------------------%
%
%           FIN566 PS#6 Part 1 
%          Main Script TEMPLATE
%
%               Version 4
%               10/29/2017
%
%            First Version: 11/1/2013
%
%-------------------------------------------------%

% %If you are going to run this script independently, rather than calling
% it from a meta-script, uncomment the two "Independence Commands" below,
% as indicated.


% % %*****Independence Commands*********** (Uncomment to run this script independently)
% clear
% run_main_script_independently_indic=1; 
% 

% %*****Startup Tasks***********

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
matching_engine_algo='Enter_cancel_mod_matching_subscript';


% %% %*****Designating the Orderbook-Construction Script's Name*****
orderbook_construction_code='orderbook_depth_construction_subscript';


% %% %*****Designating the robot1 Control-Script Name*****
    %(This will need to be modified for each different control-script)
robot1_commands='robot1_algo_mm_at_best_Q1_PS6_2017';%

% %% %*****Designating the Background-Trader Control-Script Name*****
   %(This can be modified to get different varieties of background traders)
background_trader_commands='bgt_behavior_rw_price_FAK_ECM';



% %% %*******Setting Model Parameters***********

% Whether robot1 participates (1) or not (0)
robot1_participate_indic=1;

% Number of time-steps
t_max=6322;

% Burn-in period
burn_in_period=1322;

% Number of background traders
num_bgt=11;

% Quantity ranges
max_quantity=9;

% Price range
max_price=1000;
min_price=1;

% Price-choice flexibility relative to last order price
price_flex=1;

% Probability that 'last_order_price' resets to the newest order price
prob_last_order_price_resets=0.0322;

plopr_intercept=0.0;
plopr_ordersize_param=0.4;
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

tic

while t<=t_max
    
%-----------------------------------------------------------
% Generate a random new limit order
%-----------------------------------------------------------
order_id=t;

% Randomly select a background trader other than robot1
robot_j_acct_id=randi(num_bgt)+1; %Note that this random account id will be strictly greater than 1

message_type=1;

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


%------------------------------------------------------
%------------------------------------------------------
% Now robot1 potentially gets his shot to act
%------------------------------------------------------
%------------------------------------------------------

robot1_participation_draw=rem(t,num_bgt);

if (robot1_participation_draw==1)&&(t>burn_in_period)&&(robot1_participate_indic==1)
    
    parent_script_only_price=last_order_price;
    
    robot_j_acct_id=1;%DON'T change this! It identifies that the order belongs to robot1
    
    terminal_message_indic=0; 
    
    while terminal_message_indic==0 %This ensures that robot1 can make as 
                                    % many quantity-reducing
                                    % modifications as he wants before he
                                    % enters a new order, but he doesn't
                                    % get to do anything more after
                                    % entering the new order until the next
                                    % period in which he gets to act
        
        %------------------------------------------------------------------
        % Run the separate script that controls robot1 to generate his order
        %------------------------------------------------------------------
        eval(robot1_commands);
        %Outputs from 'robot1_commands' must include the following:
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
        % Screening robot1's order and possibly correct last_order_price
        %-----------------------------------------------------------
        %This section of code rejects an order from robot1 if the price is outside
        %the range permitted by the matching algorithm. This part of the code also
        %sets alive_indicator=0 if quantity=0.
        
        if (price_robot_j>max_price)||(price_robot_j<min_price)
            message_type=3; %This won't get processed by the matching engine
            alive_indicator_robot_j=0;
        end
        
        if quantity_robot_j==0
            alive_indicator_robot_j=0;
        end
        
        %Now correct "last_order_price" if it somehow got changed by
        %the "robot1_commands" script (that should only ever happen by mistake):
        last_order_price=parent_script_only_price;
        
        %-----------------------------------------------------------
        % Process robot1's order if it was valid
        %-----------------------------------------------------------
        
        %-----------------------------------------------------------
        % Storing some stats about robot1's order
        %-----------------------------------------------------------
        entered_order_price_stor_vec(t)=price_robot_j;
        entered_order_quantity_stor_vec(t)=quantity_robot_j;
        
        robot1_order_entry_times(t)=message_type;
        robot1_order_prices_signed(t)=price_robot_j*buy_sell_robot_j*(message_type==1);
        
        %-----------------------------------------------------------
        % Process robot1's order through the matching-engine script
        %-----------------------------------------------------------
        eval(matching_engine_algo);
        
        robot1_inventory_stor_vec(t)=robot1_cum_net_inventory;
        
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

toc

transaction_price_volume_stor_mat(1,:)=[];

%plot(bid_ask_stor_mat(burn_in_period:end,:))

% %%----------------
% Number of Transactions
number_of_trades=nnz(transaction_price_volume_stor_mat(:,1));

transaction_price_volume_stor_mat((number_of_trades+1):end,:)=[];

post_burn_in_transactions_start=find((transaction_price_volume_stor_mat(:,1)>burn_in_period),1,'first');
number_of_post_burn_in_transactions=number_of_trades-post_burn_in_transactions_start;

% %%---------------
% Bid-Ask Spread
bid_ask_spread_stor_vec=bid_ask_stor_mat(:,2)-bid_ask_stor_mat(:,1);
mean_bid_ask_spread=mean(bid_ask_spread_stor_vec((burn_in_period+1):end));


% %%---------------
% Tracking P&L, Cash, and Inventory
aggressor_changes_in_net_cash=(-1)*transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4).*transaction_price_volume_stor_mat(:,3);
aggressor_changes_in_net_inventory=transaction_price_volume_stor_mat(:,2).*transaction_price_volume_stor_mat(:,4);

passor_changes_in_net_cash=(-1)*aggressor_changes_in_net_cash;
passor_changes_in_net_inventory=(-1)*aggressor_changes_in_net_inventory;

positions_changes_mat=[transaction_price_volume_stor_mat(:,1),aggressor_changes_in_net_cash,aggressor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,7),passor_changes_in_net_cash,passor_changes_in_net_inventory,transaction_price_volume_stor_mat(:,6),transaction_price_volume_stor_mat(:,3)];

% %%
robot_account_id=2-robot1_participate_indic;
z=robot_account_id;

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

num_robot_z_orders_left_in_book=sum((live_buy_orders_list(:,1)==1))+sum((live_sell_orders_list(:,1)==1));
%num_robot_z_orders_placed=robot_z_total_trading_volume+num_robot_z_orders_left_in_book; %for Q1 and Q2 only!
num_robot_z_orders_placed=sum(robot1_order_entry_times(entered_order_quantity_stor_vec>0)); %works generally

% %%-----------------------------------
% % Collecting all of the key results
    %mean_bid_ask_spread
    %robot_z_max_inventory_position_dollars
    %robot_z_max_inventory_position_shares
    robot_z_total_trading_profit
    robot_z_total_trading_volume
    num_robot_z_orders_left_in_book
    num_robot_z_orders_placed

%
plot(cum_robot_z_positions_history(:,3))
    


