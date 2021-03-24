
Pkg.add(["TimeSeries", "MarketData", "Plots", "Pipe"])
using Pipe: @pipe
using TimeSeries, MarketData, Plots
# include("src/Portfolio.jl")
using Portfolio

function strategy_tearsheet(weights::Weights, returns::Returns)
    strategy_returns = run_weights(returns, weights, 0.0)
    equity_curves = plot(TimeSeries.merge(equity_curve(returns), equity_curve(strategy_returns)))
    plot(
        equity_curves,
        plot(weights),
        size = (1200, 1200),
        layout = grid(2, 1, heights = [0.8, 0.2])
    )
end


@time dell = DELL[:AdjClose] |> percentchange


# Target mean volatility, 30 day lookback
weight_vol_target_mean = @pipe strategy_vol_target_mean(dell, 30) |> lowpass(1.0).(_)
strategy_tearsheet(weight_vol_target_mean, dell)

# Ensemble lookback 20:40, still target the mean volatility
ensembled_weight_vol_target = @pipe ensemble_parameters(strategy_vol_target_mean, dell, 20:40) |> lowpass(1.0).(_)
strategy_tearsheet(ensembled_weight_vol_target, dell)

# If 200 day momentum is positive, 100% long, otherwise zero allocation
weight_momentum_above_0 = strategy_positive_mom_binary(dell, 200)
strategy_tearsheet(weight_momentum_above_0, dell)

# Ensemble 50:200 day momentum
ensembled_weight_momentum_above_0 = ensemble_parameters(strategy_positive_mom_binary, dell, 50:200)
strategy_tearsheet(ensembled_weight_momentum_above_0, dell)

# Merge the ensembled mom / vol targeting weights
all_weights_ensembled = merge_weights([ensembled_weight_vol_target, ensembled_weight_momentum_above_0])
strategy_tearsheet(all_weights_ensembled, dell)
