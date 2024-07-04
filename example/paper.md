---
title: >-
    ReciPys: A Fast Python Package for Simplifying Machine Learning Preprocessing Pipelines
authors:
  - name: Robin van de Water
    email: albert@zeitkraut.de
    affiliation: [1, 2]
    orcid: 0000-0002-2895-4872
    corresponding: true
  - name: Hendrik Schmidt
    orcid: 0000-0001-7699-3983
    affiliation: 
    equal-contrib: false
  - name: Patrick Rockenschaub
    orcid: 0000-0002-6499-7933
    affiliation: [1, 3]
    equal-contrib: false
affiliations:
  - index: 1
    name: Hasso Plattner Institute, University of Potsdam, Potsdam, Germany
  - index: 2
    name: Hasso Plattner Institute for Digital Health at Mount Sinai, Icahn School of Medicine at Mount Sinai, New York City, NY, USA
  - index: 3
    name: Innsbruck Medical University, Innsbruck, Austria
date: 2024-07-04
bibliography: paper.bib
tags:
  - reference
  - example
  - markdown
  - publishing
---
<!-- 
Guide:
https://github.com/openjournals/inara/blob/main/example/paper.md  -->
# Summary

Machine learning pipelines often require complicated preprocessing pipelines. Our aim is to simplify this with a speedy python package that can be used to preprocess data for machine learning tasks.

# Statement of Need

Python is the most popular programming language for machine learning. However, preprocessing data for machine learning tasks can be a time-consuming and error-prone process. ReciPys is a python package that aims to simplify this process by providing a fast and intuitive interface for preprocessing data. The package uses a polars backend which allows for fast python-native data processing. ReciPys is designed to be easy to use and flexible, allowing users to easily preprocess data for a wide range of machine learning tasks.
