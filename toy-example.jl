include("src/Portfolio.jl")

Pkg.add(["TimeSeries", "MarketData", "Plots", "Pipe"])
using Pipe: @pipe
using TimeSeries, MarketData, Plots

function strategy_tearsheet(signal::TimeArray, returns::TimeArray)
    signal_returns = generate_signal_returns(returns, signal, 0.0)
    equity_curves = plot(TimeSeries.merge(returns_cumprod(returns), returns_cumprod(signal_returns)))
    plot(
        equity_curves,
        plot(signal),
        size = (1200, 1200),
        layout = grid(2, 1, heights = [0.8, 0.2])
    )
end


dell = DELL[:AdjClose] |> percentchange

# Target mean volatility, 30 day lookback
signal_vol_target_mean = @pipe generate_vol_signal_mean_target(dell, 30) |> lowpass(1.0).(_)
strategy_tearsheet(signal_vol_target_mean, dell)

# Ensemble lookback 20:40, still target the mean volatility
ensembled_signal_vol_target = @pipe ensemble_signals(generate_vol_signal_mean_target, dell, 20:40) |> lowpass(1.0).(_)
strategy_tearsheet(ensembled_signal_vol_target, dell)

# If 200 day momentum is positive, 100% long, otherwise zero allocation
signal_momentum_above_0 = generate_positive_mom_binary_signal(dell, 200)
strategy_tearsheet(signal_momentum_above_0, dell)

# Ensemble 50:250 day momentum
ensembled_signal_momentum_above_0 = ensemble_signals(generate_positive_mom_binary_signal, dell, 100:250)
strategy_tearsheet(ensembled_signal_momentum_above_0, dell)
