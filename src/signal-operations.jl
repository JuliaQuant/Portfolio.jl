
## Signal operations

function ensemble_parameters(strategy::Function, returns::Returns, ensembleRange::UnitRange; method::Function = mean)::Weights
    weights = @pipe ensembleRange |>
        map(x -> strategy(returns, x), _) |>
        TimeSeries.merge(_...) |>
        TimeSeries.map((timestamp, values) -> (timestamp, repeat([method(values)], length(ensembleRange))), _)
    return weights[colnames(weights)[1]]
end

function merge_weights(weights)::Weights
    common = TimeSeries.merge(weights...)
    target = common[colnames(common)[1]]
    for col in colnames(common)
        if col == colnames(common)[1] continue end # skip the first col, as it's already present
        target = target .+ common[col]
    end
    return target ./ length(weights)
end
