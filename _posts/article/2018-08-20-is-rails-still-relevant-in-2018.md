---
layout: article_post
categories: article
title:  "Is Rails still relevant in 2018 ?"
disq_id: 54
description:
  Is Ruby on Rails still relevant technology to learn in 2018 ?

---


Few days ago I've received email where I was asked an advice from a web
developer who was considering switching from Ruby to something else. I
was asked in the email:

> If you would start from scratch, what would you choose: Ruby, Elixir
> or maybe even JS for the backend?

Another important part of the email was that he was mainly interested in
writing own side projects where main consideration is development speed and ease.

I've started to write a response when I've realized the email is
quite long. So I've decided to turn it into an article.

So for those interested on my take on this here it is

### They are just tools

Any programming language any library any framework any database any
coding rules: they are just tools.

You may want to use hammer when you are nailing a nail to
the wall, or maybe when you want to smash bricks you would use a bigger
hammer. But using hammer to fix a car may not be good idea.

Truth is that during your career you will be forced to use / try / learn
multiple different technologies and different product development approaches.
**Being a web developer is not a job but a lifestyle !**.
It's a never ending cycle of self improvement.

> Re "lifestyle": I'm not talking about work-life balance, I'm talking
> about work-life mindset. Developer is like a MMA fighter, you will
> have to learn and endlessly practice different martial arts.

