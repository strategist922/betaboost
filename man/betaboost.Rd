\name{betaboost}
\alias{betaboost}
\title{
Function for boosting beta regression
}
\description{
Wrapper function to use mode-based boosting via mboost or gamboostLSS to fit BetaRegression.
}
\usage{
betaboost(formula, data = list(), iterations = 100)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
description of the model to be fit.
}
  \item{data}{
a data frame containing the variables.
}
  \item{iterations}{
number of boosting iterations to be used.
}

}
\details{
A wrapper function...
}
\value{
A boosting object
}
\references{
Schmid, M., Wickler, F., Maloney, K. O., Mitchell, R., Fenske, N., & Mayr, A. (2013). Boosted beta regression. PLoS ONE, 8(4), e61623.
}
\seealso{
\code{\link{glmboost}}
}
\examples{

require(gamlss.dist)
# simple simulated example
set.seed(1234)
x1 <- rnorm(100)
x2 <- rnorm(100)
x3 <- rnorm(100)
x4 <- rnorm(100)
y <- rBE(n = 100, mu = plogis(x1 +x2),
                  sigma = plogis(x3 + x4))
data <- data.frame(y ,x1, x2, x3, x4)
data <- data[!data$y%in%c(0,1),]

betaboost(formula = y~ x1 + x2, data = data,
          iterations = 120)

}