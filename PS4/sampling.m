n_sim = 1000;
est_theta = zeros(n_sim,1);
h = waitbar(0);

for i = 1:n_sim
	eval('FIN566_PS3_main_script_2017');
	all_orders = entered_order_price_stor_vec;
	all_orders(logical(robot1_order_entry_times))=[];
	est_theta(i) = theta(1,all_orders);
	waitbar(i/n_sim)
	i
end

close(h)