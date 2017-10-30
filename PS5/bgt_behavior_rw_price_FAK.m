% Background-Trader Behavior Script, compatible with FAK matching engine
%
% Prices are drawn from a uniform distribution centered about the variable
% 'last_order_price' over integers in the closed interval
% [(last_order_price-price_flex),(last_order_price+price_flex)]
%
% (The distribution at from which prices are drawn gets truncated at
% min_price and max_price, when applicable. Model parameters can be chosen
% so that these boundary conditions are never binding.)
%
% buy/sell direction is symmetric and i.i.d. 
%
% Quantity is drawn from a uniform distribution over integers in the closed
% interval [1,max_quantity]

buy_sell_robot_j=randi(2);
buy_sell_robot_j=2*(buy_sell_robot_j-1.5);

%Permitted price choices for new order
lowest_choice=max((last_order_price-price_flex),min_price);
highest_choice=min((last_order_price+price_flex),max_price);

price_robot_j=randi([lowest_choice,highest_choice]);

quantity_robot_j=randi(max_quantity);

alive_indicator_robot_j=1;

FAK_indic=0;