profit_sim = [];

tic
for mm = 1:8
	MM = [0.01:0.005:0.06];
	mm_trigger_value = MM(mm);
	eval('FIN566_PS3_meta_script_2017_Sim_Ver');
	profit_sim = [profit_sim; meta_comparison_mat(5,:)];
end
toc