%-------------------------------------------------%
%
%      FIN566 PS2 Matching Engine Subscript
%
%             Adam D. Clark-Joseph
%   University of Illinois at Urbana-Champaign
%
%                Version 2
%                8/18/2016
%
%
%-------------------------------------------------%
% The matching functionality in this script only processes order entries,
% not cancellations or modifications.
%
% This script differs from the matching engine for PS#1 in that it keeps
% track of robot_1's inventory


% %----------------------------------------------------------------------
% Note that the following variables should already exist in the parent
% script:
%
%       live_buy_orders_list: dim [t_max, 7]
%       live_sell_orders_list: dim [t_max, 7]
%
%  A row in these lists consists of the following data (for one order): 
%  [account_id, buy/sell, price, quantity, time, order_id, alive_indicator]
%
%       transaction_price_volume_stor_mat: dim [t_max, 7]
%
%  A row in this matrix consists of the following data (for one transaction):
%  [time (t), aggressor sign, price, executed quantity, passor order_id, passor_account_id, aggressor_account_id]
%
%       robot1_cum_net_inventory: dim [1, 1]
%
%  This is the current net inventory position (in shares) that robot1 holds
%
% %---------------------------------------------------------------------



% %----------------------------------------------------------------------
% The new order that is being sent here by the parent script is
% characterized by the following variables:
%
%   order_id  (identifying number for the order)
%   robot_j_acct_id (which trader account submitted the order)
%   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
%   price_robot_j (price of the order)
%   quantity_robot_j (quantity of the order)
%   alive_indicator_robot_j (a 0/1 indicator variable of whether the order is still "live" and hence should be included in the updated orderbook)
%
% %----------------------------------------------------------------------



% ************** Processing the New Order ********************

% Prepare to record transactions, if applicable
number_of_execution_records=find(transaction_price_volume_stor_mat(:,1),1,'last');
start_of_time_t_num_execu_recs=number_of_execution_records;

% Match the new order to execute against existing orders resting in the
% book, if possible. Resting orders have already been put in sequence of 
% price-time priority.


