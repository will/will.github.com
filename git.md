Back in February, on a flight home I wrote a fun little utility, in about 100 lines of ruby. In spare time over the following week, I rewrote it in about 300 lines of C.

I gave out hints to several people about it did, but wanted to wait for someone to discover it before announcing it.

Those hints were:

* I needed to figure out how to generate a [2 dimensional integer spiral](http://2000clicks.com/mathhelp/CountingRationalsSquareSpiral1.aspx) to keep two numbers as close to zero as possible, so to minimally disrupt the natural order of things.
* I redid it in C to take full advantage of all my cores. So it is CPU heavy.
* It was something that I expected people to notice.
* The first version was small enough to be written on a plane.

I really thought it would have been discovered in a few weeks, but months and months kept going on and it hadn't been discovered. From time to time a few people commented that I was lucky and got a neat sha for a particular commit, but I didn't consider this to be discovering it—they saw a point, not the line. I feared that it would never be discovered, but finally on June 17th [Maciek Sakrejda discovered][twit] the pattern.

Great job Maciek!

[twit]: https://twitter.com/deafbybeheading/status/479131436369207296

# git vain

All of my commits since February have [started with `cafe`][pge]. Well except for the commits that [killed taps][taps] which started with `dead`, and the commit for the 5up3r l33t [pull request 1337 on shogun][leet], which started with `1337c0d3` (and I'm not sure why it never got merged).

[pge]: https://github.com/heroku/heroku-pg-extras/commits/master?author=will
[taps]: https://github.com/heroku/taps-archive/commits/master?author=will
[leet]: https://github.com/heroku/shogun/pull/1337/commits

To do this I made a git command called `vain` which brute forces the sha by changing the author and committer dates in the [commit object][co] a second at a time around `(0,0)`, hence the need to figure out how to do the integer spiral.  While to get this to work requires changing reality, I didn't want it to cause a nuisance to anyone looking at the timestamps of my commits. In practice, it finds a solution within a minute or two of the actual time.

The C implementation was a lot of fun. Using pthreads was neat. It was cool to be able to make it up to twice as fast for short commit messages by pre-computing the partial sha up to the first commit date (thanks to Daniel Farina for the idea). The best part though was using OS X's excellent profiling tool Instruments, to do things like see that an often called section was not using the `divmod` processor instruction and fix it so that it would:

```
 void mytoa(int val, char *dst) {
    int i = dateLen-1;
 -  for(; val && i ; --i, val /= 10)
 -    dst[i] = "0123456789"[val % 10];
 +  int m,v;
 +  for(; i ; --i) {
 +    v = val / 10;
 +    m = val % 10;
 +    dst[i] = m+'0';
 +    val = v;
 +  }
  }
```

I'd like to maybe try getting it to use the gpu, but I couldn't find good resources for OpenCL. Everything is all cuda, but my gpu doesn't support that. For short prefixes though it's fast enough. The `1337c0d3` one took like 12 minutes, but 4-5 character prefixes are found in well under a second.

[co]: http://git-scm.com/book/en/Git-Internals-Git-Objects#Commit-Objects

# demo

I don't have it set up as a precommit hook or anything. Rather it is manually ran after making a commit. It uses the global git config to store the default prefix, but local git configs override it (`git config` takes care of all that, which is nice).

```
$ git log HEAD^..HEAD
commit 9ca1a5bc4c3b0f44f763166425cd2c17e139e842
Author: Will Leinweber <will@bitfission.com>
Date:   Sun Feb 9 17:45:29 2014 -0800

    lawyerup

$ git config vain.default
dead

$ time git vain
searching for: dead
∆a: -19, ∆c: 12, khash: 0
deada6c8918ee3b7a29b41b770856f6b66e20442
git vain  0.02s user 0.02s system 90% cpu 0.035 total

$ git log HEAD^..HEAD
commit deada6c8918ee3b7a29b41b770856f6b66e20442
Author: Will Leinweber <will@bitfission.com>
Date:   Sun Feb 9 17:45:10 2014 -0800

    lawyerup
```

