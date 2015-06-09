# JuliaProfiling-MATLAB
MATLAB code that will process the profiling printout of Julia code.

## Posted on the web
As of last push, this is posted here:
http://people.cam.cornell.edu/~zc227/extras/julia_profile.html

## Information
The script provided here will take the "flat" profiling results from Julia code and interpret it by percentage of backtraces. This is useful as the printout can be hard to interpret (functions appearing multiple times with only the number of backtraces reported). This was developed using Julia v0.3-prerelease. 

## Basic Directions
You will need the following files in the same directory (right click, save as):

* Cline.m
* JuliaProfile.m
* Optional: data_flat.txt, a sample data file

To use the JuliaProfile.m file you need the printout from the Julia profiling saved to a file. The script currently uses the filename "data_flat.txt" but you can change that if you'd like a different name. 

## Steps to profile
Steps to (a) profile the Julia code and (b) run the MATLAB script:

1. Open a terminal window in the same folder as your Julia code.
2. Start Julia, type: julia
3. If the function you want to profile, say "my_func()", is in a script you need to include it, type: include("julia_script.jl")
4. Profile the function, type: @profile my_func()
5. Print the profiling results, type: Profile.print(format=:flat)
6. Save the results to a file "data_flat.txt" to the same folder as JuliaProfile.m
7. Run JuliaProfile.m. There is an option to print the results as a LaTeX table (tabular environment).