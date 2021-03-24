# How is this different to other "backtesters"?


**It has the ability to compose strategies, layer them on top of each other, on both the single asset and portfolio level.**

In the quantiative portfolio management world, this is extremely useful, but none of the tools I know of have an easy way to support it. I've written my crappy framework in R, that I'm so happy to abanadon now, as R was slow, and the design choices of PerformanceAnalytics didn't make it easy to create composable strategies.

The composability, the recursive nature of applying multiple strategies on top of each other means a bit of a design challenge: sometimes, you need the output of the original asset returns, sometimes, you need the returns of the previous layer of the strategy, or let's say a combination of those. This means there needs to be more information passed around that you'd expect by default, and some types may need to be a bit more "generic", to be able to support all the different usecases.


# My goals
1. Replicate a simple equal-weighted portfolio (SPY, TLT, GLD ETFs), with various rebalancing periods
2. Replicate a 10% volatility targeting portfolio (SPY, TLT, GLD ETFs)
3. Replicate a 10% volatility targeting portfolio (SPY, TLT, GLD ETFs), where each of the assets also targeting 10% volatility (applying volatility targeting on two levels).
4. Replicate a simpler Tactical Asset allocation strategy: https://allocatesmartly.com/vigilant-asset-allocation-dr-wouter-keller-jw-keuning/


# Proposed Terminology:

### Returns
TimeSeries, one or multiple columns

An asset or strategy's percentage returns


### Signal
TimeSeries, one column.

These are the type of TimeSeries that a strategy could use as its input. It could be a result of a technical indicator (let's say, momentum, RSI), applied to the TimeSeries of returns on a rolling basis.
It could also be data coming in from a completely different source, like Unemployment rate from FRED.
We should wrap Indicator.jl into a function that can apply them onto a TimeSeries, and spit out a Signal


### Weights
TimeSeries, one or multiple columns, depending on the involved number of assets.
For each period, it describes the % you want to be invested in a specific asset (for a column).

This is a result of a Strategy applied. Usually ranging from 0-1 , above 1 you'll need to factor in costs of the leverage, below 0, you'll need to factor in the costs of shorting. (see Brokerage model)
It can be for a single asset (one column), or multiple assets (multiple columns).


### Strategy

**Functions** that take the assets' Returns and optionally, Signals, and creates Weights out of them.
Ideally, the contents of the strategy can be expressed by a DSL, similar to TradingLogic.jl or Strategems.jl
It can be either for a single or multiple assets.

Price above the SMA can be a strategy, taking one SMA Signal.

function strategy_price_above_sma(returns::Returns, sma_signal::Signal)::Weights

Moving average crossover can be a strategy, taking two SMA Signals.
A mean reversion strategy could be to transform the output of RSI into a continuous signal, where the lower the RSI reading, the more you want to be long on the asset, percentage-wise.



### Brokerage
struct Brokerage
	commission::Float64
	maxSlippage::Float64
	borrowing_costs::TimeSeries
	# etc.
end

### PortfolioReturns
struct PortfolioReturns
	composition::Weights # the weights that were actually used (potentially after some normalization)
	individualReturns::Returns # (for every asset, separately, this is useful for calculating risk contribution, etc)
	returns::Returns # for the whole of the portfolio
end

### run_weights()

function run(returns::Returns, weights::Weights, brokerage::Brokerage)::PortfolioReturns

The reason why it's useful to separate out Weights creation process (responsiblity of Strategy) from generating the portfolio returns, is that it makes composing strategies a lot easier.
You can now average multiple strategy's weights, or make them conditional (multiply them), and create a composite strategy (the heart of quantiative portfolio management!).


### run_strategy()

function run(returns::Returns, strategy::Strategy, brokerage::Brokerage)::PortfolioReturns

Convenience function that you can use to also run a strategy straight on the returns, and discard the intemerdiate "Weights" type.

### portfolio_tearsheet()
You'd pass in PortfolioReturns, and potentially a benchmark, and this would generate a bunch of useful metrics.

# Process of applying one strategy

no_costs_broker = Broker(transaction_costs = 0.0, initial_cash = 100_000)
asset_returns = load(:AlphaVantage, :SPY) # done by a separate package
unemployment_signal = load(:FRED, :UNRATE) # done by a separate package

strategy_unemployment_above_sma_12 = @strategy unemployment_signal .> sma(unemployment_signal, 12) # either true or false, need to map this to 1.0 and 0.0, the @strategy macro returns a Weights type

results = run(asset_returns, strategy_unemployment_above_sma_12, no_costs_broker)

portfolio_tearsheet(results, benchmark = asset_returns)

# Composing two strategies
no_costs_broker = Broker(transaction_costs = 0.0, initial_cash = 100_000)
asset_returns = load(:AlphaVantage, :SPY) # done by a separate package
unemployment_signal = load(:FRED, :UNRATE) # done by a separate package

strategy_unemployment_above_sma_12 = @strategy unemployment_signal .> sma(unemployment_signal, 12) # either true or false, need to map this to 1.0 and 0.0,

strategy_spy_above_sma_12 =  @strategy to_price(asset_returns) .> apply_indicator(sma, to_price(asset_returns), 12) # either true or false, need to map this to 1.0 and 0.0, need to convert it to a price series, as by default, we're working with returns

composite_weights = merge_signals([strategy_unemployment_above_sma_12, strategy_spy_above_sma_12]) # average out the weights of the two strategies

results = run(asset_returns, composite_weights, no_costs_broker)

portfolio_tearsheet(results, benchmark = asset_returns)
