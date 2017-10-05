a = importdata('a.dat');
b = importdata('b.dat');
x_stor = [0.01:0.01:0.05];

profit_mat = [];

for x_i = 1:length(x_stor)
	
	x = x_stor(x_i);
	p = sum(a < x)/2000;
	P1 = sum(a < x)/(sum(a<x)+sum(b<x));
	P2 = sum(a > x)/(sum(a>x)+sum(b>x));
	
	mm_trigger_value = x;
	profit_mat = [];
	
	prob_last_order_price_resets = 0.01;
	mm_trigger_value = x;
	eval('FIN566_PS3_meta_script_2017_Sim_Ver');
	profit_mat = [profit_mat; meta_comparison_mat(5:,)];
	
	prob_last_order_price_resets = 0.06;
	eval('FIN566_PS3_meta_script_2017_Sim_Ver');
	profit_mat = [profit_mat; meta_comparison_mat(5:,)];
	
end