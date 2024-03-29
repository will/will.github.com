---
title:      Rails Integration Testing Stack for Winners
layout: post
category: blog
---

Full-stack, acceptance, integration, or whatever-you-want-to-call-it testing should be a large part of your test suite. I'm not going to waste time trying to convince anyone of this, since there are probably a million other blog posts doing that (and probably twice as many arguing the different names).

![finish line](/images/finish.jpg)
Rather, I'll show you the hands-down best way to do it with what's out there right now. Follow this setup and you too can be a winner. I've written [a bit](/2009/06/celerity.html) about this earlier, but things have gotten better since then.

Currently, while Rails 3 is close, it's not out yet, so I'm ignoring it for this post. Latest is 2.3.5. Here we go.

Cucumber
--------
Cucumber drives everything. It's awesome, and you should have already heard of it. Everyone uses it. It's surpassed the vegetable on google for the top result.

It ships with webrat, but _don't use webrat_. It's neat and probably helped a lot to get cucumber popular. But it can't do javascript. And what site doesn't have JS these days. You need to be testing that too, you know.

[Cucumber &mdash; cukes.info](http://cukes.info/)

Capybara
--------
This is what you use instead of webrat. It lets you use a bunch of web drivers behind it. Out out of the box it supports selenium (ugh) and Celerity/Culerity (awesome). Before getting cucumber to work with Capybara was a little hacky, but they're best friends now. Use this.

You tag the stories that need javascript with @javascript, and it'll fire up culerity when it needs to. That's all you have to do. It's fantastic.

[Capybara &mdash; github](http://github.com/jnicklas/capybara)

Culerity
--------
This provides a nice bridge between your MRI Ruby rails app, and the jruby-only gem Celerity. It'll fire off a separate server running in the test environment, then start up a jruby process for celerity.

Now this one can be a bit of a pain to set up, since you need to install jruby and then celerity and make sure that's all working and wired up. A nice alternative is [Matt Fletcher's fork](http://github.com/fletcherm/culerity/), which bundles all that into the gem itself so you don't have to worry about it.

There can be some problems with gem bundler, though. The gist of it is that you have to use JRuby v1.3.1 or earlier. I wrote more details about the bug on the  [mailing list](http://groups.google.com/group/culerity-dev/browse_thread/thread/3c1ed5f38d540ad1). It looks like _just yesterday_ Matt updated his fork to fix this, so hurray!

[Culerity &mdash; github](http://github.com/langalex/culerity)

Celerity
--------
This is what's actually doing the work. It's a JRuby-only gem, since it uses the Java [HttpUnit](http://httpunit.sourceforge.net/) headless web browser. This is a complete web browser, with its own javascript engine, except it is just controlled though some API, and doesn't have a display.

Selenium was cool for it's time. Watir too, I guess, though I never used it. But relying on a real browser sucks. It's really slow. You have to worry about browser upgrades breaking the tenuous control. And it makes your CI server a hundred times more complicated than it has to be. Fuck that, when you can use Celerity which is awesome.

For some reason I can't quite remember, I had to stay on version 0.7.6. If you're having weird problems try that version. Of course, if you're using Matt's culerity fork like I suggested, you don't have to worry about it.

[Celerity](http://celerity.rubyforge.org/)

_picture credit: [philo nordlund](http://www.flickr.com/photos/philon/2477878611/)_
