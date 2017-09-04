% sort live orders
live_buy_orders_list = sortrows(live_buy_orders_list, [-7 -3 5]);
live_sell_orders_list = sortrows(live_sell_orders_list, [-7 3 5]);

% generate new order vector
new_order = [robot_j_acct_id, sell_buy, price_robot_j, quantity_robot_j, ...
    t, order_id, alive_indicator_robot_j];

if new_order(2) == 1 % new_order is a buy order
    i = 1;
    
    % test aggresive or passive
    if live_sell_orders_list(i,7) == 0 || new_order(3) < ...
            live_sell_orders_list(i,3)
        
        %passive order
        live_buy_orders_list(t_max,:) = new_order;
        
    else 
        
        % agggresive order
        while true
            
            %new_order is larger than best sell
            if new_order(4) > live_sell_orders_list(i,4)
                
                transaction_price_volume_stor_mat = [...
                    transaction_price_volume_stor_mat; t, 1, ...
                    live_sell_orders_list(i,[3 4 6 1]), new_order(1)];
                new_order(4) = new_order(4) - live_sell_orders_list(i,4);
                live_sell_orders_list(i,4) = 0;
                live_sell_orders_list(i,7) = 0;
                
           % new_order is not larger than best sell
            else    
                % new_order is just fulfilled by the i order
                if new_order(4) == live_sell_orders_list(i,4)
                    live_sell_orders_list(i,7) = 0;
                end
                
                % new_order is fully executed
                
                transaction_price_volume_stor_mat = [...
                    transaction_price_volume_stor_mat; t, 1, ...
                    live_sell_orders_list(i,[3 4 6 1]), new_order(1)];
                live_sell_orders_list(i,4) = live_sell_orders_list(i,4) - ...
                    new_order(4);
                new_order(4) = 0;
                new_order(7) = 0;
                live_buy_orders_list(t_max,:) = new_order;
                break
            end
            i = i + 1;
            if live_sell_orders_list(i,7) == 0 || new_order(3) < ...
                    live_sell_orders_list(i,3)
                %passive order
                live_buy_orders_list(t_max,:) = new_order;
                break
            end
        end
    end
    
    
else  % sell order
    i = 1;
    
    % test aggresive or passive
    if live_buy_orders_list(i,7) == 0 || new_order(3) > ...
            live_buy_orders_list(i,3)
        %passive order
        live_sell_orders_list(t_max,:) = new_order;
        
    else
        % aggresive order
        while true
            if new_order(4) > live_buy_orders_list(i,4)
                
                transaction_price_volume_stor_mat = [...
                    transaction_price_volume_stor_mat; t, -1, ...
                    live_buy_orders_list(i,[3 4 6 1]), new_order(1)];
                new_order(4) = new_order(4) - live_buy_orders_list(i,4); 
                live_buy_orders_list(i,4) = 0;
                live_buy_orders_list(i,7) = 0;
            else
                if new_order(4) == live_buy_orders_list(i,4)
                    live_buy_orders_list(i,7) = 0; 
                end
                
                transaction_price_volume_stor_mat = [...
                    transaction_price_volume_stor_mat; t, -1, ...
                    live_buy_orders_list(i,[3 4 6 1]), new_order(1)];
                live_buy_orders_list(i,4) = live_buy_orders_list(i,4) - ...
                    new_order(4);
                new_order(4) = 0; 
                new_order(7) = 0;
                live_sell_orders_list(t_max,:) = new_order;
                break
            end
            i = i + 1;
            if live_buy_orders_list(i,7) == 0 || new_order(3) >...
                    live_buy_orders_list(i, 3)
                %passive order
                live_sell_orders_list(t_max,:) = new_order;
                break
            end
        end
    end
end

    
    