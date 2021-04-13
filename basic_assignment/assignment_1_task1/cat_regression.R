# loading data
spotify_songs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv')
summary(spotify_songs)

hist(spotify_songs$track_popularity)
qqnorm(spotify_songs$track_popularity[spotify_songs$track_popularity!=0])
qqline(spotify_songs$track_popularity[spotify_songs$track_popularity!=0])

fit1 <- lm(track_popularity~playlist_genre+
            danceability+energy+key+loudness+mode+speechiness+acousticness+instrumentalness+
            liveness+valence+tempo+duration_ms, data=spotify_songs)
summary(fit1)

fit2 <- lm(track_popularity~playlist_genre+
             danceability+energy+key+loudness+speechiness+acousticness+instrumentalness+
             liveness+valence+tempo+duration_ms, data=spotify_songs)
summary(fit2)


fit3 <- lm(track_popularity~playlist_genre+
             danceability+energy+loudness+speechiness+acousticness+instrumentalness+
             liveness+valence+tempo+duration_ms, data=spotify_songs)
summary(fit3)

fit4 <- lm(track_popularity~playlist_genre+
             danceability+energy+loudness+speechiness+acousticness+instrumentalness+
             liveness+tempo+duration_ms, data=spotify_songs)
summary(fit4)

fit5 <- lm(track_popularity~playlist_genre+
             danceability+energy+loudness+acousticness+instrumentalness+
             liveness+tempo+duration_ms, data=spotify_songs)
summary(fit5)
plot(fitted(fit5), spotify_songs$track_popularity)
abline(a,b, col="red")


# split dataset
library(caret)

indxTrain <- createDataPartition(y = spotify_songs$track_popularity, p = 0.6, list = FALSE)
training <- spotify_songs[indxTrain,]
testing <- spotify_songs[-indxTrain,]
par(mfrow=c(3,1))
hist(training$track_popularity, prob=T)
hist(testing$track_popularity, prob=T)
hist(spotify_songs$track_popularity, prob=T)
par(mfrow=c(1,1))

fit <- lm(track_popularity~playlist_genre+
             danceability+energy+loudness+acousticness+instrumentalness+
             liveness+tempo+duration_ms, data=training)
pred <- predict(fit, newdata=testing)
sqrt(mean((pred-testing$track_popularity)^2))
plot(pred)
points(testing$track_popularity, col=2)


##### 
library(rstudioapi)
# https://www.kaggle.com/mustafaali96/weight-height
setwd(dirname(getActiveDocumentContext()$path))
data <- read.csv2("weight-height.csv", sep=",")
head(data)
summary(data)
fit <- lm(as.double(data$Height)~as.double(data$Weight)+data$Gender)
summary(fit)
p <- predict(fit)

mean((p-as.double(data$Height))^2)
mean(abs(p-as.double(data$Height)))

hist(as.double(data$Height))
mean(as.double(data$Height))
median(as.double(data$Height))

