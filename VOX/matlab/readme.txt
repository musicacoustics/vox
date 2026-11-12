Welcome to vox, the voice synthesis script for Matlab

Installation:
1. copy the content of the zip file into any folder on your local disk
   (or clone the repository, see README.md in the repository root)
2. in MATLAB, change to this folder and type "vox"
   (install.m and voxpath.mat are no longer needed: vox finds its own folder)
3. vox will launch

Use: 
1. Select the operation mode in the "Input" dropdown menu the upper right corner:
Folds: vocal fold simulation
Tract: vocal tract simulation
VF*VT: convolute the results from vocal fold and vocal tract simulation
Combi: perform simultaneous calculation of vocal fold and vocal tract function

2. set parameters
2.1 General settings 
2.2 Vocal fold parameters; select register (M)odal, (H)ead, (F)alsetto; use "m." to modify vocal fold configuration
2.3 Vocal tract parameters; computation mode: parallel segments (stairs) or conical segments (tubes) use "m." to modify vocal fold configuration 

3. Perform calculations by pressing "Calc"; wait

4. interrupt without ("Quit") or with saving of results ("Break")

5. Visualise the results ("Display")

Comments and improvements are welcome!

Detmold, 1.11.2015 
Malte Kob