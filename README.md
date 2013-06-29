# Free Responses:

## Question 1:

If I had my bills paid for a year, I would like to experiment with two different programming projects. Aviation has always been a passion of mine, so my first project would be more of an experimentation of what I can do with flight data. It would be less of a useful product for consumers, but more of a way for me to experiment with data, and see what new views of the data I can generate. For example, I would like to see how I could use historical data on arrival/departure times of airplanes into useful data.

My second project would be something mobile. I've only had a little experience with iOS and Android, and I'd like to immerse myself into the mobile app development world and see what I can come up with. A project I had in mind would be an easy way for people to organize poker games (think boys night), as I always saw the problem of people not having enough cash for a cash game because poker games are usually spontaneous affairs.

Question 2:

A non programming project that I would like to do is work on my photography. Hiking is one of my favourite hobbies, and I'd love to combine photography and hiking to compile photos of the best hiking spots in the world.

As well, if I had a house or condo or apartment, a project that I would like to do (though it does involve a bit of programming) is to fully outfit the house with automated switches and sensors (e.g. automatic light switches, automatic garage door opener, etc). Then, I'd connect these nodes together to a server and try to make the house as automated as possible.

# Project Notes:

## Starting the App

Dependencies:
1. SQLite
2. Redis

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

The app is set up to send the emails every Friday at 5:00pm, but if you want to manually send them, enter the Rails console `rails c`, and then type `PairMaker.new.get_pairs`

## Design Decisions:

I chose to use Redis as my app does a lot of set and list manipulations. As the primary data store, I use SQLite for its simplicity.

I made some assumptions about the constraints. They're meant to follow how I would pair up people in the same scenario. For example, if we have two teams with an odd number of team members, I wouldn't want the two non-teammates to be alone for the week. Thus, in scenarios like that, the non-teammates will be paired up so as to more closely follow constraint #1 (Every person in the organization should participate in a 1+1 pair each week.).


## Testing

The service that creates the pairing is tested with RSpec. I did not see a reason to test the front end, as it was mainly Rails scaffolding with a bit of Bootstrap fluff.

As well, a bit of manual testing was done at a glance to see that the service works.
