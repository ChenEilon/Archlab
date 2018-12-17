We have made some assumptions writing this code:

1. "branch" signal will be indicator of a branch that needs to be added. meaning, the signal will pulse up when counter needs to be revaluted.
2. "taken" signal will always be ready when "branch" signal goes up.
3. "prediction" will be updated one clk time after the counter is changed.