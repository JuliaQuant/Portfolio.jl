# Performance analytics

## Returns
function returns_annualized(rets::Returns)::Float64
    return return_annualized(values(rets))
end

function returns_annualized(rets::AbstractArray{Float64})::Float64
    n = 252 / length(rets)
    overall_return = last(cumprod(1 .+ rets))
    return round((overall_return ^ (n))-1, digits = 3)
end

## Volatility

function std_annualized(rets::TimeArray)::Float64
    return std_annualized(values(rets))
end

function std_annualized(rets::AbstractArray{Float64})::Float64
    return sqrt(252) * std(rets)
end

function semid_annualized(rets::TimeArray)::Float64
    return semid_annualized(values(rets))
end

function semid_annualized(rets::AbstractArray{Float64})::Float64
    return sqrt(252) * semideviation(rets)
end

## Frequently used quantiative measurements

function sharpe_annualized(rets::Union{Returns, AbstractArray{Float64}})::Float64
    return round(return_annualized(rets) / std_annualized(rets), digits = 3)
end


function sortino_annualized(rets::Union{Returns, AbstractArray{Float64}})::Float64
    return round(return_annualized(rets) / semid_annualized(rets), digits = 3)
end



## Drawdowns, etc.


# function drawdown(ta::TimeArray)
#     ta_cumprod = returns_cumprod(ta)
#     return upto(maximum, ta_cumprod)
# end

## Rolling metrics

function rolling_returns(t::TimeArray)::TimeArray
    return moving(return_annualized, t, 252)
end

function rolling_std(t::TimeArray)::TimeArray
    return moving(std_annualized, t, 252)
end

function rolling_sharpe(t::TimeArray)::TimeArray
    return moving(sharpe_annualized, t, 252)
end
