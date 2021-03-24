

function strategy_static_weights(returns::Returns, ratio::Vector{Float64})::Weights
    return TimeSeries.map((timestamp, value) -> (timestamp, ratio), returns)
end

function strategy_static_equal_weights(returns::Returns)::Weights
    return TimeSeries.map((timestamp, value) -> (timestamp, repeat([1 / length(colnames(returns))], length(colnames(returns)))), returns)
end
