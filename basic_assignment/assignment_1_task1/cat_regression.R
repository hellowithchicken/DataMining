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
ind = sample(2, nrow(spotify_songs), replace=TRUE, prob=c(0.7,0.3))
trainData = spotify_songs[ind==1,]
testData = spotify_songs[ind==2,]









