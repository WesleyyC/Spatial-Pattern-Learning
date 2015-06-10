% poly workflow
p1 = polynomial_solution([-3,1,10])
p2 = polynomial_solution([9,-1,0,2])

p3 = p1+p2
p4 = p1-p2

% plot
x = linspace(-2,2,100);
ax = plot_it(p1,x,{'b-','linewidth',2}); set(gca,'nextplot','add');
plot_it(p2,x,{'r--','linew',2},ax);
plot_it(p3,x,{'m-.','linew',2},ax);
plot_it(p4,x,{'c:','linew',2},ax);
legend('p1','p2','p3','p4');

% integration
p5 = polynomial_solution([2,-6,0,1]);
p6 = polynomial_solution([2,0,1,1]);

p5der = p5.differentiate();
p6der = p6.differentiate();

p5int = p5.integrate(0);
p6int = p6.integrate(0);

integ = diff(p6int.evaluate([0,1])) + diff(p5int.evaluate([-1,0]))

% plot
x1 = linspace(-1,0,50); x2=linspace(0,1,50);
ax = plot_it(p5,x1,{'b-','linewidth',2}); set(gca,'nextplot','add');
plot_it(p6,x2,{'r-','linew',2},ax);
plot_it(p5int,x1,{'b--','linew',2},ax);
plot_it(p6int,x2,{'r--','linew',2},ax);
plot_it(p5der,x1,{'b:','linew',2},ax);
plot_it(p6der,x2,{'r:','linew',2},ax);
legend('p5','p6');


% Check times and power
p7 = polynomial([-1,1,1]); % x^2 + x - 1
p8 = polynomial([3,0,0,2]);% 2x^3 + 3

p7timesp8 = polynomial([-3,3,3,-2,2,2]);
p8squared = polynomial([9,0,0,12,0,0,4]);

p7*p8 == p7timesp8
p8^2  == p8squared