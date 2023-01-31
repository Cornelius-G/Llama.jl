using LAMA
using Glob

cd("C:\\Users\\Cornelius\\.julia\\dev\\LAMA\\examples")


target_folder = "results/"
target_signature = "*/*.toml"

inputfiles = glob(target_signature, target_folder)

collect_csv(inputfiles, "output.csv", levels=2, selection=to_keep, remove=to_remove)



to_keep = ["mX", "sX", "fit_type", "sampling_algorithm.nsteps"]
to_remove = ["datetime", "sampling_algorithm.nchains", "sampling_algorithm.nsteps"]
collect_csv(inputfiles, "output.csv", levels=2, selection=to_keep, remove=to_remove)




