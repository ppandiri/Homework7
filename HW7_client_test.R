## Write your client test code here
## HW7_client_test.R

library(httr)
library(tidyverse)
library(lubridate)

base <- "http://127.0.0.1:8000"

test <- read.csv("test_dataset.csv.gz")

test <- test %>%
  mutate(days_wait = as.numeric(difftime(appt_time, appt_made, units = "days")))

cols <- c("days_wait", "address", "specialty", "provider_id", "age")
newdata <- as.data.frame(test[1:5, cols])

raw_input <- serialize(newdata, NULL)

# ---- predict_prob ----
resp_prob <- POST(
  url = paste0(base, "/predict_prob"),
  body = raw_input,
  add_headers("Content-Type" = "application/octet-stream")
)

prob_vec <- unserialize(content(resp_prob, "raw"))
cat("Probabilities:\n")
print(prob_vec)

# ---- predict_class ----
resp_class <- POST(
  url = paste0(base, "/predict_class"),
  body = raw_input,
  add_headers("Content-Type" = "application/octet-stream")
)

class_vec <- unserialize(content(resp_class, "raw"))
cat("\nClasses:\n")
print(class_vec)
