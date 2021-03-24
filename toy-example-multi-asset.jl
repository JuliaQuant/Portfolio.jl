
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
yahoo(:TLT)

@time dell = DELL[:AdjClose] |> percentchange
@time aapl = AAPL[:AdjClose] |> percentchange

assets = merge(dell, aapl)

Portfolio.strategy_static_equal_weights(assets)
strategy_tearsheet(Portfolio.strategy_static_equal_weights(assets), assets)
strategy_tearsheet(Portfolio.strategy_static_equal_weights(assets) |> Portfolio.rebalance_once, assets)

run_weights(assets, Portfolio.strategy_static_equal_weights(assets) |> Portfolio.rebalance_once) |> sharpe_annualized

Portfolio.strategy_static_equal_weights(assets) |> Portfolio.rebalance_once
