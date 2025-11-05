---
title: "Example: Cardinality-Constrained Boolean Least-Squares"
---

In this example, the following optimization problem is solved:
$$\begin{align}
\mathrm{minimize}\quad &||\mathbf{Ax}-\mathbf{b}||_2^2\\
\text{subject to}\quad & \mathbf{x} \in \{0, 1\}^n,\\
& ||\mathbf{x}||_0=k\\
\end{align}$$

::: {#25e776ca .cell .markdown}
## Problem Setup
:::

::: {#6b355c8b .cell .code}
``` python
import numpy as np
import cvxpy as cp
from tqdm import tqdm
from time import sleep

from branch_and_bound import branch_and_bound
from itertools import combinations
from scipy.special import comb, factorial

np.random.seed(57)

n = 25  # Number of elements in x
k = 15  # Number of elements of x that are nonzero

m = 80  # Number of elements in b. Should be greater than n.

A = np.random.uniform(-10, 10, (m, n))
b = np.random.uniform(-10, 10, m)
```
:::

::: {#212e4209 .cell .markdown}
### objective(node, \...) {#objectivenode-}

The function given for `objective` should return the value of the
objective function for the candidate solution represented by `node`.
:::

::: {#0271b94d .cell .code}
``` python
def linear_least_squares_objective(node, A, b, **kwargs):
    x = node
    return np.sum((A @ x - b) ** 2)
```
:::

::: {#56bfcd9e .cell .markdown}
### branch(node, \...) {#branchnode-}

The function given for `branch` should return a list containing the
child nodes of `node`. It does not have to handle endpoint nodes, since
those should be detected by `is_endpoint`.
:::

::: {#51ed4fe8 .cell .code}
``` python
def boolean_cardinality_branch(node, n, k, **kwargs):
    # Branching function for a 0-1 integer programming problem with a
    # cardinality constraint, i.e.
    # x in {0, 1}^n
    # sum(x) = k

    L = len(node)
    assert L <= n
    # Check if all available 1 values have been used. If so, we can skip to the end.
    if np.count_nonzero(node) == k:
        children = [node + [0] * (n - len(node))]
    # Check if all available 0 values have been used
    elif k - np.count_nonzero(node) == n - len(node):
        children = [node + [1] * (n - len(node))]
    else:
        children = [node + [0], node + [1]]
    return children
```
:::

::: {#83903e4c .cell .markdown}
### bound(node, \...) {#boundnode-}

The function given for `bound` should return (`lower_bound`,
`upper_bound`), which bound the value of the objective function for the
**best** member of the set represented by `node` (not every member).
:::

::: {#55d43f15 .cell .code}
``` python
x = cp.Variable(n)

objective_expression = cp.sum_squares(A @ x - b)

constrain_lower = cp.Parameter((n))
constrain_upper = cp.Parameter((n))
relaxed_constraints = [
    cp.sum(x) == k,
    x <= constrain_upper,
    x >= constrain_lower,
]
relaxed_problem = cp.Problem(cp.Minimize(objective_expression), relaxed_constraints)

# def greedy_a

def bound(node, **kwargs):
    # Set up constraints
    constrain_lower.value = np.zeros(x.shape)
    constrain_upper.value = np.ones(x.shape)
    constrain_lower.value[: len(node)] = node
    constrain_upper.value[: len(node)] = node

    # Solve relaxed problem for lower bound
    lower_bound = relaxed_problem.solve()

    # Generate heuristic solution for upper bound by matching pursuit
    heuristic_solution = np.zeros(n, dtype=float)
    heuristic_solution[: len(node)] = node
    
    for _ in range(k-np.count_nonzero(node)):
        gradient = A.T @ (A @ heuristic_solution - b)
        gradient[heuristic_solution == 1] = np.nan
        heuristic_solution[np.nanargmin(gradient)] = 1
        
    # heuristic_solution[np.argpartition(x.value, -k)[-k:]] = 1
    upper_bound = linear_least_squares_objective(heuristic_solution, A, b)

    return lower_bound, upper_bound
```
:::

::: {#4091d496 .cell .markdown}
### is_endpoint(node, \...) {#is_endpointnode-}

The function given for `is_endpoint` should:

- Determine whether the node represents an endpoint node, *i.e.* a
  single candidate solution.
- Return `True` if so, `False` otherwise.
:::

::: {#1f50e87b .cell .code}
``` python
def is_endpoint(node, n, **kwargs):
    return len(node) == n
```
:::

::: {#1442b6ab .cell .markdown}
### count_pruned_endpoints(node, \...) {#count_pruned_endpointsnode-}

The function given for `count_pruned_endpoints` should calculate how
many members belong to the set represented by `node`. It is optional,
and is only necessary if displaying a progress bar.
:::

::: {#028ae4b2 .cell .code}
``` python
def count_pruned_endpoints(node, n, k, **kwargs):
    return comb(n-len(node), k-np.count_nonzero(node))
```
:::

::: {#04788119 .cell .markdown}
## Solving the problem
:::

::: {#7f5112b4 .cell .code}
``` python
x_optimal, best_value = branch_and_bound(
    linear_least_squares_objective,
    boolean_cardinality_branch,
    bound,
    is_endpoint,
    count_pruned_endpoints=count_pruned_endpoints,
    total = comb(n, k),
    initial_queue=[[]],
    breadth_first=True,
    A=A,
    b=b,
    n=n,
    k=k,
    show=True
)

print(f"Optimal x: {x_optimal}")
print(f"Objective value: {best_value}")
```
:::

::: {#649d26dd .cell .markdown}
## Verification by brute force
:::

::: {#65c0f293 .cell .code}
``` python
best_value_bf = np.inf
x_optimal_bf = []

for i in tqdm(combinations(range(n), k), total = comb(n, k)):
    x = np.zeros(n, dtype=np.int8)
    x[[i]] = 1
    value = linear_least_squares_objective(x, A, b)
    if value == best_value_bf:
        # Equality check allows for multiple optimal solutions
        x_optimal_bf.append(x)
                    
    elif value < best_value_bf:
        x_optimal_bf = [x.tolist()]
        best_value_bf = value

print(f"Optimal x: {x_optimal_bf}")
print(f"Objective value: {best_value_bf}")

np.allclose(x_optimal, x_optimal_bf)
```
:::
