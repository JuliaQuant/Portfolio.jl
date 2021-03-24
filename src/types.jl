
const Returns = TimeArray

const Signal = TimeArray

const Weights = TimeArray


struct Brokerage
	transaction_costs::Float64
	# maxSlippage::Float64
	# borrowing_costs::TimeSeries
end

struct PortfolioReturns
	composition::Weights # the weights that were actually used (potentially after some normalization)
	returns::Returns # for the whole of the portfolio
	individual_returns::Returns # (for every asset, separately, this is useful for calculating risk contribution, etc)
end
