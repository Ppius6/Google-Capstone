# Google-Capstone-R-Analysis
## Introduction
Cyclistic, a bike-share program launched in 2016, has grown to become a fleet of 5,824 bicycles spread across 692 stations in Chicago. With pricing plans ranging from single-ride passes to annual memberships, Cyclistic has attracted both casual riders and annual members. However, Cyclistic's finance analysts have concluded that annual members are more profitable than casual riders. In an effort to maximize the number of annual members, the marketing team aims to convert casual riders into members. To achieve this goal, the team needs to understand the differences in usage between annual members and casual riders, the reasons why casual riders would buy annual memberships, and how digital media can influence marketing tactics. This project analyzes Cyclistic's historical bike trip data to identify trends that will guide future marketing programs. 
The analysis will focus on answering the following questions: 
1. How do annual members and casual riders use Cyclistic bikes differently? 
2. Why would casual riders buy Cyclistic annual memberships? 
3. And, how can Cyclistic use digital media to influence casual riders to become members?

## Packages Used
- Tidyverse: for data manipulation and visualization
- Janitor: for data cleaning
- Lubridate: for working with dates and times
- Scales: for formatting numbers and dates
- Writexl: for writing data frames to Excel
- Readxl: for reading Excel files
- Dplyr: for data manipulation
- Geosphere: for calculating distances between locations
- GridExtra: for arranging multiple plots on a page
- Ggmap: for visualizing maps
- Qmplot: for creating quick maps

## Data Cleaning
Before analysis, the data was cleaned using the janitor package to remove missing values, duplicates, and outliers. Date and time columns were converted to the appropriate format using the lubridate package.

## Data Analysis
The analysis consisted of the following steps:
1. Exploratory data analysis to understand the distribution of the data and identify patterns and trends.
2. Analyzing the usage patterns by day of the week, time of day, and location.
3. Calculating the distance and speed of the rides.
4. Investigating the impact of weather on usage patterns.
5. Examining the relationship between user demographics and usage patterns.
6. Developing recommendations to increase growth.

## Findings
The analysis produced the following findings:
- The bike rides peaked on summers, and dipped during the winter. 
- The casual riders have a higher ride count than the annual members. It can be assumed that the casual riders utilize the bikes for leisure than the annual members.
- The annual members had a higher daily usage of the rides except on Saturday. It seems their frequency of usage was higher as opposed to the casual riders who seemed to use the bikes for leisure as their rides peak more on weekends than on weekdays while annual members probably used the bikes as a formal type of transport i.e. to work.
- The casual riders had a higher mean ride in minutes weekly which denotes their high usage. The annual members had a lower mean ride time.
- The annual members had a higher mean travel distance than the casual members. However, their mean travel distance was closer with a slight difference.
- The rides peaked at 5 PM by start hour for all types of riders. It can be seen that most riders were much available at this time. The frequency of rides decreased from this hour and started increasing again at 5 AM till 5 PM.
- Casual riders had a higher total ride minutes monthly as compared to the annual members.
- The docked bike was mostly used by both segments of riders based on total ride minutes, followed by classic bike, and last was electric bike.
- However, comparing daily usage of the three bike types in the two segments of riders, the docked bike was far more used based on the total minutes, followed by electric bike, and lastly classic bike.
- It seems that casual riders least preferred the classic bike, while annual members blended their usage of classic bikes and electric bikes.

## Recommendations
Based on the findings, the following recommendations are suggested:
- Annual members tend to use Cyclistic bikes for commuting to work while casual riders use the bikes more for leisure. Therefore, Cyclistic can tailor its marketing campaigns to target different segments accordingly. For instance, for annual members, Cyclistic can emphasize the convenience and cost-saving benefits of using bikes as a mode of transport for commuting to work.
- Casual riders can benefit from Cyclistic annual memberships if they tend to use the bikes frequently. To attract them, Cyclistic can offer promotions, discounts, and rewards for annual membership sign-ups.
- Cyclistic can use digital media to influence casual riders to become members by promoting the benefits of using bikes, such as reducing carbon footprint, staying active, and saving money. Cyclistic can also use social media platforms to showcase the experiences of its satisfied customers and how their bikes have improved their lives. This can help in building trust and increasing the likelihood of casual riders becoming annual members.
