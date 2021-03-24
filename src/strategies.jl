



function strategy_positive_mom_binary(t::Returns, lookback::Integer)::Weights
    return @pipe moving(mean, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, value >= 0 ? 1 : 0), _) |>
        TimeSeries.lag(_, 1)
end


function strategy_prive_above_sma_binary(t::Returns, lookback::Integer)::Weights
    rets = TimeSeries.cumprod(1 .+ t, dims = 1)
    sma = moving(mean, rets, lookback)
    function islarger(lhs, rhs) lhs > rhs ? 1.0 : 0.0 end
    return TimeSeries.lag(islarger.(rets, sma), 1)
end

function strategy_vol_target_mean(t::Returns, lookback::Integer)::Weights
    target = values(std(t))[1] * sqrt(252)
    return @pipe moving(std, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
        TimeSeries.lag(_, 1)
end

function strategy_vol_target(target::Float64)
    function a(t::Returns, lookback::Integer)::Weights
        return @pipe moving(std, t, lookback) |>
            TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
            TimeSeries.lag(_, 1)
    end
end

function strategy_vol_threshold(threshold::Float64)
    function a(t::Returns, lookback::Integer)::Weights
        return @pipe TimeSeries.lag(moving(std, t, lookback), 1) |>
            TimeSeries.map((timestamp, value) -> (timestamp, value <= threshold ? 1 : 0), _)
    end
end


function strategy_semideviation_target_mean(t::Returns, lookback::Integer)::Weights
    target = values(semideviation(t)) * sqrt(252)
    return @pipe moving(semideviation, t, lookback) |>
        TimeSeries.map((timestamp, value) -> (timestamp, target / (value * sqrt(252))), _) |>
        TimeSeries.lag(_, 1)
end

function strategy_semideviation_threshold(threshold::Float64)
    function a(t::Returns, lookback::Integer)::Weights
        return @pipe TimeSeries.lag(moving(semideviation, t, lookback), 1) |>
            TimeSeries.map((timestamp, value) -> (timestamp, value <= threshold ? 1 : 0), _)
    end
end
