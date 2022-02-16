
library(tidyverse)
library(survey)
library(sampling)
library(dplyr)
library(ggplot2)
library(broom)

heartd<-read.csv("./heart_data.csv", sep=",")

heartd <- heartd  %>% mutate(
  hd = ifelse(class >  0, 1,0))

heartd <- heartd %>% mutate(sex = factor(sex, levels = 0:1, labels = c("Female","Male")))



chisq.test(heartd$sex, heartd$hd, correct = TRUE)
t.test(heartd$age ~ heartd$hd)

t.test(heartd$thalach ~ heartd$hd)

heartd2 <- heartd %>% mutate(
  hd = ifelse(hd ==  0, "No disease", "Disease"))


boxplot(heartd2$age~heartd2$hd,xlab = "Diagnostic",  # Etiqueta eje X
        ylab = "Age",  # Etiqueta eje Y
        main = "Disease per age")

ggplot(heartd2, aes(hd,fill = sex)) + geom_bar(position = 'fill') + 
  labs(title='Sex per Diagnostic ',x='Diagnostic',y='Percentage')



str(heartd)

model<-glm(data= heartd, hd~age+sex+thalach  ,family="binomial")

summary(model)



# tidy up the coefficient table
tidy_m <- model %>% tidy()
tidy_m
#
#  # calculate OR
tidy_m$OR <- exp(tidy_m$estimate)
#
#  # calculate 95% CI and save as lower CI and upper CI
tidy_m$lower_CI <- exp(tidy_m$estimate - 1.96 * tidy_m$std.error)
tidy_m$upper_CI <- exp(tidy_m$estimate + 1.96 * tidy_m$std.error)
#
#
#
#  # get the predicted probability in our dataset using the predict() function
pred_prob <- predict(model, heartd, type = "response")
#
#  # create a decision rule using probability 0.5 as cutoff and save the predicted decision into the main data frame
heartd$pred_hd <- ifelse(pred_prob>=.5,1,0)
#
#  # create a newdata data frame to save a new case information
newdata <- data.frame(age=60 , sex="Male", thalach=120)

#
#  # predict probability for this new case and print out the predicted value
p_new <- predict(model, newdata, type = "response")

pheart_risk<-p_new*100

pheart_risk