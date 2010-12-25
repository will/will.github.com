---
title:      Faking "or shift left"
layout: post
---
I've often been annoyed at the lack of <code>||<<</code> after being spoiled with <code>||=</code> for so long. The workaround I've typically used is to go ahead and use <code>||= [ ]</code> to make sure I have an empty array. That's ugly though. You're dropping down a level and writing the "how" instead of the "why".

Today some code <a href=http://blog.jayfields.com/2008/09/ruby-recording-method-calls-and.html>Jay Fields posted</a> had the answer I've been looking for. It's not quite as elegant as having the operator itself, but it does the job of tucking away the ugly detail of ensuring you have an empty array to shift on.
{% highlight ruby %}
def method_stack
  @method_stack ||= []
end

def method_missing(sym, *args)
  method_stack << [sym, args]
  self
end
{% endhighlight %}

We're still using <code>||= [ ]</code> but it is hidden away in its own spot, which I find to be much cleaner.
