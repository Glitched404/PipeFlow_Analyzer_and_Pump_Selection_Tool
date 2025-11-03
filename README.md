# PIPE FLOW ANALYZER - Interactive MATLAB Tool

## 📋 Overview

**Pipe Flow Analyzer** is a professional-grade MATLAB tool for analyzing single-pipe flow systems. It calculates friction factors using the Moody chart method, determines major and minor losses, selects appropriate pumps, and visualizes energy profiles (EGL/HGL).

### Key Features

✅ **Interactive Menu-Driven Interface** - 4-step user input workflow  
✅ **Comprehensive Calculations** - Friction factors, losses, pump selection  
✅ **Professional Outputs** - Text reports + 4 visualization plots  
✅ **Validated** - 3 test cases against published data  
✅ **Save/Load** - Timestamped analysis parameters  
✅ **No External Dependencies** - Base MATLAB only (CoolProp optional)  

---

## 🚀 Quick Start

### Installation

1. **Download/Clone** all files to a folder
2. **Navigate** to the folder in MATLAB:
   ```matlab
   cd C:\Users\skaft\Fluid_Project
   ```
3. **Refresh paths** (if functions are not found):
   ```matlab
   addpath(genpath('src'));
   addpath('data');
   rehash path;
   ```
4. **Run** the main analyzer:
   ```matlab
   main_analyzer
   ```
   
**Note:** The main analyzer automatically configures paths, so step 3 is only needed if you encounter "function not found" errors.

### First Analysis

Follow the interactive prompts:

```
STEP 1: PIPE SPECIFICATIONS
  → Diameter: 100 mm
  → Length: 50 m
  → Material: A (Commercial Steel)

STEP 2: FITTINGS & COMPONENTS
  → Add: 2× 90° Elbows (A)
  → Add: 1× Gate Valve (F)
  → Press ENTER to finish

STEP 3: FLOW SPECIFICATIONS
  → Temperature: 20°C
  → Method: Flow rate
  → Flow: 10 L/s

STEP 4: SYSTEM CONFIGURATION
  → Inlet elevation: 0 m
  → Outlet elevation: 10 m
  → Pressures: Default (atmospheric)

SAVE: Y → Analysis runs automatically
```

---

## 📁 File Structure

```
Fluid_Project/
│
├── main_analyzer.m                    ← Main entry point (START HERE)
├── validation_suite.m                 ← Validation test suite (3 tests)
├── README.md                          ← This documentation file
│
├── src/                               ← Source code (organized by function)
│   │
│   ├── core/                          ← Core calculation functions [4 files]
│   │   ├── calculate_losses.m         ← Main calculation engine
│   │   ├── get_f_from_moody_chart.m   ← Friction factor (Moody/Colebrook-White)
│   │   ├── calculate_egl_hgl.m        ← Energy & hydraulic grade lines
│   │   └── find_operating_point.m     ← Pump selection & operating point
│   │
│   ├── data/                          ← Data access functions [4 files]
│   │   ├── get_water_properties_coolprop.m  ← Water properties (CoolProp/tables)
│   │   ├── get_fitting_K.m            ← K-factor lookup for fittings
│   │   ├── get_pipe_roughness.m       ← Material roughness database
│   │   └── load_pump_database.m       ← Pump database loader
│   │
│   ├── interactive/                   ← User input functions [4 files]
│   │   ├── get_pipe_specs.m           ← Pipe specifications input
│   │   ├── get_fittings.m             ← Fittings selection input
│   │   ├── get_flow_specs.m           ← Flow conditions input
│   │   └── get_system_config.m        ← System configuration input
│   │
│   └── output/                        ← Output generation functions [5 files]
│       ├── generate_report.m          ← Text report generator
│       ├── plot_moody_diagram.m       ← Moody chart with operating point
│       ├── plot_system_pump_curves.m  ← System curve + pump curve + efficiency
│       ├── plot_egl_hgl_profile.m     ← Energy/hydraulic grade line profile
│       └── plot_pressure_profile.m    ← Pressure variation along pipe
│
├── data/                              ← Static data files
│   └── create_pump_database.m         ← Pump curve generator (10 pumps)
│
├── inputs/                            ← Saved analysis inputs (auto-generated)
│   └── run_YYYY-MM-DD_HHMMSS.mat      ← Timestamped input files
│
└── outputs/                           ← Analysis results (auto-generated)
    ├── flow_analysis_*.txt            ← Detailed text reports
    ├── moody_diagram_*.png            ← Moody diagrams
    ├── system_pump_curves_*.png       ← System & pump curves
    ├── egl_hgl_profile_*.png          ← EGL/HGL profiles
    └── pressure_profile_*.png         ← Pressure profiles

**Total:** 20 MATLAB files organized in professional structure
```

