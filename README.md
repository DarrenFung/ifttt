# Free Responses:

## Question 1:

If I had my bills paid for a year, I would like to experiment with two different programming projects. Aviation has always been a passion of mine, so my first project would be more of an experimentation of what I can do with flight data. It would be less of a useful product for consumers, but more of a way for me to experiment with data, and see what new views of the data I can generate. For example, I would like to see how I could use historical data on arrival/departure times of airplanes into useful data.

My second project would be something mobile. I've only had a little experience with iOS and Android, and I'd like to immerse myself into the mobile app development world and see what I can come up with. A project I had in mind would be an easy way for people to organize poker games (think boys night), as I always saw the problem of people not having enough cash for a cash game because poker games are usually spontaneous affairs.

Question 2:

A non programming project that I would like to do is work on my photography. Hiking is one of my favourite hobbies, and I'd love to combine photography and hiking to compile photos of the best hiking spots in the world.

As well, if I had a house or condo or apartment, a project that I would like to do (though it does involve a bit of programming) is to fully outfit the house with automated switches and sensors (e.g. automatic light switches, automatic garage door opener, etc). Then, I'd connect these nodes together to a server and try to make the house as automated as possible.

# Project Notes:

Dependencies:
SQLite
Redis

The app expects Redis to be used on the default port, and the `redis-server` executable in the PATH.

In the root directory, type `bundle install` to install all the dependencies.

Then, setup the database:

```
rake db:create
rake db:schema:load
```

If you want to seed the database with the data from the problem specifications, run:

```
rake db:seed
```

Then, start the app: `foreman start -f Procfile`
