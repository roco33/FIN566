n_sim = 20;
est_theta = zeros(n_sim,1);
h = waitbar(0);

for i = 1:n_sim
	eval('FIN566_PS3_main_script_2017');
	est_theta(i) = theta(1,entered_order_price_stor_vec);
	waitbar(i/n_sim)
	i
end

close(h)