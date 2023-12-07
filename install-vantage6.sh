# Create a new conda environment with Python 3.10
$HOME/miniconda/bin/conda create -n vantage6 python=3.10 -y &>> vantage6-install.log

# Activate the new environment
$HOME/miniconda/bin/activate vantage6 &>> vantage6-install.log

# Install the vantage6 package
pip install vantage6 &>> vantage6-install.log