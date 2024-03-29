---
title:      Test Driving a File Parser
layout: post
category: blog
---
<p>
My current project involves pulling gene names and group data from a tab separated file, then coloring those genes on a pathway diagram. Just like any other part of an application, the parser should be well tested. But how exactly should you go about testing all the different edge cases that the parser will see?
</p>

<p>
One method I've worked with was to have several sample files in the fixtures directory and load them. I don't really like this, for much the same reason I don't like fixtures. It's too easy for fixtures to deteriorate into a large, unmaintainable mess. But more importantly, I can't see the whole test on one screen. Parts are hidden across several files, all of which you have to read before you can understand the test.
</p>

<p>
<a href="/images/pathway.gif"><img src="/images/pathway.th.png" style="margin-right: 10em;"></a>
</p>

<p>
I've come up with a simple way to solve this problem. The test files should be created in the test. Now this is for tab separated files, but it could easily be changed to create csv files, or both.
</p>

{% highlight ruby %}
it "should skip empty lines and extra columns" do
  file = [
    [ "gene 1", "group 1", "only the first two columns count" ],
    [ ],
    [ "gene 2", "group 1" ]
  ].to_test_file

  parser = Parser.new file
  parser.import

  parser.lines.should == [ [ "gene 1", "group 1" ],
                           [ "gene 2", "group 1" ] ]
end
{% endhighlight %}

<p>
(I actually have the empty lines test separate from the extra columns test, I just wanted to put them together for this post.)
</p>

<p>
#to_test_file is a method on Array, and it will create a file in the tmp decretory, then return the file name. Right now it can optionally take a specific file name. I've never had reason to use that, so I'll probably remove that bit of complexity.
</p>

{% highlight ruby %}
class Array
  def to_test_file(filename = "test_file")
    File.open("tmp/#{filename}", "w") do |f|
      self.each do |line|
        f << line.join("\t")+"\n"
      end
    end
    "tmp/#{filename}"
  end
end
{% endhighlight %}

<p>
Stick that in spec_helper or test_helper.
</p>

<p>
Originally I had it on String, and put in all of the \t and \n myself. That was an unreadable mess. With Array you get the column and line separation implicitly.
</p>

This doesn't help at all for very large or complicated files. But for small, simple files, this is one of the easiest ways for testing the parser and keeping everything all in one place.
</p>
