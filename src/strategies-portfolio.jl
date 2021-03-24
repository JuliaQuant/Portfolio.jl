

function static_weights(t::Returns, ratio::Vector{Float64})::Weights
    return TimeSeries.map((timestamp, value) -> (timestamp, ratio), t)
end

function static_equal_weights(t::Returns)::Weights
    return TimeSeries.map((timestamp, value) -> (timestamp, repeat(1 / length(colnames(t)), length(colnames(t)))), t)
end
