# MLB-Pitching-Batting-Data-Analysis
This project explores the Tampa Bay Rays of the Major League Baseball (MLB) pitching and batting statistics using a combination of Microsoft Excel and SQL. The goal is to extract, clean, and analyze player performance data to uncover patterns, insights, and interesting trends within recent MLB seasons.

## Project Overview

- **Data Source**: Raw player statistics were gathered from publicly available MLB datasets (e.g. [Baseball-Reference](https://www.baseball-reference.com/) and [BaseballSavant](https://baseballsavant.mlb.com/)).
- **Tools Used**:  
  - **Excel**: Used for initial data extraction, cleaning, formatting, and basic filtering.  
  - **SQL**: Used to run deeper queries, aggregations, and comparative analysis across players and seasons.

## Project Objectives

- Filter and organize raw data to make it analysis-ready
- Use SQL queries to answer specific questions, such as:
  - AVG Pitches Per At Bat Lefty Vs Righty
  - Percentage of the different last pitches being Fastball or Offspeed
  - Show HRs for each count type -> Balls/Strikes + Type of Pitcher

## Key Features

- Integrated data workflow: Excel for preprocessing, SQL for querying
- Analysis of both pitching and batting metrics
- Focus on performance metrics such as:
  - Batting Average (AVG)
  - Home Runs (HR)
  - Runs Batted In (RBI)
  - Strikeouts (SO)
  - Walks and WHIP (for pitchers)
- Clean, readable SQL queries for reproducibility

## Future Improvements

- Automate data ingestion using Python
- Connect to a live database for real-time querying
- Add visualizations using tools like Tableau or Power BI
