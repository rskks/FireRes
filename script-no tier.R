# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(combinat)
library(writexl)

# Read the Excel file
df <- read_excel("input-prebis.xlsx")

# Convert columns to appropriate data types
df <- df %>%
  mutate(
    Slot = as.factor(Slot),
    Item = as.character(Item),
    ShadowEP = as.numeric(ShadowEP),
    FireRes = as.numeric(FireRes),
    Tier = as.factor(Tier)
  )

df <- df[c(1:3,6,10)]  # Filter the necessary columns

# Function to find valid combinations without Tier constraint
get_valid_combinations <- function(df) {
  # Split data by Slot
  slots <- split(df, df$Slot)
  
  # Initialize a list to store valid combinations
  valid_combinations <- list()
  
  # Generate combinations
  combn_helper <- function(slot_lists, current_comb = data.frame(), depth = 1) {
    if (depth > length(slot_lists)) {
      # Add the current combination to the list of valid combinations
      valid_combinations <<- append(valid_combinations, list(current_comb))
      return()
    }
    
    # Iterate through items in the current slot
    for (i in 1:nrow(slot_lists[[depth]])) {
      combn_helper(slot_lists, rbind(current_comb, slot_lists[[depth]][i, ]), depth + 1)
    }
  }
  
  # Start the recursive combination generation
  combn_helper(slots)
  
  return(valid_combinations)
}

# Get valid combinations
valid_combinations <- get_valid_combinations(df)

# Print valid combinations
# print(valid_combinations)

# Function to filter combinations based on Fire Res values
filter_combinations_by_fire_res <- function(combinations, X) {
  filtered_combinations <- list()
  
  for (comb in combinations) {
    # Check the structure and summary of the combination
    #print(str(comb))
    #print(summary(comb$FireRes))
    
    # Ensure FireRes is numeric
    comb$FireRes <- as.numeric(comb$FireRes)
    
    # Calculate the sum of FireRes, ignoring NA values
    fire_res_sum <- sum(comb$FireRes, na.rm = TRUE)
    
    # Print the sum for debugging
    #print(paste("Fire Res Sum:", fire_res_sum))
    
    # Check if the sum falls within the specified range
    if (!is.na(fire_res_sum) && !is.null(fire_res_sum) && fire_res_sum >= X && fire_res_sum <= X + 15) {
      filtered_combinations <- append(filtered_combinations, list(comb))
    } else {
      #print(paste("Filtered out - Fire Res Sum:", fire_res_sum, "Not in range"))
    }
  }
  
  return(filtered_combinations)
}


# Function to get top combinations based on ShadowEP
get_top_combinations_by_shadow_ep <- function(combinations, top_n = 250) {
  # Calculate the sum of ShadowEP and FireRes for each combination
  combinations_with_totals <- lapply(combinations, function(comb) {
    total_shadow_ep <- sum(comb$ShadowEP)
    total_fire_res <- sum(comb$FireRes)
    comb$total_shadow_ep <- total_shadow_ep
    comb$total_fire_res <- total_fire_res
    return(comb)
  })
  
  # Convert list to data frame for sorting
  combinations_with_totals_df <- do.call(rbind, lapply(combinations_with_totals, function(comb) {
    data.frame(
      Slot = comb$Slot,
      Item = comb$Item,
      ShadowEP = comb$ShadowEP,
      FireRes = comb$FireRes,
      Tier = comb$Tier,
      total_shadow_ep = comb$total_shadow_ep,
      total_fire_res = comb$total_fire_res,
      stringsAsFactors = FALSE
    )
  }))
  
  # Ensure the total_shadow_ep column is numeric
  combinations_with_totals_df$total_shadow_ep <- as.numeric(combinations_with_totals_df$total_shadow_ep)
  
  # Sort combinations by total ShadowEP in descending order
  sorted_combinations_df <- combinations_with_totals_df[order(combinations_with_totals_df$total_shadow_ep, decreasing = TRUE), ]
  
  # Extract top N combinations
  top_combinations_df <- head(sorted_combinations_df, top_n)
  
  # Convert back to list of data frames
  top_combinations <- split(top_combinations_df, seq(nrow(top_combinations_df)))
  
  # Print the structure of top combinations for debugging
  print(lapply(top_combinations, str))
  
  return(top_combinations)
}

# Create a new data frame from top_combinations
create_summary_df <- function(top_combinations) {
  # Initialize an empty list to store data
  summary_list <- list()
  
  # Initialize the combination number
  comb_number <- 1
  
  # Loop through top_combinations and extract the required information
  for (i in seq_along(top_combinations)) {
    comb <- top_combinations[[i]]
    
    # Extract current combination's total ShadowEP and FireRes
    current_shadow_ep <- comb$total_shadow_ep
    current_fire_res <- comb$total_fire_res
    
    # For the first combination, we don't need to check the previous values
    if (i > 1) {
      prev_comb <- top_combinations[[i - 1]]
      prev_shadow_ep <- prev_comb$total_shadow_ep
      prev_fire_res <- prev_comb$total_fire_res
      
      # Check if both total ShadowEP and total FireRes are different from the previous combination
      if (current_shadow_ep != prev_shadow_ep || current_fire_res != prev_fire_res) {
        comb_number <- comb_number + 1
      }
    }
    
    # Stop if comb_number exceeds 11
    if (comb_number > 10) break
    
    # Create a data frame for each combination
    comb_df <- data.frame(
      CombinationNumber = comb_number,
      Slot = comb$Slot,
      Item = comb$Item,
      TotalShadowEP = comb$total_shadow_ep,
      TotalFireRes = comb$total_fire_res,
      stringsAsFactors = FALSE
    )
    
    # Append to the summary list
    summary_list[[i]] <- comb_df
  }
  
  # Combine all data frames in the summary list into a single data frame
  summary_df <- do.call(rbind, summary_list)
  
  return(summary_df)
}
#Reminder: You have 27 Fire Res from 4 Tierpiece gear, 60(75) from Enchants, and 27 from MotW. 
#H2: 96 (69, 9 with three ez ench)
#H3: 226 (199, 139 with three ez ench | Juju MR pot 161 - Enchants 101 - AD 96)
# User input for the numeric value X
X <- as.numeric(readline(prompt = "Enter the numeric value for X: "))

# Filter valid combinations by Fire Res values
filtered_combinations <- filter_combinations_by_fire_res(valid_combinations, X)

# Get top combinations by ShadowEP
top_combinations <- get_top_combinations_by_shadow_ep(filtered_combinations)

# Example usage
summary_df <- create_summary_df(top_combinations)
View(summary_df)

# Write summary_df to an Excel file
write_xlsx(summary_df, "summary_h2flrcr.xlsx")
# Print top combinations
#print(top_combinations)