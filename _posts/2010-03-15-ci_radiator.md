---
title:      CI Radiator in Javascript
layout: post
category: blog
---

Continuous integration is a must. But if your team can't easily see the current build status, you loose a major benefit of CI: short feedback loops. The longer it takes to notice that the build is broken, the worse off you'll be.

I wrote really simple radiator that shows the current build state and the SHA of the associated commit just using HTML and JavaScript. We have it sitting up in the corner of the room, and it's been invaluable over the last few months. I even made a video showing it off, but never got around to really sharing it. Check it out:

<object width="500" height="375"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=8851542&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=ff0179&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=8851542&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=ff0179&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="500" height="375"></embed></object>

We use Hudson for CI, and if you're using it too, you can just go ahead and use this html yourself with a few modifications. Enjoy!

<script src="http://gist.github.com/281402.js"></script>
