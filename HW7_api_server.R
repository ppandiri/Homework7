library(plumber2)
library(tidyverse)
library(lubridate)
library(readr)

train <- read.csv("train_dataset.csv.gz") |>
  mutate(
    appt_time = as_datetime(appt_time),
    appt_made = as_datetime(appt_made),
    days_wait = as.numeric(difftime(appt_time, appt_made, units = "days"))
  )

model <- glm(
  no_show ~ days_wait + address + specialty + provider_id + age,
  data   = train,
  family = "binomial"
)

#* @post /predict_prob
#* @parser rds
#* @serializer rds
predict_prob <- function(body) {
  df <- as.data.frame(body)
  df$days_wait <- as.numeric(df$days_wait)
  df$age       <- as.numeric(df$age)
  preds <- predict(model, newdata = df, type = "response")
  as.numeric(preds)
}


#* @post /predict_class
#* @parser rds
#* @serializer rds
function(body) {
  df <- as.data.frame(body)
  df$days_wait <- as.numeric(df$days_wait)
  df$age       <- as.numeric(df$age)
  probs <- predict(model, newdata=df, type="response")
  as.integer(probs > 0.5)
}
