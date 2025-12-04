library(httr)
library(tidyverse)
library(lubridate)

base <- "http://127.0.0.1:8000"

test <- read.csv("test_dataset.csv.gz") %>%
  mutate(
    appt_time = as_datetime(appt_time),
    appt_made = as_datetime(appt_made),
    days_wait = as.numeric(difftime(appt_time, appt_made, units = "days"))
  )

newdata <- test

## ---- Predict Probabilities ----
resp_prob <- POST(
  url = paste0(base, "/predict_prob"),
  body = serialize(newdata, NULL),
  content_type("application/rds")
)

p <- content(resp_prob, "raw") |>
  unserialize()
head(p, 10)
## ---- Predict Classes ----
resp_class <- POST(
  url = paste0(base, "/predict_class"),
  body = serialize(newdata, NULL),
  content_type("application/rds")
)

p <- content(resp_class, "raw") |>
  unserialize()
head(p,10)
