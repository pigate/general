function [theta, J_history] = gradientDescent(X, y, theta, alpha, num_iters)
%GRADIENTDESCENT Performs gradient descent to learn theta
%   theta = GRADIENTDESENT(X, y, theta, alpha, num_iters) updates theta by 
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(num_iters, 1);
n = length(theta); %number of features

for iter = 1:num_iters

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCost) and gradient here.
    %
  %use temp variables to hold new values to update theta to.
  %avoids changing theta in middle of our calculations

  temps = (ones(n, 1)); %holds temp feature thetas

  for k = 1:n
    deriv = 0;
    for i = 1:m
      deriv = deriv + X(i,k)*(dot(theta',X(i,:), n) - y(i));
    endfor
    temp(k) = theta(k) - alpha * (1/m)*deriv;
  endfor

  for k= 1:n
    theta(k) = temp(k); %update theta
  endfor




    % ============================================================

    % Save the cost J in every iteration    
    J_history(iter) = computeCost(X, y, theta);

end

end
