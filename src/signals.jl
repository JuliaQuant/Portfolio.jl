

function signal_dayofweek(returns::Returns)::Signal
    return TimeSeries.map((timestamp, value) -> (timestamp, dayofweek(timestamp)), returns)
end

function signal_dayofmonth(returns::Returns)::Signal
    return TimeSeries.map((timestamp, value) -> (timestamp, dayofmonth(timestamp)), returns)
end
