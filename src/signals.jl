

function generate_dayofweek_signal(returns::Returns)::Signal
    return TimeSeries.map((timestamp, value) -> (timestamp, dayofweek(timestamp)), returns)
end
