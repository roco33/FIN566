%-------------------------------------------------%
%
%           FIN566 PS#5 Part 2 Robot1 Algorithn
%
%               Template
%               10/17/2017
%
%            First Version: 10/17/2013
%
%-------------------------------------------------%

%-------------------------------------------------%
% LEAVE THESE FIXED!
goal_inventory_level=1000;
buy_sell_robot_j=1;%buy order 
price_robot_j=max_price;
FAK_indic=1;%1 for passive order; 0 for market order


%-------------------------------------------------%
% Write code to modify these:

alive_indicator_robot_j=1;%alive order 

%quantity 
quantity_robot_j=1000/((t_max - burn_in_period)/g);
% quantity_robot_j=min(1000/((t_max - burn_in_period)/g),depth_at_best_ask);
% quantity_robot_j=depth_at_best_ask;
% if best_ask - best_bid > 1
	% alive_indicator_robot_j=0;
% end









   