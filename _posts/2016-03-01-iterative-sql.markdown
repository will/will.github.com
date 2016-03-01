---
title: Iterative approach to writing SQL in Postgres
layout: post
category: blog
---

Let's look at building a somewhat complex Postgres SQL query step-by-step.
This query uses some cool features like `generate_series`, common table
expressions ("with" queries), and several date functions.

This is a [reporting query][query] on an internal, [open source][gh] app to
track guests in the office and help plan catering I wrote and maintained while
I was still at Heroku. Being on the Heroku Postgres team for the last five
years has somewhat warped my sensibilities; the entire application is mostly
just 4-5 SQL queries wrapped up in Sinatra.

[gh]: https://github.com/heroku/reception
[query]: https://github.com/heroku/reception/blob/master/web.rb#L149

### Background

In the beginning, [the schema][schema] was pretty simple. There was only a
single table, `guests`:

``` sql
create table guests (
  id               uuid          primary key default uuid_generate_v4(),
  guest_name       text          not null        ,
  herokai_name     text          not null        ,
  lunch            boolean       default false   ,
  nda              boolean       default false   ,
  notify_hipchat   boolean       default false   ,
  notify_gchat     boolean       default false   ,
  notify_sms       text                          ,
  notes            text                          ,
  created_at       timestamptz   default now()   ,
  visiting_range   daterange     not null
);

create index visitng_range_gist on guests using gist(visiting_range);
```

There isn't anything particularly advanced going on there, except perhaps the
`daterange` column type. [Range Types][range] were added in the 2012 release of
Postgres 9.2. Sometimes guests visit for several consecutive days, and the
ability to express that in a single column is convenient. The type also
supports a special kind of index, [GiST][gist]. We use it for extremely fast
lookups based on if the range includes a given date, though it has other uses.

[schema]: https://github.com/heroku/reception/blob/master/schema.sql
[range]: http://www.postgresql.org/docs/current/static/rangetypes.html
[gist]: https://en.wikipedia.org/wiki/GiST

### Iteration 1: the beginning

The first thing we want to know is how many people come to the office each
month, and how many come for lunch. We have the `boolean` if they were signed
up for lunch, and we have the range they visited on, but we can't just
`group by` the range.

Instead we start building a table of dates starting from the first day of the
month the system went into production until a few months in the future.
`generate_series` is what's called a [set returning function][set], and it does
exactly what we need.

The use of `::interval` here is worth pointing out. Postgres is powerful enough
to deal with the varying amount of days in months and apply that statement
correctly, so it will always be the last day of whichever month is three months
from now.

``` sql
select *
from generate_series(
  '2013-09-01',
  date_trunc('month', now()) + '3 months - 1 day'::interval,
  '1 day') as v;

v
------------------------
2013-09-01 00:00:00-07
2013-09-02 00:00:00-07
2013-09-03 00:00:00-07
...
2015-11-30 00:00:00-08
(821 rows)
```

Next, we add a `left outer join` on the real `guests` table. We use an outer
join because otherwise a normal join would exclude days with zero guests. The
`<@` operator means 'contained by', so for each day, we're joining in all the
guests whose visiting range contains that day.

``` sql
select *
from generate_series(
  '2013-09-01',
  date_trunc('month', now()) + '3 months - 1 day'::interval,
  '1 day') as v
left outer join guests on v::date <@ visiting_range;
```

What we have at this point is at least one row per day, and one row for each
day a guest is visiting. With that, we can do group by the day start counting
the things we're looking for.

`count(expression)` gives the number of rows where *expression* is not `null`.
This works well for the total number of guests, because the outer join gives us
`null`s when there aren't any guests. It's a little tricker for the `boolean`
lunch column, since `false` values still get counted. Fortunately Postgres
gives us `nullif` which, well, does what it says.

``` sql
select
  v::date as visiting_on,
  count(visiting_range) as total,
  count(nullif(lunch, false)) as lunch
from generate_series(
  '2013-09-01',
  date_trunc('month', now()) + '3 months - 1 day'::interval,
  '1 day') as v
left outer join guests on v::date <@ visiting_range
group by 1
order by 1;

 visiting_on | total | lunch
-------------+-------+-------
 ...
 2013-09-23  |     3 |     1
 2013-09-24  |     0 |     0
 2013-09-25  |     1 |     1
 2013-09-26  |     0 |     0
 2013-09-27  |     0 |     0
 ...
```

We're almost there. What we need next is to group again by month, and add up
all the values. There are a few ways to do this, but I think ["with"
queries][cte] are best because they're much easier to work with, and understand
again in the future.  In fact, this query is over [a year and a half
old][commit1], but is still pretty easy to understand.

We wrap the previous query inside the CTE, and then group by
`date_trunc('month', visiting_on)` which makes it so all dates in the same
month are the same. Also, it's nice that the `Month` format to `to_char` pads
shorter month names with spaces so all the years line up.

