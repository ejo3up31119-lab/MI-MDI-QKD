# Loss-Tolerant Measurement-Device-Independent QKD over Untrusted Repeaters via High-Dimensional Time-Bin Multiplexing
## Reproducing Figures

To reproduce the numerical results and figures presented in the paper, simply run the corresponding MATLAB scripts listed below. Each script is self-contained and will generate the figure upon execution.

| MATLAB Script | Description | Related Figure |
| :--- | :--- | :--- |
| `KeyRateLimit_300km.m` | Simulation of Key Rate Ratio up to 300km | **Figure 3** |
| `Lo_Chau_QKD_MUX_vs_noMUX.m` | Comparison of Lo-Chau QKD with and without Multiplexing | **Figure 4** |
| `Lo_Chau_KeyRate_27MUX_vs_0MUX.m` | Analysis of Key Rate with 27-MUX vs. 0-MUX | **Figure 5** |
| `MUX_MDI_vs_MUX_Lo_Chau.m` | Performance comparison: MUX-MDI vs. MUX-Lo-Chau | **Figure 6a** |
| `MI_MUX_MDI_vs_MI_MUX_Lo_Chau.m` | MI-MUX-MDI vs. MI-MUX-Lo-Chau comparison | **Figure 6b** |

### Usage
1. Open MATLAB.
2. Add the repository folder to your MATLAB path.
3. Run the desired script directly (e.g., type `KeyRateLimit_300km` in the Command Window).
