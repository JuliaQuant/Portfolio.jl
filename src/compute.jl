
function run_weights(returns::Returns, weights::Weights, transaction_costs::Float64= 0.005)::Returns
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