``` sql
with counts_by_day as (
  select
  v::date as visiting_on,
    count(visiting_range) as total,
    count(nullif(lunch, false)) as lunch
  from generate_series(
    '2013-09-01',
    date_trunc('month', now()) + '3 months - 1 day'::interval,
    '1 day') as v
  left outer join guests on v::date <@ visiting_range
  group by 1
)

select
  to_char(date_trunc('month', visiting_on), 'Month YYYY') as month,
  sum(total) as total,
  sum(lunch) as lunch
from counts_by_day
group by date_trunc('month', visiting_on)
order by date_trunc('month', visiting_on) asc;

     month      | total | lunch
----------------+-------+-------
 September 2013 |     4 |     2
 October   2013 |   116 |    61
 November  2013 |   117 |    76
 ...
```

And there you have it. We've solved what we set out to do. Up next is dealing
with an oversight in the query and adding more information as the system grows.

[set]: http://www.postgresql.org/docs/current/static/functions-srf.html
[commit1]: https://github.com/heroku/reception/commit/cafe6deeea4f9146258feeb3216bae041ee51ccb
[cte]: http://www.postgresql.org/docs/current/static/queries-with.html

### Iteration 2: the bug

What we had seemed to work well, but there was one oversight. It turned out
that sometimes a visit would span a weekend, and because this query joins in
every day of visit, weekends were being counted.

We need to find some way to exclude Saturday and Sunday. I don't know a way to
do this off the top of my head, but a good place to look is the [Date/Time
  Functions and Operators][dtfao] page.

There we find that `EXTRACT` has a `dow` option that gives "the day of the week
as Sunday (0) to Saturday (6)". That looks pretty good, but looking a bit more
we find `isodow` which goes from "Monday (1) to Sunday (7)". Even better, now
the two things we need to exclude are next to each other.

And with that, we can [add a single line][commit2] to the `counts_by_day` CTE:

``` diff
    left outer join guests on v::date <@ visiting_range
+   where extract(isodow from v) < 6 -- only Monday-Friday
    group by 1
```

[dtfao]: http://www.postgresql.org/docs/current/static/functions-datetime.html
[commit2]: https://github.com/heroku/reception/commit/cafe774970f47c50cfa55a254b640fcf1f1dd71f:w

### Iteration 3: new features

Some time later the system grew the ability to track which guests actually
check in and when. That table looks like this:

``` sql
create table checkins (
  id         uuid        primary key default uuid_generate_v4(),
  guest_id   uuid        not null,
  created_at timestamptz not null default now()
);
create index on checkins(guest_id);
```

This allows each day a guest comes out of their range to be accounted for
individually, just by adding a row. As an aside, this is the second time we've
seen a table with a `timestamptz` column. **Always** use `timestamptz`. Look at
your database right now and change any `timestamp` columns to `timestamptz`.

Now, we already know how many people were supposed to show up each month, but
how does that compare to those who actually do?

We need to join in the checkins not only on the `guest_id` but also when the
day parts match up. `date_trunc('day', date)` will do that for us. Again we
want a left outer join.

Counting is a little tricker than before. Total checkins isn't so bad, just
count on the `id` column since it will be nil on no checkin due to the outer
join. But for checkins and lunch, we need to do a bit more work. `lunch and
checkins.id is not null` will only be `true` when `lunch` is true and when the
join matched. All other cases will either be `false` or `null`, and we use
`nullif` again to make those `false`s become `null` so they're not counted.

The change to the outer query is pretty simple, just two new sums in the select
list.

``` diff
with counts_by_day as (
    select
    v::date as visiting_on,
      count(visiting_range) as total,
      count(nullif(lunch, false)) as lunch,
+     count(checkins.id) as checkins,
+     count(nullif(lunch and checkins.id is not null, false) ) as checklunch
    from generate_series(
      '2013-09-01',
      date_trunc('month', now()) + '3 months - 1 day'::interval,
      '1 day') as v
    left outer join guests on v::date <@ visiting_range
+   left outer join checkins on date_trunc('day', v::date) = date_trunc('day', checkins.created_at) and guests.id=checkins.guest_id
    where extract(isodow from v) < 6
    group by 1
  )
  select
    to_char(date_trunc('month', visiting_on), 'Month YYYY') as month,
    sum(total) as total,
    sum(lunch) as lunch,
+   sum(checkins) as checkins,
+   sum(checkinslunch) as checkinslunch
  from counts_by_day
  group by date_trunc('month', visiting_on)
  order by date_trunc('month', visiting_on) asc;
```

And there we go. While this query can seem a bit daunting at first, seeing it
put together step-by-step makes it easier to understand. I hope some of these
ideas are useful the next time you have to write a query.

