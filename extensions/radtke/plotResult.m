function plotResult(data,figure)

timeVector = linspace(0,0.002,500);
% plotting necessary quantities over time
figure(1);
hold on;
plot(timeVector, data.displacementAtMiddleNode1, 'g--', 'LineWidth', 1.6);
plot(timeVector, data.displacementAtMiddleNode2, 'b--', 'LineWidth', 1.6);
plot(timeVector, data.displacementAtLastNode, 'r--', 'LineWidth', 1.6);

legend(['x=',data.xMiddle1],['x=',data.xMiddle2],['x=',data.xLast]);

end