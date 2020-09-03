# knnview: Visualizing nearest neighbors of high-dimensional metagenomic samples

knnview is a shiny app developed to visualize and explore the nearest 
neighbors of labeled samples.

This shiny app was developed by Eitan Yaffe. It is distributed under the GNU General
Public License v3.0. If you have questions or comments please contact Eitan
Yaffe at eitan.yaffe@gmail.com.

## Pre-requisites

The tool requires this R packages installed: shiny, Rtsne, MASS,
digest. To install this packages run within an R session:
```
> install.packages(c("shiny", "Rtsne", "MASS", "digest"))
```

## Installation

1. Create a working directory. Here we use ~/work as an example.
```
% mkdir -p ~/work
% cd ~/work
```

2. Get source code from github.
```
% git clone https://github.com/eitanyaffe/knnview.git
```

3. Set the environment variable HPIPE_DIR to point to the hpipe dir.
For example, if using bash, you can add the following line to your
.bashrc (or ~/.zshrc in newer versions of MacOS):
```
% export KNNVIEW_DIR=~/work/knnview
```

## Quick Start

To run knnview on a toy example  and run the following.

1. Go to KNNVIEW_DIR directory and start an R session.
```
% cd ${KNNVIEW_DIR}
% R
```

2. Within the R session, init the viewer with the following command.
```
> source("examples/sim_example.r")
```

3. Start the interactive session by using this command.
```
> rl()
```

## Startup

See the `examples/sim_example.r` script for a simple usage example. 

To initialize the session you must call the
`knnview.init`. Parameters:
* `df`: data.frame of samples.
* `D`: Distance matrix of samples.
* k: k value used in kNN (default: 10).
* `min.score`: classify sample as pure if purity score is at least
  this score (default: 0.9).
* `run.recursive`: if true runs until convergence (default: false).
* `field.id`: sample column in df (default: 'id').
* `field.cluster`: cluster column in df (default: 'cluster').
* `fields`: columns in df used for text/color annotation (default: 'c("id", "cluster")').
* `init.field.col`: initial field used for color (default: 'cluster').
* `init.field.label`: initial field used for label (default: 'cluster').
* `plot.all`: if false, plots only clusters involved in non-perfect
  scores (default: T).
* `use.df.xy`: override t-SNE coords with user-specified x/y coords in
  the df (default: F).

Example of usage:
```
> knnview.init(k=10, df=ll$df, D=ll$D, field.id="sample",
field.cluster="cluster", use.df.xy=T)
```

To start the app after calling `knnview.init` you must call the `rl()`
function:
```
> rl()
```

If the session dies for some reason you can always reload using the
`rl` function. 
