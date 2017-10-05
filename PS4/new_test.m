profit_sim = [];

for mm = 1:8
	MM = [0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08];
	mm_trigger_value = MM(mm);
	eval('FIN566_PS3_meta_script_2017_Sim_Ver');
	profit_sim = [profit_sim; meta_comparison_mat(5,:)];
end
