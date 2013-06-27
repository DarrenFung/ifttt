# Free Responses:

## Question 1:


# Project Notes:

To run the app, make sure you have Redis installed. The app expects Redis to be used on the default port, and the `redis-server` executable in the PATH.

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
