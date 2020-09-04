# knnview: Visualizing nearest neighbors of high-dimensional metagenomic samples

knnview is a shiny app developed to visualize and explore the nearest 
neighbors of labeled samples. For each sample, the purity score is
defined to be the fraction of the k nearest neighbours
(kNN) that share the cluster label of the sample. The tool
brings attention to samples with non-perfect scores (i.e. <1), and allows to
explore the disribution of distances between a sample and its neighbors. 

This tool was developed by Eitan Yaffe. It is distributed under the GNU General
Public License v3.0. If you have questions or comments please contact eitan.yaffe@gmail.com.

## Prerequisites

The tool requires these R packages installed: shiny, Rtsne, digest. To install this packages run within an R session:
```
> install.packages(c("shiny", "Rtsne", "digest"))
```

## Installation

1. Create a working directory. Here we use ~/work as an example.
```
% mkdir -p ~/work
% cd ~/work
```

2. Get the source code from github.
```
% git clone https://github.com/eitanyaffe/knnview.git
```

3. Set the environment variable KNNVIEW_DIR to point to the knnview
directory you've created. You can add the following line at the end of your 
.bashrc (or ~/.zshrc if using a new version of MacOS):
```
export KNNVIEW_DIR=~/work/knnview
```

## Quick start

To run knnview on a toy example, using simulated data:

1. Go to the KNNVIEW_DIR directory and start an R session.
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

## Input

There are two mandatory input data structures:

1. A data.frame that associates samples and clusters, plus optional sample
  metadata. The two required fields are the sample id and cluster id.
2. A sample distance matrix, with rows and columns named by sample id.

## Usage

See the `examples/sim_example.r` script for a simple usage example. 

To initialize the session you must call the
`knnview.init` function. The function parameters are:
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
* `max.items.in.legend`: max items displayed in color legend (default: 40).

Any fields defined using the `fields` will be available for both
colors and text labels in the app.

The `use.df.xy` is useful when you have generated xy values for samples.

The `plot.all` is allows to see all samples or limit view to clusters
involved in non-pure samples (including neighboring clusters).

The function returns a data.frame with all samples with a purity score
smaller than 1. The `score` column is the purity score, the
`oneighbor` column is the closest neighboring sample that is of a
different cluster, and the `ocluster` column is the matching offending
cluster.


Example of usage:
```
> result = knnview.init(k=10, df=df, D=D, field.id="sample", field.cluster="cluster")
```

To start the app after calling `knnview.init` you must call the `rl()`
function:
```
> rl()
```

If the session dies for some reason you can always reload using the
`rl` function. 

## Application UI description

The 2D organization of samples is shown in the middle panel. The panel
is interactive and allows to zoom in and out, and select
samples. The color of the outer circles around samples signify the purity
 score:
 * Black: Purity score in the range [0,0.8)
 * Dark gray: Purity score in the range [0.8,0.9)
 * Light gray: Purity score in the range [0.9,1.0)

The similarity index (equal to the distance minus 1) for the selected
sample is shown on the right panel. Colors and labels match the middle panel.

Viewing parameters, like the color and textual label of samples are
controlled using the left panel.
* NN-count (edges): Controls the number of kNN for which an edge is
  drawn in the middle panel.
* NN-count (barplot): Controls the number of neighbours shown on the
  right panel.
* Show only cluster NN: Show on right panel only samples of selected
  cluster.
* Show labels: Show text labels in middle plot.
* Show legend: Show legend of colors in middle panel.
* Label field: Add text labels to samples using this sample metadata field.
* Color field: Color samples using this sample metadata field.
* Plot circle size: Control size of sample circle.

Hit the Help button to see a brief explanation of how to operate the
app, including the use of the mouse and keyboard. This includes useful
keyboard shortcuts.

