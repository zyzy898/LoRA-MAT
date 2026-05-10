% Script Name: compare_metrics.m
% Function to evaluate and compare performance metrics (MSE/MAE).

function compare_metrics(labels, traditional_predictions, ai_predictions)
    % Mean Squared Error (MSE)
    mse_traditional = mean((labels - traditional_predictions).^2);
    mse_ai = mean((labels - ai_predictions).^2);

    % Mean Absolute Error (MAE)
    mae_traditional = mean(abs(labels - traditional_predictions));
    mae_ai = mean(abs(labels - ai_predictions));

    % Print Results
    fprintf('MSE (Traditional Method): %.4f\n', mse_traditional);
    fprintf('MSE (AI Method): %.4f\n', mse_ai);
    fprintf('MAE (Traditional Method): %.4f dBm\n', mae_traditional);
    fprintf('MAE (AI Method): %.4f dBm\n', mae_ai);

    % Visualization: Bar Graph for MAE
    figure;
    bar([mae_traditional, mae_ai]);
    set(gca, 'XTickLabel', {'Traditional', 'AI'});
    ylabel('Mean Absolute Error (dBm)');
    title('MAE Comparison (Traditional vs AI)');
    grid on;
end
