# Smart E-Commerce Recommendation & Customer Analytics System

An end-to-end portfolio project that stores e-commerce activity in **MySQL**, answers customer/product business questions with **SQL**, and uses **Python + Pandas** for RFM segmentation and personalized collaborative-filtering recommendations.

## What the system answers

- What and how often does each customer buy?
- Who are the top, repeat, one-time, inactive, and at-risk customers?
- Which products/categories sell most, earn most, or show declining sales?
- Which products are frequently purchased together?
- Which products have many views but poor conversion?
- What should customer `C101` buy next, and why?
- How many customers may be interested in each recommended product?

## Project Architecture(for personal understanding)

```
flowchart LR
    A[E-commerce data] --> B[(MySQL)]
    B --> C[SQL views and analysis]
    C --> D[Python + Pandas]
    D --> E[RFM segmentation]
    D --> F[Customer-based recommendations]
    E --> G[(customer_segments)]
    F --> H[(recommendations)]
    E --> I[CSV reports]
    F --> I
```

## Prerequisites

- MySQL 8.0 or newer
- Python 3.10 or newer


## One-command demo

After completing the first-time setup once, make sure MySQL is running and use:

```powershell
.\demo.bat
```

The launcher reads the database password from `.env`, so it does not prompt for it. It runs the analytics without changing the database result tables, refreshes the CSV reports, and displays the customer segments, top customers, and recommendations for `C101`.

You do not need to rerun the installation, database setup, tests, or individual SQL files for each demonstration.

To see every numbered business question and run all answers or one answer at a time, read (docs/QUESTION_COMMANDS.md):

```powershell
.\questions.bat list  # show all 16 questions
.\questions.bat all   # answer all 16 questions
.\questions.bat 14    # answer only question 14
```