---

## 🔬 Technical Details

### Formulas Implemented

#### Flow Properties
- **Velocity**: `V = Q / A`
- **Reynolds Number**: `Re = ρ V D / μ`
- **Flow Regimes**: Laminar (Re < 2300), Transitional (2300 ≤ Re ≤ 4000), Turbulent (Re > 4000)

#### Friction Factor (Moody Chart)
- **Laminar**: `f = 64 / Re`
- **Turbulent**: `1/√f = -2 log₁₀(ε/D/3.7 + 2.51/(Re√f))` [Colebrook-White]
- **Transitional**: Linear interpolation

#### Losses
- **Major (Darcy-Weisbach)**: `h_f = f × (L/D) × (V²/2g)`
- **Minor (K-factor)**: `h_m = Σ K_i × (V²/2g)`
- **Total**: `h_L = h_f + h_m`

#### System Curve
- **Equation**: `H_sys(Q) = H_static + K_sys × Q²`

#### Energy Lines
- **EGL**: `H_EGL = P/(ρg) + V²/(2g) + z`
- **HGL**: `H_HGL = P/(ρg) + z`

### Data Sources

#### Pipe Materials (6 types)
- **A** - Commercial Steel (ε = 0.046 mm)
- **B** - PVC (ε = 0.0015 mm)
- **C** - Cast Iron (ε = 0.26 mm)
- **D** - Stainless Steel (ε = 0.015 mm)
- **E** - Galvanized Iron (ε = 0.15 mm)
- **F** - Drawn Tubing (ε = 0.0015 mm)

#### Fittings (14 types)
- **A-E** - Elbows & Tees (K = 0.4 to 1.8)
- **F-I** - Valves (K = 0.05 to 10.0)
- **J-N** - Expansions, contractions, entrances, exits

#### Pumps (10 models)
- Range: 0.75 kW to 7.5 kW (1 HP to 10 HP)
- Types: Sanitary, Industrial, High-Head, High-Flow
- Best efficiency points: 70-84%

---

## 🧪 Validation

Run validation tests:
```matlab
validation_suite
```

### Test Cases
1. **Laminar Friction Factor** - Exact analytical solution (f = 64/Re)
2. **Turbulent Friction Factor** - Moody chart comparison (Re = 100,000)
3. **Water Properties** - NIST reference data (20°C)

Expected output: `✓✓✓ ALL TESTS PASSED ✓✓✓`

---

## 📊 Outputs

### Text Report
Professional analysis report including:
- System inputs and configuration
- Flow characteristics and Reynolds number
- Pressure losses (major, minor, total)
- Pump selection and operating point
- Power requirements
- Recommendations

### Visualizations

1. **Moody Diagram** - Friction factor vs Reynolds number with operating point
2. **System & Pump Curves** - Intersection showing operating point with efficiency
3. **EGL/HGL Profile** - Energy and hydraulic grade lines along pipe
4. **Pressure Profile** - Pressure variation with distance

---

## 🛠️ Usage Examples

