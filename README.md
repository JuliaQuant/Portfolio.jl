# Portfolio


# Please see toy-example.jl to see this in action!

### Single asset

Returns = 1 column TimeArray (normal returns)
Signal = 1 column TimeArray (scale, 1 means 100% long, 0 means no allocation)

### Signal creation

For example:
generate_positive_mom_binary_signal() - For every period, returns 1 if momentum is above zero with the provided lookback.

### Ensemble signals

ensemble_signals() takes a generate_signal, returns and a range, and applies the generate_signal function to every unit within that range.

### Equity curve

strategy_tearsheet() does this for now automatically (in a very limited fashion.)
