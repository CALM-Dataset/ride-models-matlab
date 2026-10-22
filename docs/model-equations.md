# Model equations

This page states what the code computes, with the symbols of the code and of `data/models/*/params.json`. The quarter-car is in `src/+ride/+models/+quartercar`, the half-car in `src/+ride/+models/+halfcar`, the shared parts in `src/+ride/+core`. SI units throughout: m, s, kg, N, rad.

## Road input

A road is either a list of raised-cosine features or a measured profile (`ride.core.terrain`).

A feature starts at $x_0$, has height $A$ (negative for a hole) and length $L_b$:

$$
\zeta(s) = \sum_\text{features} \frac{A}{2}\left(1 - \cos\frac{2\pi (s - x_0)}{L_b}\right), \qquad 0 \le s - x_0 \le L_b .
$$

The models are driven by the height rate under the wheel, $\dot\zeta = \zeta'(s)\,v$. For a feature list the code takes the slope of the first feature that contains $s$ strictly inside it:

$$
\dot\zeta(s, v) = \frac{A}{2}\,\frac{2\pi}{L_b}\,\sin\frac{2\pi (s - x_0)}{L_b}\; v .
$$

Features in the synthetic catalog do not overlap, so this equals the derivative of the sum above. Overlap is not checked for feature lists from files or code; where features overlap, the height is the sum but the rate is that of the first listed feature.

A measured profile holds heights $z_j$ every $\Delta s$ (5 cm in the dataset). Height and slope are interpolated linearly between samples; the slope samples are `gradient(z, ds)`, central differences inside and one-sided differences at the ends. Outside the profile the road is flat: $\zeta = 0$, $\dot\zeta = 0$.

## Suspension elements

Both models use the same spring and damper laws for every axle, with per-axle parameters (`ride.core.suspension`).

**Spring.** The suspension force is linear with a progressive part beyond two knees,

$$
F_\text{spring}(\Delta) = k_S\,\Delta + F_\text{nl}(\Delta),
$$

with the suspension deflection $\Delta$ (positive in compression) and

$$
F_\text{nl}(\Delta) =
\begin{cases}
k_S\left[\Delta_\text{stat}\, f_{1,\text{cmp}}\left(e^{f_{2,\text{cmp}} (\Delta - \Delta_\text{cmp})/\Delta_\text{stat}} - 1\right) - (\Delta - \Delta_\text{cmp})\right] & \Delta > \Delta_\text{cmp} \\
0 & -\Delta_\text{rbd} \le \Delta \le \Delta_\text{cmp} \\
-k_S\left[\Delta_\text{stat}\, f_{1,\text{rbd}}\left(e^{f_{2,\text{rbd}} (-\Delta - \Delta_\text{rbd})/\Delta_\text{stat}} - 1\right) - (-\Delta - \Delta_\text{rbd})\right] & \Delta < -\Delta_\text{rbd}
\end{cases}
$$

clipped to $\pm F_\text{max}$. In `params.json`: `k_S`, `dz_S_stat` ($\Delta_\text{stat}$), `dz_cmp`, `dz_rbd`, `f1_cmp`, `f2_cmp`, `f1_rbd`, `f2_rbd`, `F_max`.

**Damper.** The damper force depends on the suspension velocity $v_S$ (positive in compression). Compression and rebound have different slopes, and both get steeper beyond a knee velocity. The switches are smoothed with the logistic function $\sigma(x) = 1/(1 + e^{-50x})$, with $x$ in m/s:

$$
F_D(v_S) = \left[\sigma(v_S)\, d_1 + (1 - \sigma(v_S))\, z_1\right] v_S
+ \sigma(v_S - v_d)\,(d_2 - d_1)(v_S - v_d)
- \sigma(-v_S - v_z)\,(z_2 - z_1)(-v_S - v_z) .
$$

The four coefficients follow from the damper coefficient $D$ and the asymmetry $A$ (`damper_coefficients.m`):

$$
z_1 = \frac{2D}{1 + A}, \quad d_1 = A\, z_1, \quad d_2 = \frac{d_1}{0.25}, \quad z_2 = \frac{z_1}{0.40} .
$$

