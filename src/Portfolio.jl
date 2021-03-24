module Portfolio

    using Pipe: @pipe
    using TimeSeries
    import StatsBase: std, mean

    export
        # types
        Signal, Weights, Returns,
        PortfolioReturns, Brokerage,
        # dsp
        highpass, lowpass,
        # statistics
        semideviation,
        # utils
        equity_curve,
        # rebalancing
        skip_period,
        # performance-analytics
        returns_annualized, std_annualized, semid_annualized, sharpe_annualized, sortino_annualized,
        # signal-operations
        ensemble_parameters, merge_weights,
        # compute
        run_weights


    include("types.jl")
    include("dsp.jl")
    include("performance-analytics.jl")
    include("signal-operations.jl")
    include("signals.jl")
    include("statistics.jl")
    include("utils.jl")
    include("rebalancing.jl")
    include("compute.jl")

end
