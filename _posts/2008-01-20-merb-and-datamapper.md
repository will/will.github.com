---
title:      Merb and Datamapper
created_at: 2008-01-20 01:30:11.614269 -05:00
layout: post
category: blog
---
With the recent release of [Merb 0.5](http://merbivore.com), I've decided to use it along with [datamapper](http://datamapper.org) for one of my new projects. It isn't different enough to be completely foreign, but enough to be a refreshing change. I haven't done a whole lot with either yet, but I have had a patch accepted, ran into a huge, annoying problem with autotest, and found out how to watch the SQL datamaper is generating.

stats patch
---------------
While I was in #merb earlier today, [hassox](http://hassox.blogspot.com/) posted some [current benchmarks](http://pastie.caboo.se/136989). Being somewhat a stickler for statistics, I had to point out that means alone were meaningless. Not to get into all of the boring details, two distributions can have the same mean, but be completely different. Here is an image I made in Mathematica and sktich to show why:
<a href="http://skitch.com/leinweber/fydc/normal-distribution"><img src="http://img.skitch.com/20080120-tscppcbjptm64suuupkr63bsqe.preview.jpg" alt="normal distribution" /></a>

They all have the same mean, but a random pick from the distribution with the smaller variance of 0.5 is more likely to be actually be near the mean than with either of the ones with higher variances. If you apply this to load times, two severs could serve pages just as quickly on average. However, the one with the higher variance is going to seem a lot slower, since there are more slow points in the set.

I submitted a [patch](http://merb.devjavu.com/ticket/460) to add the standard deviations to each of the tests and [clean up the output a bit](http://pastie.caboo.se/139496).

AutoTest problem
----------------
I was trying to get autotest up and running but kept running into this problem:

  /Library/Ruby/Site/1.8/rubygems/custom_require.rb:27:in `gem_original_require':
  no such file to load -- rspec_autotest (LoadError)
  from /Library/Ruby/Site/1.8/rubygems/custom_require.rb:27:in `require'
  from /Library/Ruby/Gems/1.8/gems/zentest-3.5.0/bin/autotest:35
  from /usr/bin/autotest:19:in `load'
  from /usr/bin/autotest:19

After futilely searching for the problem for a long time, and asking in #merb where someone else was having the same problem, I was about to give up and just run my tests by hand (oh no!). I decided to check the versions of all my gems, and it turned out that zentest was only 3.5.0 when the latest was 3.7.2. I thought that was odd, because I just installed the gem that night. Odder still, updating the gem did nothing to increase the version. It turns out there is zentest and there is ZenTest

  $ gem list -r | grep -i zentest
  zentest (3.5.0)
  ZenTest (3.7.2, 3.7.1, 3.7.0, 3.6.1, 3.6.0, 3.5.2, 3.5.1, 3.4.3, 3.4.2, 3.4.1, 3.4.0, 3.3.0, 3.2.0, 3.1.0, 3.0.0)

***edit**: As of Jan 20, 2008 this seems to be fixed, and there is only ZenTest*

Uninstalling zentest and installing ZenTest fixed the problem.

Watching Datamapper's SQL
-------------------------
This is very easy to do. Just edit your config/database.yml file to include
{% highlight ruby %}
  :log_stream: STDOUT
  :log_level: 0
{% endhighlight %}
and you can see the SQL in your merb process.
