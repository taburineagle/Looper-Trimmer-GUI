# Looper-Trimmer
EDL-like trimmer for .looper files generated by my MPC-HC Looper program.  The Trimmer program can take a list of events from a .looper file and using either ffmpeg (for 99% of files), or using tsMuxeR (for MTS files with time/date subtitle data, because ffmpeg can't copy that form of subtitle data correctly!), trim each event into a smaller file to save space.