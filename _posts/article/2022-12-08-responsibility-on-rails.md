---
layout: article_post
categories: article
title:  "Responsibility On Rails"
disq_id: 60
description:
  Being a web-developer is one of the coolest jobs in the world.
  It brings freedom and growth  opportunities like no other job in the world.
  It’s easy to just enjoy the fruits of this craft.
  But remember with great benefits comes great responsibility.
---

![](/assets/2022/responsibility.jpeg)

November 2022 I’ve celebrated 13 years of being a Ruby on Rails developer. It just feels like a good time to get something off my chest. Here's the story:

One project I’ve worked for was originally developed by a dude who used [Ruby on Rails](https://rubyonrails.org/) for the first time in his life. Don’t get me wrong, there’s nothing wrong with that, in fact I encourage everyone to choose Ruby on Rails for their personal dream or an experiment.

Problem is that this dude was hired as a super expensive contractor with tons of experience but that experience was all with different programming languages. After 6 months his contract expired and he moved on to a different  project probably trying out different web development tools.

As I've been hired to take over the project from where he left I can truthfully testify the dude has never read a single Ruby on Rails book or design pattern book. I’m not kidding when I say some controllers were 4000 lines and the entire codebase was without a single test. The burden of his “I will learn on the job” attitude is that the company inherited a barely functional mess.

This may not be a problem if one accepts a contract for a company that can afford to throw money left and right. But it's just evil if you do this to a fresh startup that just managed to scrape a couple of thousands dollars to make their dream real.

And this article is a call to the moral side of all fellow web-developer colleagues: Our job is not just about the money. Sometimes people's dreams are at stake. Sometimes people take personal loans and draw their life savings to make those projects real.

If you’re planning to accept a greenfield project honestly ask yourself: Are my skills up to the task?

I don't want this article hanging on a plea. Here are my personal opinions what is the solution


### Learn, but don’t forget to learn responsibility

Look, I'm not trying to bring down anyone who wants to learn. Far from it. I think everyone should explore and experiment. Technology my project uses may not be the best match for your project and vice versa. We need to broaden our horizons.

It's more about the terms of this exploration and experimentation.

Many companies allow their employees to play around with new technologies and that's good. They either allow side projects or dedicate separate environments for the experiment.

Many companies can't afford it (e.g.: fresh startups)

Many companies can afford it but straight up refuse to invest in such things

> There are usually some fundamental issues with those kinds of projects and good developers don’t stick around for very long or the projects fail on their own. I worked for a company where the manager was frequently telling us he would not pay us to write tests. Yeah, that project didn’t last long.

Whatever the case you need to be responsible with anything you introduce. You want to introduce a new gem or JS library? You want to try a new code design pattern? You want to split monolith into microservices? You want to implement a new DevOps tool? Ok cool, but how long are you planning to stay on the project and carry on this decision? 5 years? 5 months? 5 weeks ? Who will carry on this  responsibility after you leave?

Last project I worked for I worked there as a Lead for 7 years. I've learned the word Responsibility with capital R.

So what if my company doesn’t allow me to experiment? Should I just experiment in my free time without anyone paying me for it ? ...well, yes.

### Creative process

I've heard music producer [Rick Rubin](https://en.wikipedia.org/wiki/Rick_Rubin) talk about the creative process of Eminem:

> 99% of what he writes is never used. He does this just to stay engaged in the creative process of writing and finding new ways to write. He does this so that when he needs it, it just comes.

Look at my [Github profile](https://github.com/equivalent?tab=repositories). It's a mess! At the time of writing this article I have around 180 public repos of which 89 are sources (I have many many more private ones). I  really need like 10% of them and rest are about the process.

New design pattern? Create a dummy project to test it out. Interesting deployment solution? Create a dummy project and try it out. New programming language I would like to try? Create a repo and try it out,...

I create all that mess so that once I'm paid to deliver a solution I already done the drafts and it's time to bring real rhymes.

Same applies to my attitude towards OpenSource projects. Many times I fork a repo, start writing an improvement and abandon the work. Many time I realize my idea is stupid, many times I just don’t have the time to finish it to a real pull request. Finished or not finished, I win either way as I absorb new coding styles, thinking patterns, …new beats.

Look if you are doing this 9 to 5 just to get paid I have no more arguments for you. I'm surprised you made it this far reading this. I'm surprised you are reading an article no one is paying you to read.

Throughout my career I've met true web developer artists both in Frontend and Backend. People who enjoy what they create and love the craft. I salute to all of you.

For the rest of you at least think about it.

### Convention

You need to realize that some companies or teams are about consistency with their approach.

For example look at what [DHH](https://dhh.dk/) and good folks at [37 Signals](https://dev.37signals.com/) (creators of Ruby on Rails) have been preaching about all these years. [Monolith over microservices](https://m.signalvnoise.com/the-majestic-monolith/), [limit the use of service objects](https://dev.37signals.com/vanilla-rails-is-plenty/), [limit the use of JavaScript](https://hotwired.dev/), ...

They know about code designs, SOLID principles. popular architecture opinions and all the cool JS libraries out there. However they've deliberately chosen to limit their toolset so that everyone using vanilla Rails is on the same page.

This is not just for some idealistic open source strategy. They've decided to stick with this convention so that a junior developer creating his first Ruby on Rails project has the same tools for success as what they use on their products ([Basecamp](https://basecamp.com/) & [Hey](https://www.hey.com/)). My friends, that takes a lot of courage!

> Understanding the source code behind Rails will take you to the next level. Understanding decisions behind Rails will take you to the next dimension.

So remember next time the lead engineer in your company doesn't allow you to install a cool gem or use a new revolutionary JavaScript library: Maybe it's not because he/she is against your career "growth". Maybe it's because that decision would carry a burden that the whole team will have to carry for next decade.

The convention is sometimes better than what's cool.



### Discussion
