#
# Appendix 


## Install package
install.packages("devtools")         ## needed to install from github
library("devtools")                  ## load devtools
install_github("boost-R/mboost")     ## install newest mboost version
install_github("boost-R/gamboostLSS")## install newest gamboostLSS version
install_github("boost-R/betaboost")  ## install betaboost
library("betaboost")                 ## load betaboost

#-------------------------------------------------------------------
## Quality of life data
## load data
data("dataqol2", package = "QoLR")
## take one time-point
dataqol <- dataqol2[dataqol2$time ==0,]
## remove missings
dataqol <- dataqol[complete.cases(dataqol[,c("QoL", "arm", "pain")]),]
## transfer to [0,1]
dataqol <- dataqol/100

## Outcome
#pdf("Qol_outcome.pdf", width = 7, height = 5)
#par(mar = c(3,3,1,1))
hist(dataqol$QoL, breaks = 20, col = "lightgrey", 
     main = "Quality of life", prob = TRUE, las = 1)
lines(density(dataqol$QoL), col = 2, lwd = 2)
#dev.off()

## Explanatory variable treatment arm

#pdf("boxplot_arm.pdf", width = 5, height = 5)
#par(mar = c(3,5,1,1))
boxplot(QoL ~ arm, data = dataqol, names = c("A","B"), las = 1,
        col = "lightgrey", ylab = "Qualitiy of life")
#dev.off()

## Explanatory variable pain

#pdf("plot_pain.pdf", width = 7, height = 5)
#par(mar = c(4,5,0.5,0.5))
plot(QoL ~ pain, data = dataqol, pch = 19, las = 1)
#dev.off()

## fit classical beta regression, linear effects
beta1 <- betaboost(QoL ~ pain + arm, data = dataqol)
coef(beta1, off2int = TRUE)

## the precission parameter is treated as nuissance
nuisance(beta1)

## now with smooth effect for pain
beta2 <- betaboost(QoL ~ s(pain) + arm, data = dataqol, 
                   form.type = "classic")

## plot partial smooth effect
#pdf("partial_pain.pdf", width = 7, height = 5)
#par(mar = c(4,5,0.5,0.5))
plot(beta2, which = "pain")
#dev.off()

## optimize number of boosting iterations (takes a few seconds)
set.seed(1234)
cvr <- cvrisk(beta2)
mstop(cvr)

#pdf("plot_cvr.pdf", width = 7, height = 5)
#par(mar = c(5,5,0.5,0.5))
plot(cvr)
#dev.off()

## set to optimal stopping iterations
mstop(beta2) <- mstop(cvr)

## pain no longer selected
coef(beta2)

## now extended beta regression
beta3 <- betaboost(QoL ~ arm + pain, 
                   phi.formula = QoL ~ arm + pain, 
                   data = dataqol)
coef(beta3, off2int = TRUE)

## the same with smooth effects for pain
beta4 <- betaboost(QoL ~ arm + s(pain), 
                   phi.formula = QoL ~ arm + s(pain),
                   data = dataqol, form.type = "classic")

par(mfrow = c(1,2))
plot(beta4, which =  "pain")

# compare R^2

## compare R^2 measures

cbind("lin" = R2.betaboost(beta1, data = dataqol), 
      "smooth" = R2.betaboost(beta2[100], data = dataqol),
      "ext. lin" = R2.betaboost(beta3, data = dataqol),
      "ext. smooth" = R2.betaboost(beta4, data = dataqol))

##------------------------------------

## load betareg and data
library(betareg)
data(FoodExpenditure)

## standard model with betareg
beta1 <- betareg(I(food/income) ~ income + persons, 
                 data = FoodExpenditure)


## now with betaboost
beta2 <- betaboost(I(food/income) ~ income + persons, 
                   data = FoodExpenditure)


## compare both methods
rbind("betareg" = coef(beta1), 
      "betaboost" = c(coef(beta2, off2int = TRUE), 
                      nuisance(beta2)))

#(Intercept)      income   persons    (phi)
#betareg    -0.6225481 -0.01229884 0.1184621 35.60975
#betaboost  -0.6203121 -0.01167270 0.1113287 35.23329

## minor differences -> more iterations
mstop(beta2) <- 500

## compare again
rbind("betareg" = coef(beta1), 
      "betaboost" = c(coef(beta2, off2int = TRUE), 
                      nuisance(beta2)))

#(Intercept)      income   persons    (phi)
#betareg    -0.6225481 -0.01229884 0.1184621 35.60975
#betaboost  -0.6225479 -0.01229870 0.1184606 35.60968          

## converges to same results
plot(beta2, off2int = TRUE, main = "boosting")


