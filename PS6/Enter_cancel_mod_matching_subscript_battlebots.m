%-------------------------------------------------%
%
%   Battlebot Matching Engine Enter, Cancel, Modify 
%
%               10/29/2017
%
%            First Version: 9/1/2013
%
%-------------------------------------------------%

% This script is intended to be called by Gen 3 parent scripts.  It
% accommodates multiple smart robots
%
% Like v2b+FAK, but now allowing for modification messages
%
% The only type of modification permitted is a reduction in quantity.
% Reducing the quantity to zero is equivalent to canceling the order.
% Any other modification could be replicated by canceling the old order
% then immediately entering the new order.


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
%       smart_robot_cum_net_inventory: dim [1, number_of_smart_robots]
%
%  This is the current net inventory position (in shares) that each of the
%  smart robots holds. The variable "number_of_smart_robots" also needs to
%  exist already.
%
% %---------------------------------------------------------------------


% %----------------------------------------------------------------------
% The message being sent here by the parent script is characterized by at least the following variables:
%
%   message_type (whether message is a modification (2) or an entry (1))
%   order_id  (identifying number for the order)
%   robot_j_acct_id (which trader account submitted the message)
%   quantity_robot_j (new quantity for the indicated order)
%
% To enter a new order, the following additional variables are needed:
%
%   buy_sell_robot_j (whether the order is a buy (+1), or a sell (-1))
%   price_robot_j (price of the order)
%   alive_indicator_robot_j (a 0/1 indicator variable of whether the order is still "live" and hence should be included in the updated orderbook)
%   FAK_indic (a 0/1 indicator of whether the order should remain in the orderbook after any immediate matches are made) 
%
% %----------------------------------------------------------------------

AO_indic_with_sign=0;

terminal_message_indic=1;


if message_type==2
    
    % ************** Processing the Modification Message ********************
    
    [is_buy_order,loc_in_buy_order_list]=ismember(order_id,live_buy_orders_list(:,6));
    [is_sell_order,loc_in_sell_order_list]=ismember(order_id,live_sell_orders_list(:,6));
    
    if is_buy_order==1
        indicated_order_acct_id=live_buy_orders_list(loc_in_buy_order_list,1);
        if indicated_order_acct_id==robot_j_acct_id
            terminal_message_indic=0;
            live_buy_orders_list(loc_in_buy_order_list,4)=min(quantity_robot_j,live_buy_orders_list(loc_in_buy_order_list,4));
            live_buy_orders_list(loc_in_buy_order_list,7)=live_buy_orders_list(loc_in_buy_order_list,7)*(live_buy_orders_list(loc_in_buy_order_list,4)>0);
        end
    elseif is_sell_order==1
        indicated_order_acct_id=live_sell_orders_list(loc_in_sell_order_list,1);
        if indicated_order_acct_id==robot_j_acct_id
            terminal_message_indic=0;
            live_sell_orders_list(loc_in_sell_order_list,4)=min(quantity_robot_j,live_sell_orders_list(loc_in_sell_order_list,4));
            live_sell_orders_list(loc_in_sell_order_list,7)=live_sell_orders_list(loc_in_sell_order_list,7)*(live_sell_orders_list(loc_in_sell_order_list,4)>0);
        end
    end
% %----------------------------------------------------------------------
        
elseif message_type==1

    
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
                
                quantity_robot_j=0;
                alive_indicator_robot_j=0;
                live_buy_orders_list(buy_order_lob_index,4)=0;
                live_buy_orders_list(buy_order_lob_index,7)=0;
                
            end
            
            buy_order_lob_index=buy_order_lob_index+1;
            
        end
        
    end
    
    
    robot_order_j=[robot_j_acct_id,buy_sell_robot_j,price_robot_j,quantity_robot_j,t,order_id,alive_indicator_robot_j];
    
   
    AO_indic_with_sign=0;
        
    % Computing changes in inventory for smart_robots
    if (number_of_execution_records>start_of_time_t_num_execu_recs);
        
        AO_indic_with_sign=buy_sell_robot_j;% This is not related to Robot1...it's just keeping track of aggressive order signs
        
        transaction_price_volume_stor_mat_prev_order=transaction_price_volume_stor_mat((start_of_time_t_num_execu_recs+1):number_of_execution_records,:);
        
        for r=1:number_of_smart_robots
            smart_robot_r_inventory_changes_aggressive=(transaction_price_volume_stor_mat_prev_order(:,7)==r).*transaction_price_volume_stor_mat_prev_order(:,2).*transaction_price_volume_stor_mat_prev_order(:,4);
            smart_robot_r_inventory_changes_passive=(transaction_price_volume_stor_mat_prev_order(:,6)==r).*transaction_price_volume_stor_mat_prev_order(:,2).*transaction_price_volume_stor_mat_prev_order(:,4)*(-1);
            smart_robot_cum_net_inventory(r)=smart_robot_cum_net_inventory(r)+sum(smart_robot_r_inventory_changes_aggressive)+sum(smart_robot_r_inventory_changes_passive);
        end
    end

    % Enter the robot order onto the appropriate list
    if (buy_sell_robot_j==1)&&(alive_indicator_robot_j==1)&&(FAK_indic==0)
        live_buy_orders_list(end,:)=robot_order_j;
    elseif (buy_sell_robot_j==-1)&&(alive_indicator_robot_j==1)&&(FAK_indic==0)
        live_sell_orders_list(end,:)=robot_order_j;
    end


end



% Delete dead orders then sort the lists of limit orders according to
% price-time priority 
not_alive_buy_orders_vec=(live_buy_orders_list(:,7)==0);
live_buy_orders_list(not_alive_buy_orders_vec,:)=[];

not_alive_sell_orders_vec=(live_sell_orders_list(:,7)==0);
live_sell_orders_list(not_alive_sell_orders_vec,:)=[];

live_buy_orders_list=sortrows(live_buy_orders_list,[-3,5]); %prices in descending sequence
live_sell_orders_list=sortrows(live_sell_orders_list,[3,5]); %prices in ascending sequence

live_buy_orders_list=[live_buy_orders_list;zeros(1,7)];
live_sell_orders_list=[live_sell_orders_list;zeros(1,7)];
