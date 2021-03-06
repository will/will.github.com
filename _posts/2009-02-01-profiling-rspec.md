---
title:      Profiling RSpec
layout: post
category: blog
---

If you have anything approaching a large test suite, the time spent running them becomes an important factor. The longer they take, the less often I tend to run them, which is bad. And I'm probably not alone in that. Ideally you'd be refactoring all your tests, removing duplication and such. If you're just interested in speeding things up, though it'd be nice to know where the slow specs are.

RSpec ships with a profile formatter that, but it leaves a lot to be desired. It only reports the top 10 slowest examples, and with several thousand specs, the top ten just isn't enough. It also doesn't provide any sort of statistics which are nice to track over time, say on the CI box. So let's improve this.

![stopwatch](/images/stopwatch.jpg)

### RSpec Formatters

Just run `spec` by itself, and you'll see there are about a half dozen formatters. Let's take a closer look at the [existing profile formatter](formatter). It records the time taken for each example and then prints the top ten in `#start_dump`. The recording part is fine, we just need to do a little more work in that dump method there.

```ruby
  def start_dump
   super

   @example_times = @example_times.sort_by do |description, example, time|
     time
   end.reverse

   times = @example_times.map {|d,e,t| t}
   mean = times.mean
   stddev = times.standard_deviation
   k = 2
   @example_times.reject! { |d,e,t| t < mean + k * stddev }

   @output.puts "\n\nTop #{@example_times.size} slowest examples:\n"

   @example_times.each do |description, example, time|
     @output.print red(sprintf("%.7f", time))
     @output.puts "\t#{description} #{example}"
   end

   @output.puts "\n\nStats"

   @output.puts "Mean:\t#{"%.5f" % mean}"
   @output.puts "StdDev:\t#{"%.5f" % stddev}"
   @output.puts "Total:\t#{times.size}"
   @output.puts "Slow:\t#{@example_times.size}"

   @output.flush
 end
```

So what's going on here? It's not too much different than the built in one, except we compute the standard deviation and mean of the set of times and use them grab all of the slow specs. This of course assumes that you already have `#standard_deviation` and `#mean` on `Array`. If you don't or don't feel comfortable adding those to the class, they can just as easily be methods in this module.

Once we have those, we keep the ones that are 2 deviations from the mean. The choice of two is arbitrary, but I found this gave just enough to get a good look at the slow specs. Finally we print some of the stats we collected. This is great to run on the your CI box. It still checks the whole suite like `rake spec`, but now there's the chance to record the stats and see how the tests are evolving over time.

### Using the new Formatter

To get this going, we have to make a class that inherits from `Spec::Runner::Formatter::ProgressBarFormatter`, and that file will also need to `require "spec/runner/formatter/progress_bar_formatter"`. The rest is exactly the same as the built in `ProfileFormatter`. For example, name this new formatter `RobustProfileFormatter`, and put it in `spec/config`. To run it once off the command looks like this: `spec -c -r spec/config/robust_profile_formatter.rb -f RobustProfileFormatter`. The `-c` option turns on color output, `-r` requires the new code, and `-f` chooses it as the formatter.

That's a lot to type out, and a rake task would be much nicer. In `lib/tasks/rspec.rake` there are a bunch of tasks. Inside the `spec` namespace is a good place to put our new task:

```ruby
desc "Profile specs"
Spec::Rake::SpecTask.new(:profile) do |t|
  t.spec_opts = ["-c",
                 "-r spec/config/robust_profile_formatter.rb",
                 "-f RobustProfileFormatter"]
  t.spec_files = FileList["spec/**/*/*_spec.rb"]
end
```

That's all there is to it, go and speed up your specs!

[Stopwatch image](flickr2) from flickr

[stopwatch]: http://farm1.static.flickr.com/195/504212595_56388484f9.jpg
[stopwatch2]: http://farm3.static.flickr.com/2408/2110119064_39a6054077.jpg
[flickr]: http://flickr.com/photos/ytwhitelight/504212595/sizes/m/
[flickr2]: http://flickr.com/photos/teamperks/2110119064/
[formatter]: http://github.com/dchelimsky/rspec/blob/738d9245c3ff68add2218294e3eb46951a18f245/lib/spec/runner/formatter/profile_formatter.rb
