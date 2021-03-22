## Signals

function generate_dayofweek_signal(t::TimeArray)::TimeArray
    return TimeSeries.map((timestamp, value) -> (timestamp, dayofweek(timestamp)), t)
end

function generate_positive_mom_binary_signal(t::TimeArray, lookback::Integer)::TimeArray
    return @pipe moving(mean, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, value >= 0 ? 1 : 0), _) |>
        TimeSeries.lag(_, 1)
end


function generate_above_sma_binary_signal(t::TimeArray, lookback::Integer)::TimeArray
    rets = TimeSeries.cumprod(1 .+ t, dims = 1)
    sma = moving(mean, rets, lookback)
    function islarger(lhs, rhs) lhs > rhs ? 1.0 : 0.0 end
    return TimeSeries.lag(islarger.(rets, sma), 1)
end

function generate_vol_signal_mean_target(t::TimeArray, lookback::Integer)::TimeArray
    target = values(std(t))[1] * sqrt(252)
    return @pipe moving(std, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
        TimeSeries.lag(_, 1)
end

function generate_vol_signal_target(target::Float64)
    function a(t::TimeArray, lookback::Integer)::TimeArray
        return @pipe moving(std, t, lookback) |>
            TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
            TimeSeries.lag(_, 1)
    end
end

function generate_vol_threshold_signal(threshold::Float64)
    function a(t::TimeArray, lookback::Integer)::TimeArray
        return @pipe TimeSeries.lag(moving(std, t, lookback), 1) |>
            TimeSeries.map((timestamp, value) -> (timestamp, value <= threshold ? 1 : 0), _)
    end
end


function generate_semid_signal_mean_target(t::TimeArray, lookback::Integer)::TimeArray
    target = values(semideviation(t)) * sqrt(252)
    return @pipe moving(semideviation, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
        TimeSeries.lag(_, 1)
end

function generate_semid_threshold_signal(threshold::Float64)
    function a(t::TimeArray, lookback::Integer)::TimeArray
        return @pipe TimeSeries.lag(moving(semideviation, t, lookback), 1) |>
            TimeSeries.map((timestamp, value) -> (timestamp, value <= threshold ? 1 : 0), _)
    end
end
