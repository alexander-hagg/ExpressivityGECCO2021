# Code accompanying "Expressivity of Parameterized and Data-driven Representations in Quality Diversity Search" (GECCO 2021)

We consider multi-solution optimization and generative models for the generation of diverse artifacts and the discovery of novel solutions. In cases where the domain’s factors of variation are unknown or too complex to encode manually, generative models can provide a learned latent space to approximate these factors. When used as a search space, however, the range and diversity of possible outputs are limited to the expressivity and generative capabilities of the learned model. We compare the output diversity of a quality diversity evolutionary search performed in two different search spaces: 1) a predefined parameterized space and 2) the latent space of a variational autoencoder model. We find that the search on an explicit parametric encoding creates more diverse artifact sets than searching the latent space. A learned model is better at interpolating between known data points than at extrapolating or expanding towards unseen examples. We recommend using a generative model’s latent space primarily to measure similarity between artifacts rather than for search and generation. Whenever a parametric encoding is obtainable, it should be preferred over a learned representation as it produces a higher diversity of solutions.

If you use this code in any publication, please do cite:

Hagg, A., Berns, S., Asteroth, A., Colton, S., & Bäck, T. (2021). Expressivity of Parameterized and Data-driven Representations in Quality Diversity Search. In Proceedings of Genetic and Evolutionary Computation Conference, GECCO 2021.
Hagg, A., Asteroth, A., Bäck, T. (2020). A Deep Dive Into Exploring the Preference Hypervolume. in Proceedings of International Conference on Computational Creativity, ICCC 2020.

Author: Alexander Hagg
Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
email: alex@haggdesign.de
Nov 2019; Last revision: 07-Jun-2021

## AutoVE Generative System

AutoVE combines quality diversity algorithms, a divergent optimization method that can produce many, diverse solutions, with variational autoencoders to both model that diversity as well as the user’s preferences, discovering the preference hypervolume within large search spaces. VE, or Voronoi-Elites, is an adaptation to the original formulation of MAP-Elites [1] and Centroidal Voronoi Tessellation Elites [2].

# Demo

Run the demo.m script from the root directory of the repository. This demo contains two autoVE runs, one searching the domain's explicit encoding (parameter search, PS) and one searching in a VAE's latent space (latent search, LS)

# Experiments from paper for replication purposes

## Recombination, Interpolation and Extrapolation
To determine whether the VAE can correctly reproduce, and thus properly represent, fixed predefined shape sets, we measure the models' reconstruction errors on the held-out examples.

Files:
- experiment: IDNvsODN_I_II.m
- analysis: IDNvsODN_I_II_analysis.m

## Expansion
we compare the two search spaces (parameter: PS, and latent: LS) in the AutoVE framework

Files:
- experiment: IDNvsODN_III.m
- analysis: IDNvsODN_III_analysis.m

# Literature
[1] Antoine Cully, Jeff Clune, Danesh Tarapore, and Jean-Baptiste Mouret. 2015. Robots that can adapt like animals. Nature 521, 7553 (2015).
[2] Vassilis Vassiliades, Konstantinos Chatzilygeroudis, and Jean-Baptiste Mouret. 2017. Using Centroidal Voronoi Tessellations to Scale Up the Multidimensional Archive of Phenotypic Elites Algorithm. IEEE Transactions on Evolutionary Computation 22, 4 (2017).