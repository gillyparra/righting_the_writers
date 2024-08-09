# Load necessary libraries
library(dplyr)
library(readr)

# Read the data
data <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/RightDF.csv', show_col_types = FALSE)

# Convert the date columns to Date type
data$date <- as.Date(data$date)
data$Date_of_party_switch <- as.Date(data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
data <- data %>%
  arrange(Name, date)

# Identify the rows where treated_dummy changes from 0 to 1 and capture Date_of_party_switch
switch_rows <- data %>%
  group_by(Name) %>%
  mutate(lead_treated_dummy = lead(treated_dummy)) %>%
  filter(treated_dummy == 1 & lag(treated_dummy) == 0) %>%
  select(Name, Date_of_party_switch)

# Join the switch_rows back to the original data to get the Date_of_party_switch
data <- data %>%
  left_join(switch_rows, by = "Name", suffix = c("", "_switch"))

# Mark the rows to duplicate
data <- data %>%
  group_by(Name) %>%
  mutate(duplicated_row = ifelse(treated_dummy == 0 & lead(treated_dummy) == 1, 1, 0)) %>%
  ungroup()

# Duplicate the necessary rows
duplicated_data <- data %>%
  filter(duplicated_row == 1) %>%
  mutate(date = Date_of_party_switch, treated_dummy = 1) %>%
  select(-duplicated_row)

# Combine the original data with the duplicated rows
final_data <- bind_rows(data %>% select(-duplicated_row), duplicated_data) %>%
  arrange(Name, date)

# Print lines 6980 to 6986
print(final_data[6980:6986, ])

# Save the result to a new CSV file
write_csv(final_data, 'C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/RightDFWDATE.csv')



##########################################################################################

# Convert the date columns to Date type
final_data$date <- as.Date(final_data$date)
final_data$Date_of_party_switch <- as.Date(final_data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
final_data <- final_data %>%
  arrange(Name, date)

# Create the time_to_treatment column based on observation number
final_data <- final_data %>%
  group_by(Name) %>%
  mutate(time_to_treatment = ifelse(ever_treated == 0, 0, row_number() - which.max(treated_dummy == 1))) %>%
  ungroup()


########################################################################################################
library(fixest)


# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) | Name + date, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = final_data)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Event study: Staggered treatment (TWFE)')




############################################ left data



# Read the data
data <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/LeftDF.csv', show_col_types = FALSE)

# Convert the date columns to Date type
data$date <- as.Date(data$date)
data$Date_of_party_switch <- as.Date(data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
data <- data %>%
  arrange(Name, date)

# Identify the rows where treated_dummy changes from 0 to 1 and capture Date_of_party_switch
switch_rows <- data %>%
  group_by(Name) %>%
  mutate(lead_treated_dummy = lead(treated_dummy)) %>%
  filter(treated_dummy == 1 & lag(treated_dummy) == 0) %>%
  select(Name, Date_of_party_switch)

# Join the switch_rows back to the original data to get the Date_of_party_switch
data <- data %>%
  left_join(switch_rows, by = "Name", suffix = c("", "_switch"))

# Mark the rows to duplicate
data <- data %>%
  group_by(Name) %>%
  mutate(duplicated_row = ifelse(treated_dummy == 0 & lead(treated_dummy) == 1, 1, 0)) %>%
  ungroup()

# Duplicate the necessary rows
duplicated_data <- data %>%
  filter(duplicated_row == 1) %>%
  mutate(date = Date_of_party_switch, treated_dummy = 1) %>%
  select(-duplicated_row)

# Combine the original data with the duplicated rows
final_data <- bind_rows(data %>% select(-duplicated_row), duplicated_data) %>%
  arrange(Name, date)

# Print lines 6980 to 6986
print(final_data[6980:6986, ])

# Save the result to a new CSV file
write_csv(final_data, 'C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/LeftDFWDATE.csv')

# Re-read the final data to ensure it's properly formatted for the next steps
final_data <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/LeftDFWDATE.csv', show_col_types = FALSE)

# Convert the date columns to Date type
final_data$date <- as.Date(final_data$date)
final_data$Date_of_party_switch <- as.Date(final_data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
final_data <- final_data %>%
  arrange(Name, date)

# Create the time_to_treatment column based on observation number
final_data <- final_data %>%
  group_by(Name) %>%
  mutate(time_to_treatment = ifelse(ever_treated == 0, 0, row_number() - which.max(treated_dummy == 1))) %>%
  ungroup()

# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) | Name + date, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = final_data)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Event study: Staggered treatment (TWFE)')




################################################################### with controls and other stuff for right


# Re-read the final data to ensure it's properly formatted for the next steps
final_dataR <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/RightDFWDATE.csv', show_col_types = FALSE)

# Convert the date columns to Date type
final_dataR$date <- as.Date(final_dataR$date)
final_dataR$Date_of_party_switch <- as.Date(final_dataR$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
final_dataR <- final_dataR %>%
  arrange(Name, date)

# Create the time_to_treatment column based on observation number
final_dataR <- final_dataR %>%
  group_by(Name) %>%
  mutate(time_to_treatment = ifelse(ever_treated == 0, 0, row_number() - which.max(treated_dummy == 1))) %>%
  ungroup()

# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) | Name + date  + Country + State, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = final_dataR)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Impact of Switching Parties on Sentiment')



################################################################################ with controls and other stuff for left




# Re-read the final data to ensure it's properly formatted for the next steps
final_dataL <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/LeftDFWDATE.csv', show_col_types = FALSE)

# Convert the date columns to Date type
final_dataL$date <- as.Date(final_dataL$date)
final_dataL$Date_of_party_switch <- as.Date(final_dataL$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
final_dataL <- final_dataL %>%
  arrange(Name, date)

# Create the time_to_treatment column based on observation number
final_dataL <- final_dataL %>%
  group_by(Name) %>%
  mutate(time_to_treatment = ifelse(ever_treated == 0, 0, row_number() - which.max(treated_dummy == 1))) %>%
  ungroup()

# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) + word_count + Party Alignment | Name + date + Country + State, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = final_dataL)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Impact of Switching Parties on Sentiment')

####################################################################################################### Robustness checks 

# Filter out "Independent" from the "New_Party" column
filtered_data <- final_dataR %>%
  filter(New_Party != "Independent")

# Further filter to only include individuals with "ever_treated" = 1
treated_data <- filtered_data %>%
  filter(ever_treated == 1)

# Count unique individuals by "Name"
unique_people_count <- treated_data %>%
  distinct(Name) %>%
  summarise(count = n())

# Display the result
print(unique_people_count)




# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) + word_count + Party_Alignment | Name + date + Country + State, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = filtered_data)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Impact of Switching Parties on Sentiment')



#############

# Filter to only include individuals with "Independent" in the "New_Party" column
independent_data <- final_dataR %>%
  filter(New_Party == "Independent")

# Further filter to only include individuals with "ever_treated" = 1
treated_independent_data <- independent_data %>%
  filter(ever_treated == 1)

# Count unique individuals by "Name"
unique_people_count <- treated_independent_data %>%
  distinct(Name) %>%
  summarise(count = n())

# Display the result
print(unique_people_count)



# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1) + word_count + Party_Alignment | Name + date + Country + State, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = independent_data)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Impact of Switching Parties on Sentiment')


##############

data <- read_csv('C:/Users/Guill/OneDrive/Documents/School/Masters/Sem 3/Processed_FinalDF.csv', show_col_types = FALSE)

# Convert the date columns to Date type
data$date <- as.Date(data$date)
data$Date_of_party_switch <- as.Date(data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
data <- data %>%
  arrange(Name, date)

# Identify the rows where treated_dummy changes from 0 to 1 and capture Date_of_party_switch
switch_rows <- data %>%
  group_by(Name) %>%
  mutate(lead_treated_dummy = lead(treated_dummy)) %>%
  filter(treated_dummy == 1 & lag(treated_dummy) == 0) %>%
  select(Name, Date_of_party_switch)

# Join the switch_rows back to the original data to get the Date_of_party_switch
data <- data %>%
  left_join(switch_rows, by = "Name", suffix = c("", "_switch"))

# Mark the rows to duplicate
data <- data %>%
  group_by(Name) %>%
  mutate(duplicated_row = ifelse(treated_dummy == 0 & lead(treated_dummy) == 1, 1, 0)) %>%
  ungroup()

# Duplicate the necessary rows
duplicated_data <- data %>%
  filter(duplicated_row == 1) %>%
  mutate(date = Date_of_party_switch, treated_dummy = 1) %>%
  select(-duplicated_row)

# Combine the original data with the duplicated rows
final_data <- bind_rows(data %>% select(-duplicated_row), duplicated_data) %>%
  arrange(Name, date)

# Print lines 6980 to 6986
print(final_data[6980:6986, ])


# Convert the date columns to Date type
final_data$date <- as.Date(final_data$date)
final_data$Date_of_party_switch <- as.Date(final_data$Date_of_party_switch, format="%Y-%m-%d")

# Sort data by Name and date
final_data <- final_data %>%
  arrange(Name, date)

# Create the time_to_treatment column based on observation number
final_data <- final_data %>%
  group_by(Name) %>%
  mutate(time_to_treatment = ifelse(ever_treated == 0, 0, row_number() - which.max(treated_dummy == 1))) %>%
  ungroup()

# Filter for individuals whose alignment went from 1 to 2 or 4 to 3
alignment_filtered_data <- final_data %>%
  filter((Party_Alignment == 1 & New_Party_Alignment == 2) |
           (Party_Alignment == 4 & New_Party_Alignment == 3))

# Count unique individuals by "Name"
unique_people_count <- alignment_filtered_data %>%
  distinct(Name) %>%
  summarise(count = n())

# Display the result
print(unique_people_count)
# Further filter out individuals with "time_to_treat" of 5 or more
alignment_filtered_data <- alignment_filtered_data %>%
  filter(time_to_treatment < 5)
# Perform the staggered DiD analysis using fixest
mod_twfe <- feols(score ~ i(time_to_treatment, treated_dummy, ref = -1)  | Name + date + Country + State, # Fixed effects
                  cluster = ~Name,                                                   # Clustered SEs
                  data = alignment_filtered_data)

# Summary of the model
summary(mod_twfe)

# Plot the results
iplot(mod_twfe, 
      xlab = 'Time to treatment',
      main = 'Impact of Switching Parties on Sentiment')




################

# Calculate the row-by-row change in the score column for each individual
data <- final_data %>%
  group_by(Name) %>%
  arrange(date) %>% # Assuming "Time" indicates the order of the scores; adjust if necessary
  mutate(Score_Change = score - lag(score)) %>%
  filter(!is.na(Score_Change)) %>% # Remove the rows with NA changes (i.e., the first row of each group)
  ungroup()

# Group by "Name" and calculate the average change
average_change_per_person <- data %>%
  group_by(Name) %>%
  summarise(Average_Change = mean(Score_Change, na.rm = TRUE))

# Display the result
print(average_change_per_person)


overall_average <- mean(average_change_per_person$Average_Change, na.rm = TRUE)

# Display the result
print(overall_average)

std_dev <- sd(average_change_per_person$Average_Change, na.rm = TRUE)

# Calculate the sample size (number of individuals)
n <- nrow(average_change_per_person)

# Calculate the standard error
standard_error <- std_dev / sqrt(n)

# Display the result
print(standard_error)




# Load the dataset
data <- final_data

# Filter out individuals with treated_dummy = 1
data_filtered <- data %>%
  filter(treated_dummy != 1)

# Calculate the row-by-row change in the score column for each individual
data_filtered <- data_filtered %>%
  group_by(Name) %>%
  arrange(date) %>% # Assuming "date" indicates the order of the scores
  mutate(Score_Change = score - lag(score)) %>%
  filter(!is.na(Score_Change)) %>% # Remove the rows with NA changes (i.e., the first row of each group)
  ungroup()

# Group by "Name" and calculate the average change
average_change_per_person <- data_filtered %>%
  group_by(Name) %>%
  summarise(Average_Change = mean(Score_Change, na.rm = TRUE))

# Display the average change per person
print(average_change_per_person)

# Calculate the overall average of the individual averages
overall_average <- mean(average_change_per_person$Average_Change, na.rm = TRUE)

# Display the overall average
print(overall_average)

# Calculate the standard deviation of the average changes
std_dev <- sd(average_change_per_person$Average_Change, na.rm = TRUE)

# Calculate the sample size (number of individuals)
n <- nrow(average_change_per_person)

# Calculate the standard error
standard_error <- std_dev / sqrt(n)

# Display the standard error
print(standard_error)