So you need to realize that it's not  just programming languages that are important but also
technologies that the programming language works with (databases, cloud solutions, caching, libraries ....). Also important are
architectures([Monolith vs Microservices](https://skillsmatter.com/skillscasts/11594-lrug-march)), team organization practices(e.g. [agile](http://agilemanifesto.org), Scrum, Kamban, [XP](http://www.extremeprogramming.org), [github-flow](https://guides.github.com/introduction/flow/),...), coding practices & styles([SOLID](https://www.youtube.com/watch?v=TMuno5RZNeE&t=960s), [DCI](https://en.wikipedia.org/wiki/Data,_context_and_interaction), [bounded contexts](https://martinfowler.com/bliki/BoundedContext.html), [OODD](https://www.youtube.com/watch?v=RdE-d_EhzmA), many many more ...) Programming language is just
the glue.

You can work with the fastest programming language out there, but still
if you have no idea how to effectively query a MySQL database you will
create supper slow application.

### Developer happiness

You will work with that programming language 8-10 (maybe even 16) hours
a day. **Don't underestimate the importance of "developer happiness"**

If that what you work with (or the project you work for) doesn't make you happy then it's you that failed not
the Programming language.

I love my job because I've picked a job with the right set of technologies
, with the right team, with the right project that has the right set of values.

Junior developers often have to sustain jobs that they may not
like just to gain experience but I honestly don't understand how in the year 2018
any **decent** senior role web-developer may be miserable
in his job. There are definitely days that are stressful or frustrating
but those are temporary states. But miserable ?
Either change the project/job, the technology, or the way how
you work (e.g. push for [remote working](https://basecamp.com/books/remote)).
If none of that is possible then you are probably not
that decent web-developer after all and try work on your self improvement harder (then
revisit this paragraph in couple of months.)

> Working 10 years as a web-developer doesn't mean you have 10 year
> experience. Maybe you just repeated the same year 10 times !





### No winners

There is no "bad" programming language, only badly chosen project where
you would use that programming language.

Way to often I hear or read software developers dismiss languages like
Ruby as too slow" not realizing that their strength was never the speed.
And then when you investigate background of those claims you discover
someone was trying to fit couple of thousand request to non-load
balanced server or had no idea what caching is.

> Load balancing means that instead of one VM (virtual machine computer)
> you introduce multiple  VMs with same code running and spread the load
> between them. This way you can introduce multiple smaller VMs whenever
> you have a peek time when your application is mostly used instead of
> paying for large expensive box that needs to be on all the time.

Often I read developers complaining about languages like Java are too
complex or non-pragmatic for real applications. Those languages were
designed for enterprise use where applications are developed in larger
teams with the desire to run couple of decades. For example banks will choose Java over
Ruby without hesitation. The main reason is that Java almost never drops a
feature (even the bad ideas in laguages are supported pretty much
forever once they were released). Ruby feeling less preasure from
enterprise giants can afford to do radical changes that may break code but
introduce better features.


Don't underestimate the size of community as well. Too small community
may mean that there are not that many libraries and senior develpers
willing to jump to fix bugs.

To large community may get toxic pretty quickly. It may not sound as 

If you are working on Google size project with billion users you may not
want to use Ruby. At the same time if you are Google you 


There are also cases where project matured so much that the original
technology cannot support it anymore.

language because  or "too unfamiliar",...


It's always ok to prepare for a large scale but honestly don't kid
yourself. I worked for so many startups that were expecting couple of
million users as first draft of specification and by the time they were
shutting down they had only couple of thousand.

The reason was never insignificance of the language but marketing
failture or the ability not to keep up with requirement of shipping new feature releases 



#### JavaScript

At least minimum level of  JavaScript knowledge is essential for frontend web-development when
one is building fullstack side project. So given or take JavasScript
must be learned to some degree.

For backend I've tried it couple of years ago on a side projects and didn't like the experience so I've
never really returned to it. I'm not saying it's good or bad I just feel it's not
the right choice for me. I'm pretty sure there are many happy Backend JS developers out
there I'm just not one of them. That's why I'll not say much on JS in
this article.

One good argument that I've heard is that the developer in modern
web-applications can write backend in NodeJS (JavaScript), frontend in React or Angular or VueJS (all JavaScript),
BE and FE will be communicating with each other via JSON (JavaScript
object exchange) and the database can be MongoDB where you store JSON
documents.

So entire experience of web-development feels like you just need to know
one programming language.


#### Ruby

Ruby is an excellent Object Oriented programming language where the primary
goal (in my opinion) is excellent OOP experience and developer happiness.
But speed of code is not a primary goal.

So what I mean by that: More you will learn object oriented programming more and
more you will be stumbling upon many buzzwords like SOLID principles or
object composition, object oriented decomposition and design, simple design, etc... but also testable code and TDD, etc..

Ruby is just excelent  when it comes to these practices invented by
really smart people.

My opinion is that Ruby is the best language to express
yourself.


#### Ruby on Rails


Ruby on Rails is web framework built upon Ruby language where the
primary goal  is productivity and developer happiness. Speed of code and
true decoupled OOP experience is not the main goal and  socket
connection is not that great.


#### Elixir



Elixir vs Ruby is in really Elixir vs Ruby vs Rails.






Hi Christian,

thank you for contacting me, I'm always happy to reply to these kind of
emails.

I've started to write a reply to your email and discovered that  the
answer is long as an article. So would it be ok
if I email you later today my full response in a form of Article on my
website (where I fully explain my reasoning) ?


Elixir is excellent functional programming language where primary goal
(in my opinion) is multi-core processing (code speed) and socket
connection support while keeping in mind developer happiness and
reasonable productivity. 
Elixir has Phoenix web framework but more you read about it it's really
collection of  libraries that go hand in hand with Elixir primary goals.

That's why Elixir vs Ruby vs Ruby on Rails :) 

My explanation sounds really similar but devil is in the details and
I'll explain those details fully in that article :)  But main point is
that Rails is also a philosophy of how to write code so you build your
products fast.
So if your main concern is "development speed and ease" then I would go
with Rails. Especially if it's just you (not a team of developers)
creating that project.

BUT the type of project is also important! If you are building e.g.:
e-commerce shop where 95% of browser communication will be via GET, PUT,
POST requests and maybe you will have 5% socket communication (e.g. some
shop chat) then Rails is good choice.

If you are building Chat application where 95% of communication  will be
via sockets then that's a different story. If you will have more than
200 users connected at the same time  then probably Phoenix Elixir will
be much better choice. (if the chat is just
couple of friends go with Rails !) 

I have the feeling from your email that you are the type of person who
wants to build his  own projects and make the living out of those.
Personally advise to go with Rails 

If you desire to work in medium large teams that do fun web-projects go
with Rails, But be aware that often goes with hand in hand with startup
life (it's often company run out of money the very same year they lunch
project) 

If you are more of a person who wants to work in large company on really
interesting projects that tackle large scale problems in larger teams
maybe Elixir is better for you. 

if you are type of person who would just want to learn just one language
and do all your projects in one language then JavaScript is a good
choice (you learn same language for frontend and backend) . But honestly
you may trick the learning curve with one language
you will still have to learn those other technologies (Databases, cloud
storage, caching,  libraries, ...) 


in retrospect,  I would choose Ruby on Rails again. What I would do
differently is that I would stop listening to every senior developer who
was saying "you are doing it wrong because it's not OOP, it's not SOLID,
it's not clean".They have good points and good ideas and it's wort to
learn them. But they are not "rules" they are just advises ! .

 With any technology you need to understand why it was invented (
 history will help you understand the future)

 here are some videos I highly recommend you to watch before choosing
 Rails https://www.youtube.com/watch?v=9LfmrkyP81M
 https://player.fm/series/all-ruby-podcasts-by-devchattv/rr-342-rails-development-and-more-with-david-heinemeier-hansson
 http://testandcode.com/45

 here is a video that best explains Elixir reasons:
 https://www.youtube.com/watch?v=tMO28ar0lW8 ,
 https://www.youtube.com/watch?v=MMfYXEH9KsY  


 Will get back to you soon with the article ;) 


### sources

* 

---------------





I wanted to write an article on this topic for  several years but I was delaying
it until I achive  something in the field worthy of giving this advice.
Truth is I'm writing Ruby code 9 years now and I'm still nobody.