### Example 1: Basic Analysis
```matlab
% Run analyzer
main_analyzer

% Choose: [1] Create new analysis
% Input: DN100 pipe, 50m, 10 L/s, 2 elbows
% Results automatically saved and displayed
```

### Example 2: Load Previous Analysis
```matlab
main_analyzer

% Choose: [2] Load previous analysis
% Select from list of saved runs
% Results regenerated with original parameters
```

### Example 3: Custom Analysis
```matlab
% Manually create input structure
inputs.pipe.diameter = 0.15;  % 150 mm
inputs.pipe.length = 100;     % 100 m
inputs.pipe.material = 'a';
inputs.pipe.roughness = 0.046e-3;
% ... [set other fields]

% Run calculation
results = calculate_losses(inputs);
```

---

## 🔧 Configuration

### CoolProp (Optional)

For accurate water properties, install CoolProp:

```matlab
% Check Python configuration
pyversion

% Install CoolProp
system('python -m pip install --user -U CoolProp')

% Verify
py.CoolProp.CoolProp.PropsSI('D', 'T', 293.15, 'P', 101325, 'Water')
```

**Fallback**: If CoolProp unavailable, tool uses built-in lookup tables (±2% accuracy).

---

## 📖 References

1. **Moody, L.F.** (1944). "Friction Factors for Pipe Flow." *Transactions of the ASME*, 66(8), 671-684.

2. **Colebrook, C.F. & White, C.M.** (1937). "Turbulent Flow in Pipes." *Journal of ICE*, 11(4), 133-156.

3. **White, F.M.** (2011). *Fluid Mechanics* (8th ed.). McGraw-Hill.

4. **Crane Co.** (1991). *Flow of Fluids Through Valves, Fittings, and Pipe*. Technical Paper 410.