With $A = 0.5$ the rebound slope $z_1$ is twice the compression slope $d_1$. In `params.json`: `D`, `A`, `v_d`, `v_z`.

**Tyre.** A linear spring and damper with no lift-off: $F_T = k_T x_T + c_T(\dot\zeta - \dot z_W)$, with the tyre deflection $x_T$ (positive in compression).

All deflections are measured from the static equilibrium, so gravity does not appear. All states start at zero except the speed state, which starts at $v_1$.

## Quarter-car

Six states (`+quartercar/+dynamics/ode_rhs.m`):

| | State | Symbol |
| --- | --- | --- |
| $x_1$ | tyre deflection | $x_T = \zeta - z_W$ |
| $x_2$ | wheel velocity | $\dot z_W$ |
| $x_3$ | suspension deflection | $\Delta = z_W - z_B$ |
| $x_4$ | body velocity | $\dot z_B$ |
| $x_5$ | vehicle speed | $v$, set from the speed profile |
| $x_6$ | body position | $z_B$ |

$$
\begin{aligned}
F_S &= k_S x_3 + F_\text{nl}(x_3) + F_D(x_2 - x_4), \qquad F_T = k_T x_1 + c_T(\dot\zeta - x_2), \\
\dot x_1 &= \dot\zeta - x_2, \qquad m_W \dot x_2 = F_T - F_S, \qquad \dot x_3 = x_2 - x_4, \\
m_B \dot x_4 &= F_S, \qquad \dot x_5 = 0, \qquad \dot x_6 = x_4 .
\end{aligned}
$$

Outputs: $\ddot z_B = \dot x_4$, $\ddot z_W = \dot x_2$, the suspension deflection $x_3$, $z_B = x_6$, $z_W = x_6 + x_3$. Parameters: the body mass `m_B` and one axle.

## Half-car

Eleven states (`+halfcar/+dynamics/ode_rhs.m`). The pitch angle $\varphi$ is positive nose down. The body points above the axles move with $z_B - l_f \varphi$ (front) and $z_B + l_r \varphi$ (rear).

| | State | | State |
| --- | --- | --- | --- |
| $x_1$ | rear tyre deflection | $x_7$ | front suspension deflection |
| $x_2$ | rear wheel velocity $\dot z_{W,r}$ | $x_8$ | pitch rate $\dot\varphi$ |
| $x_3$ | front tyre deflection | $x_9$ | vehicle speed $v$ |
| $x_4$ | front wheel velocity $\dot z_{W,f}$ | $x_{10}$ | body position $z_B$ |
| $x_5$ | rear suspension deflection | $x_{11}$ | pitch angle $\varphi$ |
| $x_6$ | body velocity $\dot z_B$ | | |

With the corner velocities $\dot z_{B,f} = x_6 - l_f x_8$ and $\dot z_{B,r} = x_6 + l_r x_8$, each axle $i \in \{f, r\}$ has

$$
F_{S,i} = k_{S,i}\,\Delta_i + F_{\text{nl},i}(\Delta_i) + F_{D,i}(\dot z_{W,i} - \dot z_{B,i}), \qquad
F_{T,i} = k_{T,i}\, x_{T,i} + c_{T,i}(\dot\zeta_i - \dot z_{W,i}),
$$

with $\Delta_f = x_7$, $\Delta_r = x_5$, $x_{T,f} = x_3$, $x_{T,r} = x_1$. Then

$$
\begin{aligned}
\dot x_1 &= \dot\zeta_r - x_2, & m_{W,r}\,\dot x_2 &= F_{T,r} - F_{S,r}, \\
\dot x_3 &= \dot\zeta_f - x_4, & m_{W,f}\,\dot x_4 &= F_{T,f} - F_{S,f}, \\
\dot x_5 &= x_2 - x_6 - l_r x_8, & \dot x_7 &= x_4 - x_6 + l_f x_8, \\
m_B\,\dot x_6 &= F_{S,f} + F_{S,r}, & I_B\,\dot x_8 &= l_r F_{S,r} - l_f F_{S,f} - h(a)\, m_\text{tot}\, a, \\
\dot x_9 &= 0, \quad \dot x_{10} = x_6, & \dot x_{11} &= x_8 .
\end{aligned}
$$

