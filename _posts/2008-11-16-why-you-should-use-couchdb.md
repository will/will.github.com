---
title:      Why You Should Use CouchDB
layout: post
category: blog
---

### New Approach to an Old Problem

Your applications need to store and retrieve data. That's nothing new. [CouchDB](http://incubator.apache.org/couchdb/), and other document databases like Amazon SimpleDB, are new to the game however. Okay, I'll admit the general concept is some [20 years old](http://en.wikipedia.org/wiki/IBM_Lotus_Notes), but it's safe to say that they've recently started to gain popularity over the last year or so.

<div class="image left"><img src="/images/couchdb.png" /></div>
Learning a document database is worthwhile, even if you don't end up using it for anything serious in the near future. You'll gain new insights on how to solve your current problems. Don't take my word for it, there's that line everyone quotes from The Pragmatic Programmer: _Learn at least one new database paradigm a year_, or something like that.

What exactly makes CouchDB so great? Read on.

### Stable and Scalable

When you update a document in CouchDB, it doesn't go in and change the existing document. Instead, it just adds a new version. The upshot is that your data is never in a bad state, so even in the case of a power failure, you're not going to lose data or spend time verifying against corruption when you start up again. All these extra versions are deleted when you compact the database, so there isn't much of a storage penalty because of it.

<div class="image right">
  <a href="http://leinweber.us/post/58513962/we-need-more-erlangs">
    <img src="/images/erlangs.png" /><br />
    <span class="alt">Other databases have low erlangs</span>
  </a>
</div>
It's written in Erlang, and benefits from the stability and concurrency of the language its design idioms. Also, unlike current relational databases that try and make a single query as fast as possible, CouchDB tries to maintain consistent performance as the number of queries grows.

Another big plus is that it doesn't have a custom binary protocol. It uses regular HTTP. This means you can use existing http infrastructure tools such as load balancers and clustering proxies. Better still, it's RESTful, so you interact with it using the CRUD operations we've come to know and love.

The way you query data from CouchDB is through views which are written using the map/reduce approach. These views themselves are indexed, so they're very fast as long as you keep the indices fresh. While it's not an option now, it's possible that in the future the mapping step could be distributed amongst several nodes which could make it ridiculously fast.

### Deep Structures, No Schemas

Data has it's own natural shape, and I know I'm not the only one who is sick and tired of fighting that fact. It is often an uphill battle cramming models into relational records. Your data is more complex than a few simple strings, numbers, and boolean values. You have lists, you have hashes, and even small variations between instances of the same object. This is unacceptable in the relational world.

ORMs like ActiveRecord and DataMapper have done a lot to to ease the pain and abstract away the nastiness of SQL. It's not enough though. It's like treating the symptoms and not the underlying condition. You still have to worry about joins, normalization, and other artifacts from relational databases. These issues leak their way up into your models where they don't belong, and obscure more important logic.

All of this isn't an issue with CouchDB, and that's the biggest selling point for me. The fields in your documents can be hashes, they can be arrays, they can be arrays of hashes. Anything that can be serialized to JSON. It's about documents &mdash; not records.

As a quick example, rather than having to create an assets table for uploads, you can store all the metadata in a single field. That field can live right on the object that is responsible for it, where it belongs. Or you could store all the comments for a blog post inline with the post itself. There's a good article comparing [inline vs. separate storage](http://www.cmlenz.net/archives/2007/10/couchdb-joins) that is worth a read.

### Downsides

Nothing is without drawbacks, and CouchDB is no exception. For one, it's still alpha. That's not to say it's buggy and unusable &mdash; far from it &mdash; but there are likely to be changes before they hit 1.0. I can't say to what extent this will be an issue, but you should be aware of that.

There is no security model. This turns out to not be _that_ big of a deal, but it's far from ideal. You can lock down the port it runs on to only talk to localhost, which I think happens by default.

The first time you run a view it will be slow. It has to go through every document and build the index. After that though, it only has to go through the new or changed documents and is significantly faster. You can make sure your views are fresh by running them after every couple hundred updates or every 10 minutes or so. But if you're always running unique views, CouchDB probably isn't a good choice.

### Getting Started

Go ahead and compile CouchDB from the svn head rather than going for the last release. You can find instructions over on [their wiki](http://wiki.apache.org/couchdb/Installation). You'll also want a persistence layer. So far, I've been most impressed with [Couch Potato](http://github.com/langalex/couch_potato/tree/master). I've been using it with Merb, which has been great. You just need to add it to your `config/dependencies.rb` like this

```ruby
dependency "langalex-couch_potato", "0.1", :require_as => "couch_potato"
```

then add this to your `config/init.rb`

```ruby
Merb::BootLoader.before_app_loads do
  CouchPotato::Config.database_name = "appname_#{Merb.environment}"
  require 'json/pure'
end
```

You might not need that `json/pure` fix. I was having some problem where `#to_json` was declared multiple times. It'd be nice if there was a merb_couchpotato gem so you could just say `use_orm :couchpotato`, and maybe use database.yml instead, but it's not really necessary yet.

That's really all it takes. Go checkout the readme for Couch Potato and its [introduction post](http://upstream-berlin.com/2008/10/27/couch-potato-unleashed-a-couchdb-persistence-layer-in-ruby/).

Time to relax.
