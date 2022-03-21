#Installing the required Packages
install.packages("tidyverse")
install.packages("janitor")
install.packages("lubridate")
install.packages("scales")
install.packages("writexl")
install.packages("readxl")
install.packages("dplyr")
install.packages('geosphere')
install.packages('gridExtra')
install.packages('ggmap')
install.packages('qmplot')

#Loading the libraries
library(tidyverse)
library(janitor)
library(lubridate)
library(scales)
library(readxl)
library(writexl)
library(dplyr)
library(geosphere)
library(ggmap)


##COLLECTING DATA

Apr_04 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_04.csv")
May_05 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_05.csv")
Jun_06 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_06.csv")
Jul_07 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_07.csv")
Aug_08 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_08.csv")
Sep_09 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_09.csv")
Oct_10 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_10.csv")
Nov_11 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_11.csv")
Dec_12 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2020_12.csv")
Jan_01 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2021_01.csv")
Feb_02 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2021_02.csv")
Mar_03 <- read.csv("C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\2021_03.csv")

##WRANGLING DATA AND COMBINING TO A SINGLE FILE

#Combining the data frames to one data frame
bike_rides <- rbind(Apr_04, May_05, Jun_06, Jul_07, Aug_08, Sep_09, Oct_10, Nov_11, Dec_12, Jan_01, Feb_02, Mar_03)
bike_rides <- janitor::remove_empty(bike_rides, which = c("cols"))
bike_rides <- janitor:: remove_empty(bike_rides, which = c("rows"))


# Viewing the data and its structure

glimpse(bike_rides)

summary(bike_rides)



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

# Creating ride distance column

bike_rides$ride_distance <- distGeo(matrix(c(bike_rides$start_lng, bike_rides$start_lat), ncol = 2), matrix(c(bike_rides$end_lng, bike_rides$end_lat), ncol = 2))
bike_rides$ride_distance <- bike_rides$ride_distance/1000

#Converting ride_length to minutes and hours
bike_rides$ride_length_by_minutes <- difftime(bike_rides$ended_at, bike_rides$started_at, units = c("mins"))
bike_rides$ride_length_by_hour <- difftime(bike_rides$ended_at, bike_rides$started_at, units = c("hours"))

#The speed in Km/h
bike_rides$ride_speed = c(bike_rides$ride_distance)/as.numeric(c(bike_rides$ride_length_by_hour))

# Removing bad data and NAs

bike_rides_2 <- bike_rides %>%
  filter (bike_rides$ride_length_by_minutes > 0) %>% drop_na()

str(bike_rides_2)

#Creating a summary data frame
bike_rides_summary <- bike_rides_2 %>%
  group_by(weekly = floor_date(date, "week"), start_hour, end_hour, member_casual) %>%
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

# Total count rides by week

summary(bike_rides_summary$Count)

bike_rides_summary$Monthly <- lubridate::month(bike_rides_summary$weekly)

#Count of Rides Per week
bike_rides_summary %>% ggplot() + geom_col(aes(x = weekly, y = Count, fill = member_casual)) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides per Week",
       x = 'Week of Ride',
       y = "Average Rides per Day")

# Number of rides by Rider Type in a Week

bike_rides_2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(num_of_rides = n(), .groups = 'drop') %>%
  ggplot(aes(x = weekday, y = num_of_rides, fill = member_casual)) + 
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = "Count of Rides by Member type in a Week",
       x = 'Days of the Week',
       y = "Count of the Rides")

#Creating a summary data frame of bike Types
bike_type <- bike_rides_2 %>%
  group_by(member_casual, rideable_type, weekly = floor_date(date, "week")) %>%
  summarize(
    Minutes = sum(ride_length_by_minutes),
    Mean_mins = mean(ride_length_by_minutes),
    mean_hour = mean(ride_length_by_hour),
    Median_mins = median(ride_length_by_minutes),
    Max_mins = max(ride_length_by_minutes),
    Min_mins = min(ride_length_by_minutes),
    mean_distance = mean(ride_distance),
    Count = n()
  ) %>%
  ungroup()