**Pitch coupling and load transfer.** The longitudinal acceleration $a$ of the current step pitches the body through the inertia of the whole car, $m_\text{tot} = m_B + m_{W,f} + m_{W,r}$, acting at a height $h(a) = h_T$ when the car speeds up ($a > 0$) and $h(a) = h_B$ otherwise. Speeding up pitches the nose up, braking pitches it down.

**Road input.** The rear wheel follows the front wheel at the wheelbase $L = l_f + l_r$: $\dot\zeta_f = \dot\zeta(s, v)$ and $\dot\zeta_r = \dot\zeta(s - L, v)$, where $s$ is the distance of the front axle.

Outputs: $\ddot z_B = \dot x_6$, $\ddot\varphi = \dot x_8$, $\ddot z_{W,f} = \dot x_4$, $\ddot z_{W,r} = \dot x_2$, the suspension deflections, $z_B$, $\varphi$, and the wheel positions $z_{W,f} = z_B - l_f\varphi + x_7$ and $z_{W,r} = z_B + l_r\varphi + x_5$.

## Integration

The speed profile gives one speed $v_k$ per output step $\Delta t = 0.02$ s (`dt_s`). Step $k$ runs at the constant speed $v_k$, starting at the distance $s_{k-1}$, with $s_k = s_{k-1} + v_k \Delta t$ and $s_0 = 0$. The half-car takes $a_k = (v_k - v_{k-1})/\Delta t$, with $v_0 = v_1$.

Inside a step the state is advanced by $N = 20$ (`substeps`) classical Runge-Kutta steps of $h = 1$ ms (`dt_sim_s`). Sub-step $i$ evaluates the road rate at the distances $s_{k-1} + (i-1)hv_k$, $s_{k-1} + (i-\tfrac12)hv_k$ and $s_{k-1} + ihv_k$, the middle one for both midpoint stages. After the last sub-step the right-hand side is evaluated once more at the new state, with the road rate at $s_{k-1} + N h v_k$, which is $s_k$ because $N h = \Delta t$ for the shipped parameters (the code assumes this and does not check it), and gives the reported accelerations. Every output is the value at the end of its step.

## Comfort measures

`ride.core.comfort` and `ride.metrics.builtin`.

**Wk weighting.** The ISO 2631-1 Wk weighting for vertical whole-body vibration, as the product of four second-order sections: high-pass at $f_1 = 0.4$ Hz and low-pass at $f_2 = 100$ Hz (both Butterworth, $Q = 1/\sqrt2$), the acceleration-velocity transition with $f_3 = f_4 = 12.5$ Hz, $Q_4 = 0.63$, and the upward step with $f_5 = 2.37$ Hz, $Q_5 = 0.91$, $f_6 = 3.35$ Hz, $Q_6 = 0.91$. The code regroups the numerators and denominators of these factors into four biquads (`wk_sections` in `wk_weight.m`); their product is the filter above, with the upward step written as

$$
H_s(s) = K\,\frac{s^2/\omega_5^2 + s/(Q_5\omega_5) + 1}{s^2/\omega_6^2 + s/(Q_6\omega_6) + 1}, \qquad K = 0.5 .
$$

The magnitude of this analog design is within 0.01 dB of the tabulated Wk values of ISO 2631-1 at 1, 4, 6.3 and 8 Hz; the test suite checks the digital implementation within 0.1 dB.

The signal, sampled at $\Delta t$, is upsampled by 10 (`resample` from the Signal Processing Toolbox when installed, `pchip` interpolation otherwise), filtered by four biquads after the bilinear transform at the upsampled rate, each started at steady state for the first sample, and taken back to the original samples.

**Weighted RMS and VDV.** With the weighted body acceleration $a_w(t)$ up to the end of the trip $T$:

