/* Comprehensive Zone-based FLF Problem Model */

/* Sets */
set NODES;
set LINKS within {NODES, NODES};
set TYPES;
set REQUESTS within {NODES, NODES, TYPES};
set PATHS := 1..2;

/* Parameters */
param S{TYPES};
param c{TYPES};
param delta{s in NODES, d in NODES, t in TYPES, (i,j) in LINKS, k in PATHS} default 0;

/* Variables */
var a{REQUESTS}, binary;
var p{REQUESTS, PATHS}, binary;
var y{REQUESTS, LINKS}, binary;
var f{REQUESTS, LINKS}, integer, >= 0;
var s_start{REQUESTS}, integer, >= 0;
var s_end{REQUESTS}, integer, >= 0;
var x{REQUESTS, LINKS, 1..max{t in TYPES} c[t]}, binary;

/* Objective Function */
maximize TotalAccepted: sum{(s,d,t) in REQUESTS} a[s,d,t];

/* Constraints */
s.t. FlowConservation{(s,d,t) in REQUESTS, i in NODES}:
    sum{(i,j) in LINKS} y[s,d,t,i,j] - sum{(j,i) in LINKS} y[s,d,t,j,i] = 
    if i = s then a[s,d,t]
    else if i = d then -a[s,d,t]
    else 0;

s.t. PathSelection{(s,d,t) in REQUESTS}:
    sum{k in PATHS} p[s,d,t,k] = a[s,d,t];

s.t. LinkUsage{(s,d,t) in REQUESTS, (i,j) in LINKS}:
    y[s,d,t,i,j] = sum{k in PATHS} p[s,d,t,k] * delta[s,d,t,i,j,k];

s.t. SpectrumAllocation{(s,d,t) in REQUESTS, (i,j) in LINKS}:
    f[s,d,t,i,j] = y[s,d,t,i,j] * S[t];

s.t. ZoneCapacity{(i,j) in LINKS, t in TYPES}:
    sum{(s,d,t_req) in REQUESTS: t_req = t} f[s,d,t_req,i,j] <= c[t];

s.t. SpectrumContinuity{(s,d,t) in REQUESTS}:
    s_start[s,d,t] = s_end[s,d,t] - S[t] + 1;

s.t. SpectrumContiguity{(s,d,t) in REQUESTS}:
    s_start[s,d,t] <= c[t] - S[t] + 1;

s.t. SlotUsage1{(s,d,t) in REQUESTS, (i,j) in LINKS, slot in 1..c[t]}:
    x[s,d,t,i,j,slot] >= y[s,d,t,i,j] + (slot - s_start[s,d,t]) / c[t] - 1;

s.t. SlotUsage2{(s,d,t) in REQUESTS, (i,j) in LINKS, slot in 1..c[t]}:
    x[s,d,t,i,j,slot] >= y[s,d,t,i,j] - (slot - s_end[s,d,t]) / c[t];

s.t. NonOverlappingSpectrum{(i,j) in LINKS, t in TYPES, slot in 1..c[t]}:
    sum{(s,d,t_req) in REQUESTS: t_req = t} x[s,d,t_req,i,j,slot] <= 1;

end;
