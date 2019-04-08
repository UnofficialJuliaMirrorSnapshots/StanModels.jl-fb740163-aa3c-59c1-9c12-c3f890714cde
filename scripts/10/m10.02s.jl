# Load Julia packages (libraries) needed  for the snippets in chapter 0

using StanModels

# CmdStan uses a tmp directory to store the output of cmdstan

ProjDir = rel_path_s("..", "scripts", "10")
cd(ProjDir)

# ### snippet 10.4

d = CSV.read(rel_path("..", "data", "chimpanzees.csv"), delim=';');
df = convert(DataFrame, d);

first(df, 5)

# Define the Stan language model

m_10_02 = "
data{
    int N;
    int pulled_left[N];
    int prosoc_left[N];
}
parameters{
    real a;
    real bp;
}
model{
    vector[N] p;
    bp ~ normal( 0 , 10 );
    a ~ normal( 0 , 10 );
    for ( i in 1:N ) {
        p[i] = a + bp * prosoc_left[i];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

stanmodel = Stanmodel(name="m_10_02", 
monitors = ["a", "bp"],
model=m_10_02, output_format=:mcmcchains);

# Input data for cmdstan

m_10_02_data = Dict("N" => size(df, 1), 
"pulled_left" => df[:pulled_left], "prosoc_left" => df[:prosoc_left]);

# Sample using cmdstan

rc, chn, cnames = stan(stanmodel, m_10_02_data, ProjDir, diagnostics=false,
  summary=false, CmdStanDir=CMDSTAN_HOME);

# Result rethinking

# Result rethinking

rethinking = "
   mean   sd  5.5% 94.5% n_eff Rhat
a  0.04 0.12 -0.16  0.21   180 1.00
bp 0.57 0.19  0.30  0.87   183 1.01
";

# Describe the draws

describe(chn)

# End of `10/m10.02s.jl`
