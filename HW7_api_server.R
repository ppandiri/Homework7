## HW7_api_server.R

library(plumber)
library(tidyverse)

train <- read.csv("train_dataset.csv.gz")

train <- train %>%
  mutate(days_wait = as.numeric(difftime(appt_time, appt_made, units = "days")))

model <- glm(
  no_show ~ days_wait + address + specialty + provider_id + age,
  data = train,
  family = binomial(link = "logit")
)

#* @serializer contentType list(type="application/octet-stream")
#* @post /predict_prob
function(req){
  df <- unserialize(req$body)
  probs <- predict(model, newdata = df, type = "response")
  serialize(as.numeric(probs), NULL)
}

#* @serializer contentType list(type="application/octet-stream")
#* @post /predict_class
function(req){
  df <- unserialize(req$body)
  p <- predict(model, newdata = df, type = "response")
  classes <- as.integer(ifelse(p > 0.5, 1L, 0L))
  serialize(classes, NULL)
}
