---
title:      Reopening NilClass
layout: post
category: blog
---
I just read a post advocating <a href="http://blog.rubyenrails.nl/articles/2008/02/29/our-daily-method-18-nilclass-method_missing">changing NilClass#method_missing to always return nil</a>. Their argument is that you no longer have to check if you actually have something before calling methods on it like:

```
@sun && @sun.still_burning?
```

Instead, you could just call @sun.still_burning?, which is nice. I usually just check <a href="isTheSunStillBurning.com">isthesunstillburning.com</a> 20 times a day to make sure, but you get the point. _*Edit:* it looks like this site is no longer up, and now I get worried at night, when I can't tell_

<img src="http://farm1.static.flickr.com/77/158529397_d0e4a4cfb0.jpg" style="margin-right: 10em">

Now, it's a very attractive, very short solution to an every day annoyance -- that alone is enough to make me worry. Overriding #method_missing on NilClass just seems _wrong_.  The better solution is to define Null Objects for all of your classes, and have those returned instead of nothing. Yeah, it's more work than the method_missing solution, but it's a lot safer and doesn't leave such a bad taste in my mouth.

### I do actually reopen NilClass though

Often, actually. Working with rspec and making typos can be very frustrating otherwise. If do @sum.should_recieve(:set) instead of @sun, then you'll get

```ruby
  Mock 'some mock' received unexpected message :tyop?
  # or
  Mock 'NilClass' expected :list_pathways with ("hsa") once, but received it 0 times
```

The second one is easy to realize you have a typo, sure. But I know I've wasted time wondering why the expectation failed, and I'm sure you have too. By adding a few methods to NilClass, this is no longer an issue:

```ruby
  class NilClass
    def should_receive(*args)
      raise "WARNING: you tried to add expectations to nil!"
    end
    alias :stub! :should_receive
  end
```

Now we get: <code>WARNING: you tried to add expectations to nil!</code> and even a line number to where the typo is.

When else have you found it okay to mess around with NilClass? I'm sure there are a few other occasions where it makes sense.

Sun picture from <a href="http://flickr.com/photos/rogersmith/61126609/">rodger smith, flickr</a>
