---
title: >-
    ReciPys: An Intuitive and Fast Python Package for Simplifying Machine Learning Preprocessing Pipelines
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

Python is the most popular programming language for machine learning. However, preprocessing data for machine learning tasks can be a time-consuming and error-prone process. ReciPys is a python package that aims to simplify this process by providing a fast and intuitive interface for preprocessing data. It can use both a polars [@PolarsPolars2024] backend, which allows for fast python-native data processing, and a traditional Pandas [@mckinney-proc-scipy-2010] backend for use with legacy data tools. ReciPys is designed to be easy to use and flexible, allowing users to easily preprocess data for a wide range of machine learning pipelines. Moreover, we hide the complexity of the preprocessing pipeline from the user.
# Benchmarks

# Related Work
The package was inspired by the R package by @kuhnRecipesPreprocessingFeature2024. 
# Application: ICU Data
The package was specifically aimed towards temporal EHR data. We demonstrate the utility of ReciPys by preprocessing a dataset of ICU patients. The dataset contains information about patients in the ICU, including vital signs, lab results, and medications. We show how ReciPys can be used to preprocess this data and prepare it for machine learning tasks.

If we have a dataset, `df` with a label `y`, some features `x1`, `x2`, `x3`, `x4`, an identifier `id`, and a sequential component `time`, we can build a preprocessing pipeline using ReciPys. We first do a train/test split:
``` python
df_train, df_test = train_test_split(df, test_size=0.2, random_state=42)
roles = {outcomes:["y"], predictors=["x1", "x2", "x3", "x4"], groups=["id"], sequences=["time"]}
ing = Ingredients(df_train, roles=roles)
rec = Recipe(ing)
```
We can now add preprocessing steps:
``` python
rec.add_step(StepScale())
rec.add_step(StepSklearn(MissingIndicator(features="all"), sel=has_role("predictor")))
rec.add_step(StepImputeFill(strategy="forward"))
rec.add_step(StepSklearn(LabelEncoder(), sel=has_type("cateogircal"), columnwise=True))
```

We can now fit the recipe and transform both the train and test set without leakage:
``` python
df_train = rec.prep()
df_test = rec.bake(df_test)
```

