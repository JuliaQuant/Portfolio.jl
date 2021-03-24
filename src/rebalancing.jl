
function skip_period(t::Weights, interval::Integer)::Weights
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