$$
a_w = \sqrt{\frac{1}{T}\int_0^T a_w^2(t)\,dt}, \qquad \text{VDV} = \left(\int_0^T a_w^4(t)\,dt\right)^{1/4},
$$

computed as the mean over samples and the sum over samples times $\Delta t$.

**End of the trip.** All built-in metrics stop at the first step $k$ with $s_k$ at or beyond the end of the road plus the wheelbase (`ride.metrics.trip_end`; the wheelbase is 0 for the quarter-car). The end of the road is the end of the last feature for a feature list and the end of the profile plus 3 m for a measured profile. If the drive never gets there, all steps are used. `travel_time` is the time of that step and `mean_speed` the distance over that time.

## Parameters and their provenance

The numbers in `params.json` come from the thesis this package was written for (see `CITATION.cff`), which takes them from the following sources:

- Quarter-car masses $m_B$, $m_W$, spring stiffness $k_S$, tyre stiffness $k_T$ and tyre damping $c_T$: the equivalent quarter-car parameterisation of F. Klinger, *Kombinierte Betrachtung passiver und (semi-)aktiver Radaufhängungen mittels äquivalenter Fahrwerksparameter*, PhD thesis, Technische Universität Wien, 2018.
- Progressive spring (bump stop) parameters $\Delta_\text{cmp}$, $\Delta_\text{rbd}$, $f_{1/2,\text{cmp/rbd}}$ and $F_\text{max}$: M. Mitschke and H. Wallentowitz, *Dynamik der Kraftfahrzeuge*, 5th ed., Springer Vieweg, 2014, doi:10.1007/978-3-658-05068-9.
- Damper characteristic and its parameters $D$, $A$, the degression factors 0.25 and 0.40, $v_d$, $v_z$: F. Klinger, J. Edelmann, M. Plöchl, S. Jeindl and B. Angrosch, "Virtual Chassis Tuning with Emphasis on the Damper Characteristics", *6th International Munich Chassis Symposium 2015*, Springer Fachmedien, pp. 325 to 346, doi:10.1007/978-3-658-09711-0_22.

The half-car body parameters ($m_B$, $I_B$, $l_f$, $l_r$, $h_T$, $h_B$) and its suspension calibration come from the CALM project; they have no published source yet.

| | Quarter-car | Half-car front | Half-car rear |
| --- | --- | --- | --- |
| Body mass $m_B$ [kg] | 465.7 | 803.0 (whole body) | |
| Pitch inertia $I_B$ [kg m^2] | | 1430.0 | |
| $l_f$, $l_r$ [m] | | 1.206 | 1.664 |
| $h_T$, $h_B$ [m] | | 0.6, 0.222 | |
| Wheel mass $m_W$ [kg] | 50.4 | 50.4 | 50.4 |
| Tyre $k_T$ [N/m], $c_T$ [N s/m] | 262200, 500 | 262200, 500 | 262200, 500 |
| Spring $k_S$ [N/m] | 27922 | 29589.9 | 21444.86 |
| Damper $D$ [N s/m] | 3530 | 564.8 | 562.4 |

The spring and damper shape parameters are the same everywhere: $\Delta_\text{cmp} = 0.02$ m, $\Delta_\text{rbd} = 0.08$ m, $f_{1,\text{cmp}} = 1/3$, $f_{2,\text{cmp}} = 4$, $f_{1,\text{rbd}} = 1$, $f_{2,\text{rbd}} = 8$, $F_\text{max} = 10^5$ N, $A = 0.5$, $v_d = v_z = 0.2$ m/s. $\Delta_\text{stat}$ equals the static deflection $m g / k_S$ ($g = 9.81$ m/s^2) under the body mass the axle carries: $m_B$ for the quarter-car, and the share $m_B l_r / L$ (front) or $m_B l_f / L$ (rear) with the nominal stiffness for the half-car.

The half-car uses a calibrated suspension. The nominal values are kept under `nominal` in its `params.json`; the calibrated springs are 1.06 times and the calibrated dampers 0.16 times the nominal values.
