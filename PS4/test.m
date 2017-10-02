flex = 1;
last_order = 500;
prob = 0.01;
t_max = 2322;
n_simu = 400;

est_theta = zeros(n_simu,1);

for j = 1:n_simu
	bg_orders = [];
	last_orders = [];
	robot1_orders = [];
	all_orders = [];
	for i = 1:t_max
		if rem(i,2) == 1
			new_order = randi([last_order-flex,last_order+flex]);
			bg_orders = [bg_orders, new_order];
			if rand() < prob
				last_order = new_order;
				last_orders = [last_orders, last_order];
			end
		else
			new_order = randi([last_order-flex,last_order+flex]);
			robot1_orders = [robot1_orders, new_order];
		end
		all_orders = [all_orders, new_order];
	end	
	est_theta(j) = theta(flex,all_orders);
end

mean_theta = mean(est_theta)
std_theta = std(est_theta)

plot(sort(est_theta))

