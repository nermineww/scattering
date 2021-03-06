%
% Copyright (c) 2014, Ross Adelman, Nail A. Gumerov, and Ramani Duraiswami
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%

%
% Generate three figures.  The first two show the field and normal derivative
% along the boundary of an oblate spheroid from a plane wave arriving from
% directly above (axial incidence) for five different choices of the oblate
% spheroid's boundary conditions.  The second shows that the boundary
% conditions have been satisfied in all five cases.
%
function generate_figure3abc()
	k = 10.0;
	a = 1.0;
	theta0 = pi;
	xi1 = 0.5;
	
	figure(1);
	hold('on');
	figure(2);
	hold('on');
	figure(3);
	hold('on');
	u = 0.0 : 0.25 : 1.0;
	color = [0.0, 0.0, 0.0; 1.0, 0.0, 0.0; 0.0, 0.7, 0.0; 0.0, 0.0, 1.0; 1.0, 0.0, 1.0];
	marker = {'none', 'x', 'square', 'diamond', '^'};
	
	for i = 1 : length(u)
		figure(1);
		plot([-1000.0, -900.0], [-1000.0, -900.0], 'color', color(i, 1 : 3), 'linewidth', 2.0, 'marker', marker{i}, 'markersize', 15.0);
		figure(2);
		plot([-1000.0, -900.0], [-1000.0, -900.0], 'color', color(i, 1 : 3), 'linewidth', 2.0, 'marker', marker{i}, 'markersize', 15.0);
		figure(3);
		plot([-1000.0, -900.0], [-1000.0, -900.0], 'color', color(i, 1 : 3), 'linewidth', 2.0, 'marker', marker{i}, 'markersize', 15.0);
	end
	
	for i = 1 : length(u)
		if (u(i) == 0.0)
			alpha = 'soft';
		elseif (u(i) == 1.0)
			alpha = 'hard';
		else
			alpha = u(i) / (1.0 - u(i));
		end
		eta = linspace(-1.0, 1.0, 1001);
		xi = xi1 * ones(1, length(eta));
		phi = zeros(1, length(eta));
		obl = [eta; xi; phi];
		cart = obl_to_cart(a, obl);
		x = cart(1, :);
		y = cart(2, :);
		z = cart(3, :);
		[ ...
		v_in, grad_in_cart ...
		] = plane_wave_in(k, sin(theta0), 0.0, cos(theta0), x, y, z);
		grad_in_obl = grad_cart_to_obl(a, [x; y; z], grad_in_cart);
		gradxi_in = grad_in_obl(2, :);
		if (ischar(alpha))
			if (strcmp(alpha, 'soft'))
				[ ...
				v_scat, grad_scat_cart, max_abs_change_scat ...
				] = obl_plane_wave_scat_soft(k, a, theta0, 'saved', xi1, x, y, z);
			else
				[ ...
				v_scat, grad_scat_cart, max_abs_change_scat ...
				] = obl_plane_wave_scat_hard(k, a, theta0, 'saved', xi1, x, y, z);
			end
		else
			[ ...
			v_scat, grad_scat_cart, max_abs_change_scat ...
			] = obl_plane_wave_scat_robin(k, a, theta0, 'saved', xi1, alpha, x, y, z);
		end
		grad_scat_obl = grad_cart_to_obl(a, [x; y; z], grad_scat_cart);
		gradxi_scat = grad_scat_obl(2, :);
		v = v_in + v_scat;
		gradxi = gradxi_in + gradxi_scat;
		
		figure(1);
		plot(eta, abs(v), 'color', color(i, 1 : 3), 'linewidth', 2.0);
		plot(eta(1 : 100 : end), abs(v(1 : 100 : end)), 'color', color(i, 1 : 3), 'linewidth', 2.0, 'linestyle', 'none', 'marker', marker{i}, 'markersize', 15.0);
		figure(2);
		plot(eta, abs(gradxi), 'color', color(i, 1 : 3), 'linewidth', 2.0);
		plot(eta(1 : 100 : end), abs(gradxi(1 : 100 : end)), 'color', color(i, 1 : 3), 'linewidth', 2.0, 'linestyle', 'none', 'marker', marker{i}, 'markersize', 15.0);
		figure(3);
		if (ischar(alpha))
			if (strcmp(alpha, 'soft'))
				plot(eta, log10(abs(v)), 'color', color(i, 1 : 3), 'linewidth', 2.0);
				plot(eta(1 : 100 : end), log10(abs(v(1 : 100 : end))), 'color', color(i, 1 : 3), 'linewidth', 2.0, 'linestyle', 'none', 'marker', marker{i}, 'markersize', 15.0);
			else
				plot(eta, log10(abs(gradxi)), 'color', color(i, 1 : 3), 'linewidth', 2.0);
				plot(eta(1 : 100 : end), log10(abs(gradxi(1 : 100 : end))), 'color', color(i, 1 : 3), 'linewidth', 2.0, 'linestyle', 'none', 'marker', marker{i}, 'markersize', 15.0);
			end
		else
			plot(eta, log10(abs(v + alpha * gradxi)), 'color', color(i, 1 : 3), 'linewidth', 2.0);
			plot(eta(1 : 100 : end), log10(abs(v(1 : 100 : end) + alpha * gradxi(1 : 100 : end))), 'color', color(i, 1 : 3), 'linewidth', 2.0, 'linestyle', 'none', 'marker', marker{i}, 'markersize', 15.0);
		end
	end
	
	figure(1);
	xlim([-1.0, 1.0]);
	ylim([-1.0, 6.0]);
	draw_border();
	set(gca, 'fontsize', 30);
	xlabel('\eta');
	ylabel('|V|');
	title('Field on Boundary');
	set(gca, 'fontsize', 20);
	legendflex_pre2014b({'\alpha = 0', '\alpha = 1 / 3', '\alpha = 1', '\alpha = 3', '\alpha \rightarrow \infty'}, 'ref', gca, 'anchor', [3, 3], 'buffer', [-30, -30]);
	set(gcf, 'position', [100, 100, 800, 600]);
	set(gcf, 'color', [1.0, 1.0, 1.0]);
	export_fig(1, 'images/figure3a.pdf');
	close();
	
	figure(2);
	xlim([-1.0, 1.0]);
	ylim([-5.0, 25.0]);
	draw_border();
	set(gca, 'fontsize', 30);
	xlabel('\eta');
	ylabel('|dV/dn|');
	title('Normal Derivative on Boundary');
	set(gca, 'fontsize', 20);
	legendflex_pre2014b({'\alpha = 0', '\alpha = 1 / 3', '\alpha = 1', '\alpha = 3', '\alpha \rightarrow \infty'}, 'ref', gca, 'anchor', [1, 1], 'buffer', [30, -30]);
	set(gcf, 'position', [100, 100, 800, 600]);
	set(gcf, 'color', [1.0, 1.0, 1.0]);
	export_fig(2, 'images/figure3b.pdf');
	close();
	
	figure(3);
	xlim([-1.0, 1.0]);
	ylim([-16.0, -8.0]);
	draw_border();
	set(gca, 'fontsize', 30);
	xlabel('\eta');
	ylabel('log_{10}(|V + \alpha{}dV/dn|)');
	title('Check on Boundary Conditions');
	set(gca, 'fontsize', 20);
	legendflex_pre2014b({'\alpha = 0', '\alpha = 1 / 3', '\alpha = 1', '\alpha = 3', '\alpha \rightarrow \infty'}, 'ref', gca, 'anchor', [3, 3], 'buffer', [-30, -30]);
	set(gcf, 'position', [100, 100, 800, 600]);
	set(gcf, 'color', [1.0, 1.0, 1.0]);
	export_fig(3, 'images/figure3c.pdf');
	close();
end