if buy_sell_robot_j==1 %i.e., if the robot order is a buy
    
    sell_order_lob_index=1;
    
    while (sell_order_lob_index<=length(live_sell_orders_list))&&(live_sell_orders_list(sell_order_lob_index,3)>0)&&(price_robot_j>=live_sell_orders_list(sell_order_lob_index,3))&&(quantity_robot_j>0)
        
        number_of_execution_records=number_of_execution_records+1;
            
        if live_sell_orders_list(sell_order_lob_index,1)==robot_j_acct_id %resting orders are assumed to be canceled if they would otherwise be matched against an aggressive order from the same trader who placed them 
            live_sell_orders_list(sell_order_lob_index,7)=0;
            number_of_execution_records=number_of_execution_records-1; %this is so that skipped self-crosses won't be included in the transaction records
        
        elseif quantity_robot_j>live_sell_orders_list(sell_order_lob_index,4)
            quantity_robot_j=quantity_robot_j-live_sell_orders_list(sell_order_lob_index,4);
            
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_sell_orders_list(sell_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=live_sell_orders_list(sell_order_lob_index,4);
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_sell_orders_list(sell_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_sell_orders_list(sell_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;
            
            robot1_inventory_changes(t)=(live_sell_orders_list(sell_order_lob_index,1)==1)*live_sell_orders_list(sell_order_lob_index,4)*(-1);
            
            live_sell_orders_list(sell_order_lob_index,4)=0;
            live_sell_orders_list(sell_order_lob_index,7)=0;   
            
        elseif quantity_robot_j<live_sell_orders_list(sell_order_lob_index,4)
            
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_sell_orders_list(sell_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=quantity_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_sell_orders_list(sell_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_sell_orders_list(sell_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;
            
            robot1_inventory_changes(t)=(live_sell_orders_list(sell_order_lob_index,1)==1)*quantity_robot_j*(-1);
            
            live_sell_orders_list(sell_order_lob_index,4)=live_sell_orders_list(sell_order_lob_index,4)-quantity_robot_j;
            quantity_robot_j=0;
            alive_indicator_robot_j=0;
            
        else %i.e., if quantity_robot_j==live_sell_orders_list(sell_order_lob_index,4)
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_sell_orders_list(sell_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=live_sell_orders_list(sell_order_lob_index,4);
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_sell_orders_list(sell_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_sell_orders_list(sell_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;
     
            robot1_inventory_changes(t)=(live_sell_orders_list(sell_order_lob_index,1)==1)*quantity_robot_j*(-1);
            
            quantity_robot_j=0;
            alive_indicator_robot_j=0;
            live_sell_orders_list(sell_order_lob_index,4)=0;
            live_sell_orders_list(sell_order_lob_index,7)=0;
            
        end
        
        sell_order_lob_index=sell_order_lob_index+1;   
        
    end
    
else
    
   buy_order_lob_index=1;
    
    while (buy_order_lob_index<=length(live_buy_orders_list))&&(price_robot_j<=live_buy_orders_list(buy_order_lob_index,3))&&(quantity_robot_j>0)
        
        number_of_execution_records=number_of_execution_records+1;
        
        if live_buy_orders_list(buy_order_lob_index)==robot_j_acct_id %resting orders are assumed to be canceled if they would otherwise be matched against an aggressive order from the same trader who placed them 
            live_buy_orders_list(buy_order_lob_index,7)=0;
            number_of_execution_records=number_of_execution_records-1; %this is so that skipped self-crosses won't be included in the transaction records
        
        elseif quantity_robot_j>live_buy_orders_list(buy_order_lob_index,4)
            
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_buy_orders_list(buy_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=live_buy_orders_list(buy_order_lob_index,4);
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_buy_orders_list(buy_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_buy_orders_list(buy_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;
            
            robot1_inventory_changes(t)=(live_buy_orders_list(buy_order_lob_index,1)==1)*live_buy_orders_list(buy_order_lob_index,4);
            
            quantity_robot_j=quantity_robot_j-live_buy_orders_list(buy_order_lob_index,4);
            live_buy_orders_list(buy_order_lob_index,4)=0;
            live_buy_orders_list(buy_order_lob_index,7)=0; 

        elseif quantity_robot_j<live_buy_orders_list(buy_order_lob_index,4)
            
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_buy_orders_list(buy_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=quantity_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_buy_orders_list(buy_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_buy_orders_list(buy_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;
            
            robot1_inventory_changes(t)=(live_buy_orders_list(buy_order_lob_index,1)==1)*quantity_robot_j;

            live_buy_orders_list(buy_order_lob_index,4)=live_buy_orders_list(buy_order_lob_index,4)-quantity_robot_j;
            quantity_robot_j=0;
            alive_indicator_robot_j=0;
            
        else
            transaction_price_volume_stor_mat(number_of_execution_records,1)=t;
            transaction_price_volume_stor_mat(number_of_execution_records,2)=buy_sell_robot_j;
            transaction_price_volume_stor_mat(number_of_execution_records,3)=live_buy_orders_list(buy_order_lob_index,3);
            transaction_price_volume_stor_mat(number_of_execution_records,4)=live_buy_orders_list(buy_order_lob_index,4);
            transaction_price_volume_stor_mat(number_of_execution_records,5)=live_buy_orders_list(buy_order_lob_index,6);
            transaction_price_volume_stor_mat(number_of_execution_records,6)=live_buy_orders_list(buy_order_lob_index,1);
            transaction_price_volume_stor_mat(number_of_execution_records,7)=robot_j_acct_id;

            robot1_inventory_changes(t)=(live_buy_orders_list(buy_order_lob_index,1)==1)*quantity_robot_j;
            
            quantity_robot_j=0;
            alive_indicator_robot_j=0;
            live_buy_orders_list(buy_order_lob_index,4)=0;
            live_buy_orders_list(buy_order_lob_index,7)=0;
            
        end
        
        buy_order_lob_index=buy_order_lob_index+1;   
        
    end  
    
end


robot_order_j=[robot_j_acct_id,buy_sell_robot_j,price_robot_j,quantity_robot_j,t,order_id,alive_indicator_robot_j];


% Computing changes in inventory for robot 1
    % In principle, the incoming 
if (number_of_execution_records>start_of_time_t_num_execu_recs);
   
    transaction_price_volume_stor_mat_prev_order=transaction_price_volume_stor_mat((start_of_time_t_num_execu_recs+1):number_of_execution_records,:);
    robot1_inventory_changes_aggressive=(transaction_price_volume_stor_mat_prev_order(:,7)==1).*transaction_price_volume_stor_mat_prev_order(:,2).*transaction_price_volume_stor_mat_prev_order(:,4);
    robot1_inventory_changes_passive=(transaction_price_volume_stor_mat_prev_order(:,6)==1).*transaction_price_volume_stor_mat_prev_order(:,2).*transaction_price_volume_stor_mat_prev_order(:,4)*(-1);
    robot1_cum_net_inventory=robot1_cum_net_inventory+sum(robot1_inventory_changes_aggressive)+sum(robot1_inventory_changes_passive);
end


% Enter the robot order onto the appropriate list
if (buy_sell_robot_j==1)&&(alive_indicator_robot_j==1)
    live_buy_orders_list(end,:)=robot_order_j;
elseif (buy_sell_robot_j==-1)&&(alive_indicator_robot_j==1)
    live_sell_orders_list(end,:)=robot_order_j;
end

% Delete dead orders then sort the lists of limit orders according to
% price-time priority 
not_alive_buy_orders_vec=(live_buy_orders_list(:,7)==0);
live_buy_orders_list(not_alive_buy_orders_vec,:)=0;

not_alive_sell_orders_vec=(live_sell_orders_list(:,7)==0);
live_sell_orders_list(not_alive_sell_orders_vec,:)=0;

live_buy_orders_list=sortrows(live_buy_orders_list,[-7,-3,5]); %prices in descending sequence
live_sell_orders_list=sortrows(live_sell_orders_list,[-7,3,5]); %prices in ascending sequence
