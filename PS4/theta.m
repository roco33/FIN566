% estimat theta
function y = theta(price_flex,entered_order_price_stor_vec)
c = price_flex;
order_vec = entered_order_price_stor_vec(entered_order_price_stor_vec~=0);
delta_price = order_vec(2:end) - order_vec(1:end-1);
% delta_price = entered_order_price_stor_vec(2:end) - entered_order_price_stor_vec(1:end-1);
delta_price_0 = delta_price(1:end-1);
delta_price_1 = delta_price(2:end);
y = (2*c+1)*(sum(delta_price_0 .* delta_price_1 == (2 * c^2)))/(sum(abs(delta_price_0) == (2*c)));
end
