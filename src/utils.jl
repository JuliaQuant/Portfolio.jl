function returns_cumprod(t::TimeArray)::TimeArray
    TimeSeries.cumprod(1 .+ t, dims = 1)
end