# Mean Travel time by Member Type
ggplot(bike_type, aes(x = member_casual, y = Mean_mins, fill = member_casual)) +
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = "Mean Ride Minutes by Week",
       x="Rider Type",y = "Mean time in Minutes")


# Mean Travel distance by Member Type
ggplot(bike_type, aes(x = member_casual, y = mean_distance, fill = member_casual)) +
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = 'Mean Travel Distance by Rider Type', x = "Member Type", y = "Mean distance In Km")


# Count of Start of Rides by Hours
ggplot(bike_rides_summary, aes(x = start_hour, y = Count, fill = member_casual)) + geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = "Start Hour of Rides by Hour in a Day",
       x = 'Start Hour of the Ride',
       y = "Rides per Hour")


# Count of End of Rides by Hours
ggplot(bike_rides_summary, aes(x = end_hour, y = Count, fill = member_casual)) + geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = "End Hour of Rides by Hour in a Day",
       x = 'End Hour of the Ride',
       y = "Rides per Hour")


# Total Ride Minutes by Week per member type
ggplot(bike_type, aes(x = weekly, y = Minutes, fill = member_casual)) +
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) + 
  labs(title = "Total Ride Minutes",
       x = 'Week',
       y = 'Ride Minutes')


# Total Ride Minutes by Bike Type
ggplot(bike_type, aes(x = member_casual, y = Count, fill = rideable_type)) +
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = comma) +
  labs(title = "Total Ride Minutes by Bike Type",
       x = 'Member Type',
       y = "Bike Trip in Minutes")


# Weekly Bike Type usage

bike_rides_2 %>%
  mutate(Weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, rideable_type, Weekday) %>%
  summarise(Total = n(), .groups = 'drop') %>%
  ggplot(aes(x = Weekday, y = Total, fill = rideable_type)) +
  geom_col(position = 'dodge') +
  facet_wrap(~ member_casual) +
  scale_y_continuous(labels = comma) +
  labs(title = "Weekly Bike type usage",
       x = 'Member Type',
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


summary(bike_rides_2)

#Most Popular Routes
Routes_table <- bike_rides_2 %>%
  filter(start_lng != end_lng & start_lat != end_lat) %>%
  group_by(start_lng, start_lat, end_lng, end_lat, member_casual, rideable_type) %>%
  summarise(total = n(),.groups="drop") %>%
  filter(total > 250)

#Creating tables for the user types
casual_riders <- Routes_table %>% 
  filter(member_casual == 'casual')
member_riders <- Routes_table %>%
  filter(member_casual == 'member')

#Creating the boundary coordinates for the ggmap
bouding_b_cord <- c(left = -87.700424,
                    bottom = 41.790769,
                    right = -87.554855,
                    top = 41.990119
                    )

#Storing the stamen map of the area
Area_stamen <- get_stamenmap(
  bbox = bouding_b_cord,
  zoom = 10,
  maptype = "toner-lite")

# Visualizing by casual riders routes
qmplot(x = start_lng, y = start_lat, xend = end_lng, yend = end_lat, 
       data = casual_riders, maptype = 'terrain', geom = 'point', 
       color = rideable_type, size = 0.5) +
  coord_cartesian() +
  labs(title = "The popular routes used by Casual Riders",x=NULL,y=NULL, color="User type", caption = "Data by Cyclistic Bike-share Company") +
  theme(legend.position = "none") 

#Visualizing by annual members routes
qmplot(x = start_lng, y = start_lat, xend = end_lng, yend = end_lat, 
       data = member_riders, maptype = 'terrain', geom = 'point', 
       color = rideable_type, size = 0.5) +
  coord_cartesian() +
  labs(title = "The popular routes used by Annual members Riders",x = NULL,y = NULL, color="User type", caption = "Data by Cyclistic Bike-share Company") +
  theme(legend.position = "none") 

str(bike_rides_2)

write_csv(bike_rides_summary, "C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\Analysis Datasets\\bike_rides_summary.csv")
write_csv(bike_type, "C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\Analysis Datasets\\bike_type.csv")
write.csv(bike_rides_2, "C:\\Users\\Pius\\Desktop\\Google Capstone - BikeShare Case study\\Datasets\\Analysis Datasets\\bike_rides_2.csv")
