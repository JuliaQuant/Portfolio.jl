
## Signal operations

function ensemble_signals(f::Function, t::TimeArray, ensembleRange::UnitRange; method::Function = mean)::TimeArray
    signal = @pipe ensembleRange |>
        map(x -> f(t, x), _) |>
        TimeSeries.merge(_...) |>
        TimeSeries.map((timestamp, values) -> (timestamp, repeat([method(values)], length(ensembleRange))), _)
    return signal[colnames(signal)[1]]
end

function merge_signals(signals)::TimeArray
    common = TimeSeries.merge(signals...)
    target = common[colnames(common)[1]]
    for col in colnames(common)
        if col == colnames(common)[1] continue end # skip the first col, as it's already present
        target = target .+ common[col]
    end
    return target ./ length(signals)
end


function skip_signal(t::TimeArray, interval::Integer)::TimeArray
    counter = 0
    last_value = 0.0

    function mapping(x)
        counter += 1
        if counter <= interval
            return NaN
        else
            counter = 0
            last_value = x
            return x
        end
    end
    return TimeArray(timestamp(t), map(mapping, values(t))) |> dropnan
end


## Signals to returns

function generate_signal_returns(rets::TimeArray, signal::TimeArray, transaction_costs::Float64= 0.005)::TimeArray
    last_signal = nothing
    function mapping(timestamp, value)
        if isnothing(signal[timestamp]) && isnothing(last_signal)
            return (timestamp, NaN)
        elseif isnothing(signal[timestamp])
            return (timestamp, value * last_signal)
        else
            new_signal = values(signal[timestamp])[1]
            cost = abs(new_signal - (isnothing(last_signal) ? 0.0 : last_signal)) * transaction_costs
            last_signal = values(signal[timestamp])[1]
            return (timestamp, value * new_signal - cost)
        end
    end
    return map(mapping, rets) |> dropnan
end

function equity_curve(t::TimeArray)::TimeArray
    TimeSeries.cumprod(1 .+ t, dims = 1)
end
