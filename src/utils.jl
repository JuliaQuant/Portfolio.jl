

function equity_curve(returns::TimeArray)::TimeArray
    TimeSeries.cumprod(1 .+ returns, dims = 1)
end

function sum_rows(ta::TimeArray)::TimeArray
    target = ta[colnames(ta)[1]]
    for col in colnames(ta)
        if col == colnames(ta)[1] continue end # skip the first col, as it's already present
        target = target .+ ta[col]
    end
    return target
end
