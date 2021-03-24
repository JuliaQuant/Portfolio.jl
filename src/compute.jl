
function run_weights(returns::Returns, weights::TimeArray{T,1}, transaction_costs::Float64 = 0.005)::Returns  where {T}
    last_weights = nothing
    function mapping(timestamp, value)
        if isnothing(weights[timestamp]) && isnothing(last_weights)
            return (timestamp, NaN)
        elseif isnothing(weights[timestamp])
            return (timestamp, value * last_weights)
        else
            new_weights = values(weights[timestamp])[1]
            cost = abs(new_weights - (isnothing(last_weights) ? 0.0 : last_weights)) * transaction_costs
            last_weights = values(weights[timestamp])[1]
            return (timestamp, value * new_weights - cost)
        end
    end
    return map(mapping, returns) |> dropnan
end

function run_weights(returns::TimeArray, weights::TimeArray{T,2}, transaction_costs::Float64 = 0.005) where {T}
    individual_returns = map(colnames(weights)) do col_name
        return run_weights(returns[col_name], weights[col_name])
    end
    return TimeSeries.merge(individual_returns..., method = :outer) |> sum_rows
end
