# righting_the_writers
This GitHub repository hosts the 'Righting the Writers' project materials, including the Python and R scripts and the Jupyter notebooks for scraping, cleaning, and analyzing political bias on Wikipedia using event studies and sentiment analysis.

This GitHub repository hosts the 'Righting the Writers' project materials, which explore assessing bias in Wikipedia’s political content. Below is a breakdown of the content and structure of this repository:

## Repository Structure

- **/data**: Contains the datasets used in the analyses, including historical snapshots of Wikipedia pages of 1,399 politicians from the US, UK, and Canada.

- **/scripts**: This includes Python and R scripts for data collection and analysis. Python scripts handle data retrieval and initial processing, while R scripts are used for detailed statistical analysis.

- **/notebooks**: Jupyter notebooks document the step-by-step processes of the analyses, including data cleaning, exploratory data analysis, and the event study/staggered difference-in-differences approach combined with sentiment analysis.

- **/papers**: This folder contains the final research paper in PDF format, which details the study's findings and methodology.

- **requirements.txt**: This file lists all Python dependencies necessary to run the scripts, ensuring the analysis's replicability.

## Key Files

- **Analysis.R**: R script for performing the statistical analysis using event study and DiD methodologies.
  
- **paper.ipynb**: A Jupyter notebook that complements the static R scripts by providing a visual and interactive component to the analysis.
  
- **Summer_Research_Paper-Righting the Writers.pdf**: The final paper summarizing the study's motivation, methodology, results, and implications.
  
- **get_articles.py & analyze.py**: Python scripts used for scraping Wikipedia data and initial data processing.

## Installation

To set up the environment to run the scripts and notebooks, Python 3.8+ and R 4.0+ are required. Install Python dependencies using:

