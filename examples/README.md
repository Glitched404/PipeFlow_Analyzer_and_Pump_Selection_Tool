# Example Analysis

This folder contains a sample analysis run demonstrating the tool's capabilities.

## Sample Case: Industrial Pipe System

**System Specifications:**
- Pipe: DN100 (100 mm), 50 m length, Commercial Steel
- Fluid: Water at 20°C
- Flow Rate: 15 L/s (1.91 m/s)
- Elevation Change: 0 → 10 m

**Fittings:**
1. 90° Standard Elbow at 10 m
2. 90° Standard Elbow at 25 m
3. Gate Valve at 40 m

**Results:**
- Reynolds Number: 213,952 (Turbulent)
- Friction Factor: 0.0185
- Total Head Loss: 4.99 m
- Pump Required: 5.5 kW

## Files Included

- `sample_input.mat` - Saved input parameters
- `sample_report.txt` - Detailed analysis report
- `sample_moody.png` - Moody diagram with operating point
- `sample_pressure.png` - Pressure profile showing discrete drops
- `sample_egl_hgl.png` - Energy and hydraulic grade lines
- `sample_system_pump.png` - System curve and pump selection

## How to Load This Example

```matlab
% Navigate to project directory
cd C:\path\to\PipeFlow-Analyzer

% Load the sample input
load('examples/sample_input.mat')

% Run analysis with loaded parameters
results = calculate_losses(inputs);

% Generate outputs
generate_report(inputs, results, 'my_analysis.txt');
```

## Expected Output

The sample analysis demonstrates:
- ✅ Discrete pressure drops at fitting locations (visible as vertical red lines)
- ✅ Step-wise energy dissipation in EGL/HGL profiles
- ✅ Accurate pump selection based on system requirements
- ✅ Professional visualization with detailed annotations
