---
title:      Auto Merge Gemfile.lock
layout: post
---

<div class="right image">
  <img src="/images/lock.jpg" />
</div>
Here's the problem: you're working on a topic branch and add a gem to your Gemfile, and someone else has added a gem to master before you're done. When you go to rebase, every single one of your commits is going to have a conflict with `Gemfile.lock`.

All you have to do is run `bundle lock` to get bundler to relock then add that and continue your rebase. But that's so damn tedious.

Good news! I just figured out how to tell git how to do that for you, and it works great. There are two files you have to edit.

### gitconfig

First is your `~/.gitconfig` file. Here we're going to give it a new merge strategy, one that will just relock the gemfile. Add this to the end:

    [merge "gemfilelock"]
      name = relocks the gemfile.lock
      driver = bundle lock

The driver is what git will use to try and fix the conflict. Its exit status will tell git if the merge was successful or not. Here all we're doing is having bundler relock. You can see it in action in [my dotfiles](http://github.com/will/dotfiles/commit/4ed4930c61df795b7fbc9732d3c6463164ebb43f)

### gitattributes

Next up, we have to tell git to use our new strategy for `Gemfile.lock`, and we do that with [gitattributes](http://www.kernel.org/pub/software/scm/git/docs/gitattributes.html). You can either put this in `project/.git/info/attributes` or `project/.gitattributes`. I did the .git directory one myself, but it doesn't matter. We just need one line in this file:
    Gemfile.lock merge=gemfilelock

### results

And that's it! Here's what happen when you rebase now

<pre><code>First, rewinding head to replay your work on top of it...
Applying: commit one
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Your bundle is already locked, relocking.
<span style="color: green;">Your bundle is now locked. Use `bundle show [gemname]` to list the gems in the environment.</span>
Auto-merging Gemfile
Auto-merging Gemfile.lock
</code></pre>

Now that, if I may say so myself, is really awesome! (image credit [malstora](http://www.flickr.com/photos/maistora/3237164755/))

