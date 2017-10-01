%-------------------------------------------------%
%
%           FIN566 PS#3 Meta Script Servant
%
%               Version 6
%               9/26/2017
%
%            First Version: 9/15/2013
%
%-------------------------------------------------%

% %% %*******Creating Data-Storage Structures***********
meta_comparison_mat=zeros(13,num_simulation_runs);


% %% %******* Running the [Meta-] Simulation***********

for w=1:num_simulation_runs
    eval(main_simulation_script)
    meta_comparison_mat(:,w)=algo_performance_stor_vec;
end

%
% algo_performance_stor_vec=[number_of_post_burn_in_transactions;
%                            mean_bid_ask_spread;
%                            robot_z_max_inventory_position_dollars;
%                            robot_z_max_inventory_position_shares;
%                            robot_z_total_trading_profit;
%                            robot_z_total_trading_volume;
%                            robot_z_final_inventory_position;
%                            robot_z_final_cash_position;
%                            mean_TtE;
%                            median_TtE;
%                            std_TtE;
%                            fraction_of_robot_1_orders_executed;
%                            fraction_of_robot1_orders_placed_mispriced;
%                            est_prob_last_order_price_resets];



meta_comparison_mat_col_stor=meta_comparison_mat';

bootstrap_CI_results_mat=zeros(length(bootstrap_column_index_choice_vec),4);

lower_cutoff=floor(confidence_level*num_bootstrap_samples/2);
upper_cutoff=num_bootstrap_samples-lower_cutoff;

for h=1:length(bootstrap_column_index_choice_vec)

    bootstrap_column_index=bootstrap_column_index_choice_vec(h);

    bootstrap_samples_stor_vec=zeros(1,num_bootstrap_samples);

    for w=1:num_bootstrap_samples
        sample_indices=randi(num_simulation_runs,[1, num_simulation_runs]);
        sample_values_vec=meta_comparison_mat_col_stor(sample_indices,bootstrap_column_index);    
        bootstrap_samples_stor_vec(w)=mean(sample_values_vec);    
    end

bootstrap_samples_stor_vec_sorted=sort(bootstrap_samples_stor_vec);

bootstrap_CI_lower=bootstrap_samples_stor_vec_sorted(lower_cutoff);
bootstrap_CI_upper=bootstrap_samples_stor_vec_sorted(upper_cutoff);

bootstrap_CI_results_mat(h,:)=[bootstrap_column_index,confidence_level,bootstrap_CI_lower,bootstrap_CI_upper];

end

