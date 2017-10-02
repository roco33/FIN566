for ii = 1:5
	test_value = [0.06, 0.03, 0.02, 0.01, 0.005];
	mm_trigger_value = test_value(ii);
	eval('FIN566_PS3_meta_script_2017');
	mean(meta_comparison_mat(5,:))
end