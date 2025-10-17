The documents **WBDesign3.pdf** and **WBBOMDesign3.csv** were generated automatically using TI’s **WEBENCH Power Designer**: https://webench.ti.com/power-designer/

- **WBDesign3.pdf** — design report (topology, key equations/limits, efficiency and ripple estimates, Bode plot if available, recommended passives, and thermal notes).
- **WBBOMDesign3.csv** — BOM exported from WEBENCH for the selected design (MPNs, values, packages).

> Note: File names are kept as exported by WEBENCH for traceability.
>
> ### Why we use a voltage supervisor (TLV809EA30DBZR)

We monitor the 3.3 V rail (from the LMR51430 buck) with **TLV809EA30** to guarantee a clean, deterministic MCU start-up:

- **Accurate undervoltage detection** at **3.08 V**, so the MCU never runs in an undefined region. 
- **Fixed reset delay ~200 ms** (option “A”) after the rail recovers, giving the buck, decoupling, and peripherals time to settle before code executes.
- **Push-pull, active-low RESET** output (TLV809E), so no external pull-up is needed and the reset line has strong drive.
- **Glitch immunity** (ignores short supply transients) to prevent false resets on fast dip/spike events.
- **Ultra-low IQ (~250 nA)** and **wide temp range (–40…125 °C)** → negligible standby loss, robust in industrial environments.
- Defined output down to **VPOR ≈ 0.7 V**, so RESET stays valid even during deep brown-out or hot-plug events.

**System behavior:** if 3.3 V falls below the threshold, RESET asserts low immediately; when 3.3 V rises back above the threshold, RESET remains low for the fixed delay and then releases, ensuring the STM32 starts only on a stable rail.

> Variant mapping: `TLV809E A 30 DBZR` → push-pull active-low, **200 ms** delay, **3.08 V** threshold, **SOT-23-3** package.

