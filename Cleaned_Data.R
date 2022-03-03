#Installing the required Packages
install.packages("tidyverse")
install.packages("janitor")
install.packages("lubridate")
install.packages("scales")
install.packages("writexl")
install.packages("readxl")
install.packages("dplyr")

#Loading the libraries
library(tidyverse)
library(janitor)
library(lubridate)
library(scales)
library(readxl)
library(writexl)
library(dplyr)

##COLLECTING DATA

Apr_04 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_04.xlsx")
May_05 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_05.xlsx")
Jun_06 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_06.xlsx")
Jul_07 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_07.xlsx")
Aug_08 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_08.xlsx")
Sep_09 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_09.xlsx")
Oct_10 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_10.xlsx")
Nov_11 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_11.xlsx")
Dec_12 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2020_12.xlsx")
Jan_01 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2021_01.xlsx")
Feb_02 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2021_02.xlsx")
Mar_03 <- read_excel("C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Datasets - XLSX\\2021_03.xlsx")

##WRANGLING DATA AND COMBINING TO A SINGLE FILE

#Combining the data frames to one data frame
bike_rides <- rbind(Apr_04, May_05, Jun_06, Jul_07, Aug_08, Sep_09, Oct_10, Nov_11, Dec_12, Jan_01, Feb_02, Mar_03)
bike_rides <- janitor::remove_empty(bike_rides, which = c("cols"))
bike_rides <- janitor:: remove_empty(bike_rides, which = c("rows"))

str(bike_rides)


#Removing lat, long

bike_rides <- bike_rides %>%
  select(-Day_of_week)

str(bike_rides)


#Parse Time and create a hour field
bike_rides$date <- as.Date(bike_rides$started_at)
bike_rides$started_at <- lubridate::ymd_hms(bike_rides$started_at)
bike_rides$ended_at <- lubridate::ymd_hms(bike_rides$ended_at)

bike_rides$start_hour <- lubridate::hour(bike_rides$started_at)
bike_rides$end_hour <- lubridate::hour(bike_rides$ended_at)

#Dates, Day, Month
bike_rides$Month <- format(as.Date(bike_rides$date), "%m")
bike_rides$Day <- format(as.Date(bike_rides$date), "%d")
bike_rides$Year <- format(as.Date(bike_rides$date), "%Y")
bike_rides$Day_of_week <- format(as.Date(bike_rides$date), "%A")

str(bike_rides)

#Converting ride_length to minutes and hours
bike_rides$ride_length_by_minutes <- difftime(bike_rides$ended_at, bike_rides$started_at, units = c("mins"))
bike_rides$ride_length_by_hour <- difftime(bike_rides$ended_at, bike_rides$started_at, units = c("hours"))

#Removing bad data
bike_rides_2 <- bike_rides %>%
  filter (bike_rides$ride_length_by_minutes > 0) %>% drop_na()

str(bike_rides_2)



#Creating a summary data frame
bike_rides_summary <- bike_rides_2 %>%
  group_by(weekly = floor_date(date, "week"), start_hour) %>%
  summarize(
    Minutes = sum(ride_length_by_minutes),
    Mean = mean(ride_length_by_minutes),
    Median = median(ride_length_by_minutes),
    Max = max(ride_length_by_minutes),
    Min = min(ride_length_by_minutes),
    Count = n()
  ) %>%
  ungroup()

bike_rides_summary

#Plotting rides by date
summary(bike_rides_summary$Count)

bike_rides_summary$Monthly <- lubridate::month(bike_rides_summary$weekly)

#Count of Rides Per Day
bike_rides_summary %>% ggplot() + geom_col(aes(x = weekly, y = Count)) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides per Day", 
       subtitle = "Bases on 28-day Moving Average",
       y = "Average Rides per Day")

#Count of Rides by Hours
bike_rides_summary %>% ggplot() + geom_col(aes(x = start_hour, y = Count)) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides by Hours",
       y = "Rides per Hour")

#Creating a summary data frame of bike Types
bike_type <- bike_rides_2 %>%
  group_by(member_casual, rideable_type, weekly = floor_date(date, "week")) %>%
  summarize(
    Minutes = sum(ride_length_by_minutes),
    Mean = mean(ride_length_by_minutes),
    Median = median(ride_length_by_minutes),
    Max = max(ride_length_by_minutes),
    Min = min(ride_length_by_minutes),
    Count = n()
  ) %>%
  ungroup()

#Count of bike type (Total by week)
ggplot(bike_type) + 
  geom_col(aes(x = weekly, y = Count, fill = rideable_type)) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides by Bike Type")


#Count of Rides by Rider Type
ggplot(bike_type) + 
  geom_col(aes(x = weekly, y = Count, fill = member_casual)) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides by Rider Type")

#Total Ride Minutes by Week
ggplot(bike_type) + geom_col(aes(x = weekly, y = Minutes)) +
  scale_y_continuous(labels = comma) + 
  facet_wrap(~ rideable_type) + 
  labs(title = "Total Ride Minutes by Week")

#Ride Minutes by Bike Type and Week
ggplot(bike_type, aes(x = weekly, y = Minutes, fill = rideable_type)) +
  geom_area(stat = "identity", position = position_dodge(width = NULL), alpha = 0.75) +
  scale_y_continuous(labels = comma) +
  labs(title = "Rides Minutes by Bike Type and Week",
       y = "Bike Trip in Minutes")

#Top 20 Start Station Name by Ride Count
bike_rides_2 %>% 
  count(start_station_name, sort = TRUE) %>%
  top_n(20) %>%
  ggplot() + geom_col(aes(x = fct_reorder(start_station_name,n), y = n)) +
  coord_flip() + 
  labs(title = "Top 20 Start Stations by Ride Count",
       y = "Station Name",
       x = "Count of Rides") + 
  scale_y_continuous(labels = comma)

write_csv(bike_rides_summary, "C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Analysis Datasets\\bike_rides_summary.csv")
write_csv(bike_type, "C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Analysis Datasets\\bike_type.csv")
write.csv(bike_rides_2, "C:\\Users\\Pius\\Desktop\\Google Capstone Revised\\Datasets\\Analysis Datasets\\bike_rides_2.csv")
