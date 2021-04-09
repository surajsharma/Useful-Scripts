#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from sklearn import datasets
from sklearn import manifold 
from sklearn.datasets import fetch_openml

mnist = fetch_openml('mnist_784')


pixel_values, targets = mnist 
targets = targets.astype(int)