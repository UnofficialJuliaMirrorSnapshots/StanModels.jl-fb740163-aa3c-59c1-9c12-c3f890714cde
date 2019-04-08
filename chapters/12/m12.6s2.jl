using StanModels

ProjDir = rel_path_s("..", "scripts", "12")

d = CSV.read(rel_path( "..", "data",  "Kline.csv"), delim=';');
size(d) # Should be 10x5

d[:log_pop] = map((x) -> log(x), d[:population]);
d[:society] = 1:10;

first(d, 5)

m12_6_2 = "
  data {
    int N;
    int T[N];
    int N_societies;
    int society[N];
    int P[N];
  }
  parameters {
    real alpha;
    vector[N_societies] a_society;
    real bp;
    real<lower=0> sigma_society;
  }
  model {
    vector[N] mu;
    target += normal_lpdf(alpha | 0, 10);
    target += normal_lpdf(bp | 0, 1);
    target += cauchy_lpdf(sigma_society | 0, 1);
    target += normal_lpdf(a_society | 0, sigma_society);
    for(i in 1:N) mu[i] = alpha + a_society[society[i]] + bp * log(P[i]);
    target += poisson_log_lpmf(T | mu);
  }
  generated quantities {
    vector[N] log_lik;
    {
    vector[N] mu;
    for(i in 1:N) {
      mu[i] = alpha + a_society[society[i]] + bp * log(P[i]);
      log_lik[i] = poisson_log_lpmf(T[i] | mu[i]);
    }
    }
  }
";

stanmodel = Stanmodel(name="m12.6.2",  model=m12_6_2,
output_format=:mcmcchains);

m12_6_2_data = Dict("N" => size(d, 1), "T" => d[:total_tools],
"N_societies" => 10, "society" => d[:society], "P" => d[:population]);

rc, chn, cnames = stan(stanmodel, m12_6_2_data, ProjDir,
diagnostics=false, summary=false, CmdStanDir=CMDSTAN_HOME);

describe(chn)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
