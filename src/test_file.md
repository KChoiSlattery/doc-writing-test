---
title: "Test Article"
author:
  - "Kieran Choi-Slattery"
date: "September 2025"
mainfont: "Magnetik"
monofont: "Berkely Mono Trial"
bibliography: "./src/references.bib"

# header-includes:
#   - \usepackage{bm}
---

\newcommand{\bv}[1]{\mathbf{#1}}
\newcommand*{\tran}{^{\mathsf{T}}}

## Some Tests

Here's an example of an equation using my custom commands:

$$\left[\bm{F}(\bv{z})\right]_{i,j}=\frac{\partial \bv{s}\tran(\bv{z})}{\partial z_i}\bm{V}\tran\bm{\Omega}^{-1}\bm{V}\frac{\partial \bv{s}(\bv{z})}{\partial z_j}$$

$$\bv{x}\in\mathbb{R}^n$$
$$\nabla\times{x}\in\mathbb{R}^n$$

Here we cite [@prager_development_2022].

## Gravity survey system design

The gravity survey works by precisely measuring the ranges between the spacecraft. While a comprehensive error analysis would use the spherical harmonic functions to find the maximum determinable harmonic degree, a loose estimation can be performed by determining the amount of relative acceleration that can be measured by the spacecraft.

### Direct-path SNR

The direct-path SNR is given by the Friis transmission equation:

$$\text{SNR}=\frac{P_t}{P_b} \left(\frac{\lambda_c G}{4\pi \rho}\right)^2\bv{A}$$

where $P_t$, $\lambda_c$, and $G$ are all specific to the gravity-survey mode of operation, and $P_b$ is given by

$$ k_b T_{\text{sys}} B. $$
with a system temperature $T_{\text{sys}}$ derived as before, with a different $T_{\text{ant}}$ according to the new signal direction.

### Positioning accuracy

To determine the positioning accuracy of the inter-satellite ranging, we use the Cramér-Rao lower bound (CRLB) derived in [prager_wireless_2020]. While this is technically a statistical lower-bound and not the actual variance of any estimator, existing estimators such as those presented in [prager_wireless_2020] have been shown to achieve enough precision that this is a reasonable approximation. The individual satellite-satellite time-of-flight (TOF) variances are given by [prager_wireless_2020, Eq. A.17] as

$$\sigma_{\text{TOF}}^2 \geq \frac{3}{2 \pi^2 B^3 \tau_p \cdot \mathrm{SNR}}.$$

From this, a cooperative one-dimensional position estimation can be performed. The CRLB of a one-dimensional relative position estimator from all inter-satellite TOF measurements is given by [patwari_relative_2003, E1. 8] as

$$\sigma_{\rho}^2\geq \frac{2\sigma_{TOF}^2 c^2}{N+1}.$$

### Acceleration accuracy

For two given satellites, the second derivative of inter-satellite range $\ddot{\rho}$ is assumed constant over a time-interval $\tau$ and found using a parabolic fit of multiple points. For a temporal spacing of measurements given by $\delta$, the variance in the second derivative of $\rho$ is given by

$$\sigma_{\ddot{\rho}}^2=\sigma_{\rho}^2\frac{180\delta}{\tau^5+5\tau^4 \delta+5\tau^3 \delta^2 - 5\tau^2 \delta^3-6\tau \delta^4},$$

using a derivation that I will write out at a later date.

And now for something completely different:

```python
def boolean_cardinality_branch(node, n, k, **kwargs):
    # Branching function for a 0-1 integer programming problem with a
    # cardinality constraint, i.e.
    # x in {0, 1}^n
    # sum(x) = k

    L = len(node)
    assert L <= n
    # Check if all available 1 values have been used. If so, we can 
    # skip to the end.
    if np.count_nonzero(node) == k:
        children = [node + [0] * (n - len(node))]
    # Check if all available 0 values have been used
    elif k - np.count_nonzero(node) == n - len(node):
        children = [node + [1] * (n - len(node))]
    else:
        children = [node + [0], node + [1]]
    return children
```