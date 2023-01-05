# Worldwide Opera Performance Data, 2012-2018

## Background

From 2015-2021, I was a professional classical pianist and opera coach. A large part of my job was to learn operas and play them in rehearsals for opera companies; I would serve as the full orchestra, which would be incorporated at the end of rehearsals and in performances.

Learning an entire opera is demanding and time-consuming. Many are over 2 or 3 hours long, most are in a foreign language (which needs to be learned), and none were written for piano so many of them are extremely difficult to play. Moreover, given that opera has been around since the early 1600s, there are far more operas in the repertoire than would be possible for any one person to learn in an entire lifetime, much less in a few years as a student.

In this project, I explored a dataset of opera performances around the world between 2012-2018 to answer the questions that were top of mind when I was a pianist: what operas should I learn? Who are the most popular composers? What languages/countries produced the most operas? For some composers, would I be able to focus on just one of their pieces, or would I need to learn multiple from some composers? Essentially: what is the most efficient way for me to learn as much of the in-demand repertoire as possible, so I could be as hirable and effective as possible? I knew that some operas were more important and popular than others, but I wanted to quantify that popularity.

## Dataset/Cleaning

This dataset was a comprehensive list of opera performances. To clean the dataset and ensure its accuracy, I took the following steps:

- Removed columns that were unnecessary for my analysis, including season, production, type, and start date
- Cleaned the composer nationality column by looking up all composers that had null values
- Carefully checked the composers and piece titles for entries that didn't belong
  - For example, I saw several oratorios on the list by composers such as Bach, Beethoven, and Handel. Oratorio is a similar genre to opera, but distinct enough that I felt they should be removed.
  - It's highly possible that some non-operas still slipped through the cracks; however, these would only be pieces that received a few performances total and would not materially affect the conclusions.
- Converted ISO country codes to country names, for better readability on composer nationality and performance country columns.

#### Dataset Caveats

The main caveat of this dataset is that it only includes up to 2018. Normally this lack of immediate recency wouldn't be relevant; however, the COVID pandemic and social justice conversations in the wake of George Floyd protests have had a resounding impact on the classical music and opera worlds, as everywhere else. I would be interested to see a dataset in a few years from now incorporating these changes to determine any tangible impact on the composers being performed and stories being told in opera.

Another important caveat to keep in mind is that many smaller opera companies, particularly in the United States, would likely be left out of a dataset such as this. It would be very difficult to keep an accurate count of every single operatic performance, especially ones that only have a small audience of dozens. At least in the US, a lot of the most innovative programming of newer and lesser-known composers happens at these small grassroots companies, which wouldn't be reflected in this dataset.

## Analysis Tools/Methods

For this project, I used SQL to analyze the data and Tableau for visualization.

- All SQL queries can be found [here](https://github.com/Jonathan-Heaney/opera_sql/blob/main/opera_stats.sql)
- Tableau visualizations can be found [here](https://public.tableau.com/views/opera_stats/PerfCountComposer?:language=en-US&:display_count=n&:origin=viz_share_link)

## Conclusions

#### Power Laws/Pareto Principle

The main takeaway is that opera performances are dominated to an extreme degree by power laws. This means that performances are very unevenly distributed: although there are thousands of pieces in existence, a much, much smaller number gets performed with any regularity. The same is true for composers; there are many of them, but a small number dominate the field.

The [Pareto Principle](https://betterexplained.com/articles/understanding-the-pareto-principle-the-8020-rule/) states that 80% of outcomes come from 20% of causes, but opera is actually even more extreme in this regard. For example:

- The top **38** operas (out of 2,863 in this dataset) make up **50%** of total performances.
- **80%** of performances come from **7.9%** of operas.
- The top **8** composers (out of 1,411) make up **52%** of total performances.
- **80%** of performances come from **3%** of composers.

Though a lot of composer nationalities were represented (69 total), the top **4** (all European) represent **76%** of all performances.

The outputs of many individual composers also follow a power law- for example, Mozart wrote 21 operas, but **90%** of his performances came from his top **5**.

These statistics may not be good news for the health of the opera industry as a whole, but they do provide some pretty clear takeaways for someone who was in my position:

- Prioritize the popular works of Verdi, Mozart, and Puccini.
- Learn extremely popular operas not by the above three composers:
  - _Carmen_ by Bizet
  - _Il barbiere di Siviglia_ by Rossini
  - _Die Fledermaus_ by Johann Strauss
- Learn the top-performed opera by the most popular composers not already listed:
  - _L'elisir d'amore_ by Donizetti
  - _Der fliegende Hollander_ by Wagner
  - _Eugene Onegin_ by Tchaikovsky
- In terms of language learning: prioritize Italian above all else, followed by German, followed by French.

Most composers maintain similar styles throughout their careers, so by focusing on these few operas by these composers, one could cover an extremely high percentage of all the composers/works that one would be expected to know.