5. **NIST** Standard Reference Data (https://www.nist.gov/)

---

## ⚠️ Limitations

- **Single pipe only** - No branched networks
- **Water only** - Not suitable for other fluids without modification
- **Steady flow** - No transient analysis
- **Constant diameter** - No pipe size changes along length
- **Atmospheric discharge** - Assumes outlet at atmospheric pressure

---

## 🎯 Use Cases

### Educational
- Fluid mechanics courses
- Pipe flow demonstrations
- Moody chart understanding
- Loss calculation exercises

### Professional
- Preliminary pipe system design
- Pump sizing estimates
- Energy analysis
- System optimization studies

### Portfolio
- Demonstrates fluid mechanics knowledge
- Shows MATLAB proficiency
- Validates against published data
- Professional code quality

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Unrecognized function or variable 'get_f_from_moody_chart'"  
**Solution**: MATLAB needs to refresh its function cache. Run these commands:
```matlab
addpath(genpath('src'));
addpath('data');
rehash path;
```
Or simply restart MATLAB and run `main_analyzer` (it does this automatically).

**Issue**: Functions not found after restructuring  
**Solution**: Close and reopen MATLAB, or run:
```matlab
rehash path
clear all
```

**Issue**: Test script shows functions not found  
**Solution**: Run the test from the project root directory:
```matlab
cd C:\Users\skaft\Fluid_Project
test_functions
```

**Issue**: CoolProp not found  
**Solution**: Install via pip or use built-in tables (automatic fallback)

**Issue**: No plots appear  
**Solution**: Check that outputs folder exists, ensure figure visibility

**Issue**: Invalid friction factor  
**Solution**: Check Reynolds number and relative roughness values

**Issue**: No suitable pump found  
**Solution**: Adjust flow rate or check if head requirement is too high

**Issue**: Excessive warnings during plotting  
**Solution**: This is normal behavior when generating Moody diagrams (see "Known Behavior" below)

### Known Behavior (Not Bugs)

The following warnings may appear but are **not errors**:

**Warning**: `Friction factor f=0.XXXX is outside typical range [0.008, 0.10]`  
**Explanation**: When `plot_moody_diagram` generates the background Moody chart, it calculates friction factors for extreme Reynolds numbers (Re = 100 to 10⁸) to draw the full chart. At very low turbulent flow (Re < 1000) or very high flow (Re > 10⁷), friction factors can be outside the typical engineering range. This is expected for visualization purposes and does **not** affect your actual pipe flow calculation. The warnings are now suppressed for these extreme plotting conditions.

**Warning**: `Colebrook-White iteration did not converge after 20 iterations`  
**Explanation**: The Colebrook-White equation solver uses Newton-Raphson iteration. At the extreme edges of the Moody chart (used for visualization), convergence can be slow. This does **not** affect your operating point calculation. The warnings are suppressed for extreme Reynolds numbers used in plotting.

**Warning**: `No suitable pump found`  
**Explanation**: Your system requirements exceed all pumps in the database. Consider reducing flow rate, reducing elevation change, or adding more pumps to the database.

---

## 📝 Version History

**Version 1.2** (Nov 3, 2025) - Production Ready ✅
- **Fixed:** Suppressed excessive warnings during Moody diagram plotting
  - Warnings now only appear for realistic flow conditions (100 < Re < 1e6)
  - Background chart plotting no longer spams console
- **Fixed:** Dimension mismatch error in `plot_system_pump_curves.m`
  - Ensured all vectors are column vectors before concatenation
  - Changed `max([H_sys, H_pump])` to `max([max(H_sys), max(H_pump)])`
- **Improved:** Documentation consolidated into single README.md
- **Status:** All 20 files working correctly, no known critical issues

**Version 1.1** (Nov 3, 2025) - Restructuring & Bug Fixes
- **Restructured:** Organized all files into professional `src/` directory structure
  - `src/core/` - Core calculation functions (4 files)
  - `src/data/` - Data access functions (4 files)
  - `src/interactive/` - User input functions (4 files)
  - `src/output/` - Output generation functions (5 files)
- **Fixed:** Function name mismatches (MATLAB requires filename = function name)
  - Renamed `friction_factor_moody.m` → `get_f_from_moody_chart.m`
  - Renamed `select_pump.m` → `find_operating_point.m`
- **Fixed:** Function accessibility after restructuring
  - Added `rehash path` to all entry points
  - Automatic path management in `main_analyzer.m` and `validation_suite.m`
- **Added:** Comprehensive troubleshooting section to README
- **Total:** 20 MATLAB files in organized structure

**Version 1.0** (Nov 2, 2025) - Initial Release
- Initial flat-structure implementation
- 15 core MATLAB files
- 10 pump models in database
- 3 validation test cases
- 4 visualization outputs (Moody, system curves, EGL/HGL, pressure)

---

## 👤 Author

**SK Aftab Hosen**  
Email: skaftabhosen695@gmail.com  

*Developed as part of fluid mechanics coursework and professional portfolio*

---

## 📄 License

MIT License

Copyright (c) 2025 SK Aftab Hosen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**Academic Use:** When using this tool for academic work, please reference the original fluid mechanics sources cited in the References section.

---

## 🚀 Quick Command Reference

```matlab
% Run main analyzer
main_analyzer

% Run validation tests
validation_suite

% Direct calculation (advanced)
results = calculate_losses(inputs);

% Generate individual plots
plot_moody_diagram(results, 'moody.png');
plot_system_pump_curves(results, 'curves.png');
plot_egl_hgl_profile(results, 'egl_hgl.png');
plot_pressure_profile(results, 'pressure.png');

% Generate report only
generate_report(inputs, results, 'report.txt');
```

---

## 📞 Support

For issues or questions:
1. Check this README (especially the Troubleshooting section)
2. Run `validation_suite` to verify installation (should pass 3/3 tests)
3. Review MATLAB command window for error messages
4. Ensure you're in the project root directory: `cd C:\Users\skaft\Fluid_Project`
5. Try refreshing paths: `addpath(genpath('src')); addpath('data'); rehash path;`

---

**END OF README**
