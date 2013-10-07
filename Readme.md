Movie DataSet
=============

Set of programs to generate movie dataset similar to that of movie streaming sites.

**DataSet**: The generated dataset will be of the form

```
cid, cname, active?, ts, pt, rating, mid, mname, mrdate, mrtime, genre
```

| column | Description |
| ------ | ----------- |
| *cid* | id of the customer |
| *cname* | name of the customer |
| *active?* | specfies whether a customer is active or inactive (0 specifies active user and 1 specifies the user is inactive) |
| *ts* | timestamp at which the user watched a movie/show |
| *pt* | time at which the user paused the movie (0 specifies the user has watched entire movie, else specifies the minute at which user paused the movie for watching it later) |
| *rating* | rating user gave for the movie (possible values: 5-0, -1 being user has not rated the movie) |
| *mid* | id of the movie the user watched |
| *mname* | name of the movie user watched |
| *mrdate* | data at which movie was released |
| *mrtime* | run time of the movie in minutes |
| *genre* | movie genre |

Generating the dataset:
-----------------------

```
ruby generator.rb
```

This program generates data @ rate of ~ 1 Mbps