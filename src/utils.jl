

function equity_curve(returns::TimeArray)::TimeArray
    TimeSeries.cumprod(1 .+ returns, dims = 1)
end
