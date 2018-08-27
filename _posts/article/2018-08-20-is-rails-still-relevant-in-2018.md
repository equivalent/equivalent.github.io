---
layout: article_post
categories: article
title:  "Is Rails still relevant in 2018 ?"
disq_id: 54
description:
  Is Ruby on Rails still relevant technology to learn in 2018 ?
---

Few days ago I've received email where I was asked for an advice from a web
developer who was considering switching from Ruby to something else. I
was asked in the email:

> If you would start from scratch, what would you choose: Ruby, Elixir
> or maybe even JS for the backend?

Another important part of the email was that he was mainly interested in
writing own side projects where main consideration is development speed and ease.

I've started to write a response when I've realized the email is
quite long. So I've decided to turn it into an article.

So for those interested on my take on this here it is.

> First I'll go trough some philosophical points of web-development, work life and then I'll
> shine some light on the technologies themself to better explain what they aim for.

### TL;DR ?

To long to read ? I'll  place the conclusion to the top of the article
then and you don't have to read the rest.

In retrospect I would choose "Ruby on Rails" as my primary technology again even in 2018.

I like the projects that this technology attracts (startups mostly)
and people similar to me I meet on the journey.
So it's my personal choice, you may be different.

Rails is not obsolete, Ruby is not dying (they are more awesome then ever before)
market for this technologies is really good ($$$).

> Anyone who want to fight my opinions pleas read the entire article first.
> Thank you.

I would focus on my primary tool (Rails) at the same time I would  keep learning plain Ruby,
Elixir, Phoenix and JavaScript as my side tools (everyone can find 20 minutes a day).

I wouldn't spend too much time learning programming
languages outside that list as you need more tools in your toolbox but too many tools may
get your toolbox cluttered and not really able to have the skill
required to operate the tool. Rather learn underlying technologies an
problems, like Databases, Caching, Coding practices, DevOps, team maintenance, testing, ...

> You can learn new programming languages when you are senior developer.

### They are just tools

Any programming language any library any framework any database any
coding rules: they are just tools.

You may want to use hammer when you are nailing a nail to
the wall, or maybe when you want to smash bricks you would use a bigger
hammer. But using hammer to fix a car may not be good idea.

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/web-developer-is-a-lifestyle.jpg)

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
if you have no idea how to effectively query in a MySQL database you will
create supper slow application.

### Developer happiness

You will work with that programming language 8-10 (maybe even 16) hours
a day. **Don't underestimate the importance of "developer happiness"**

If that what you work with (or the project you work for) doesn't make you happy then it's you that failed not
the Programming language.

I love my job because I've picked a job with the right set of technologies,
with the right team, with the right project that has the right set of values.

Junior developers often have to sustain jobs that they may not
like to gain experience but I honestly don't understand how in the year 2018
any **decent** senior role web-developer may be miserable
in his job. There are definitely days that are stressful or frustrating
but those are temporary states. But miserable ?
Either change the project/job, the technology, or the way how
you work (e.g. push for [remote working](https://basecamp.com/books/remote)).
If none of that is possible then you are probably not
that decent web-developer after all and try work on your self improvement harder (then
revisit this paragraph in couple of months.)

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/10-year-experience.jpg)

> Working 10 years as a web-developer doesn't mean you have 10 year
> experience. Maybe you just repeated the same year 10 times !


### No winners

There is no "bad" programming language, only badly chosen project where
you would use that programming language.

Way to often I hear or read software developers dismiss languages like
Ruby as too slow" not realizing that their strength was never the speed.
Lot of times when you investigate background of those claims you will discover that
someone was trying to fit couple of thousand request to non-[load balanced](https://en.wikipedia.org/wiki/Load_balancing_(computing)) server or had no idea what [caching](https://edgeguides.rubyonrails.org/caching_with_rails.html) is.

> Developer need's to focus to optimize overall performance of
> application with tools like [newrelic](https://newrelic.com) not
> focus on how many loop cycles the language can handle. You are
> building real life applications used by real people.

Often I read developers complaining about languages like Java as too
complex or non-pragmatic for real applications. Those languages were
designed for enterprise use where applications are developed in larger
teams with the desire to run couple of decades. For example banks will choose Java over
Ruby without hesitation. The main reason is that Java almost never drops a
feature (even the bad ideas in languages are supported pretty much
forever once they were released). Ruby feeling less pressure from
enterprise giants can afford to do radical changes that may break code but
introduce better features more often.

If you are working on Google size project with a billion users you may not
want to use Ruby. At the same time if you are at that size it will be
nearly impossible to deal with a monolith application. You would most likely deal
with a form of microservice architecture
where the limitations of the language would be hidden behind smaller
chunks of application running on different servers.

> more on [monolith vs microservice](https://blog.eq8.eu/talk/architecture.html)

It's often to see some major companies move from one language to another
simply because the language no longer make sense for their scenarios.
Years ago Twitter moved away from Ruby because they became this giant
social media monster. Github  needed to refactor parts of it application
to different technology as well. That doesn't mean the original language
was a mistake. It was good choice at the time that helped them to grown
into what they are now.

> This happens not only with programming languages, but also with databases (SQL vs NoSQL), or
> storage solutions (Dropbox moved away from AWS S3), or.. pretty much anything ! It's only programming
> languages people tend to freak out for some reason.

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/one-does-not-language.jpeg)

It's perfectly normal to let go.

> Also we see this countless times with monolith applications becoming
> refactored into microservices when they become too successful.

If you are startup that has only couple of thousands in founding to develop a successful
application from scratch you will burn that money before you ever lunch
the product if you choose something unnecessary complex like Java or even Elixir Phoenix

> Yes Elixir & Phoenix is awesome and really really productive but lets be
> honest here: Rails is much faster for product development speed.

When a brand new startups without previous web-development experience drafts out requirements for they
"revolutionary" project, almost always one of the requirements is: "it needs to
support million users". Because it's obvious that the product will be overnight success.
The ego plays huge role in downfall of many such companies.
Six months after the lunch they will probably have couple of thousand users not more.
It's ok to prepare for a larger traffic but honestly don't kid
yourself.

Investment in supporting overoptimistic expectations
always comes with price of delivery time. You can build same feature in couple of days, weeks
or months depending whether it
needs to withstand traffic from couple of hundreds, thousands or
hundred-thousands of users.

In highly competitive market survive those startups  that are able to adapt
existing features to requirements or
introduce new features quickly. Those that won't be able to keep up fade
in time. Your customers and investors don't care that your application can potentially handle two million
users if the application experience sucks so bad than only couple of
hundred will use it.

Like I said it's always goes from project to project. You may be
building a chat application where Ruby would struggle from day one and
Elixir will dominate. You really need to analyze the bottlenecks of the
project.

Reason why I stick with Ruby (and mainly Rails) is simple: I love to work
on projects where I develop many interesting features rather than I spend months optimizing
the heck out of same one feature. I deliberately choose
projects that are neither too large or too small. Medium size projects are always
fun and challenging just the right way.

So really ask yourself what projects would you want to work on in couple
of years and according to that choose the technology.

### Community

Don't underestimate the size and nature of the community as well. Too small language community
may mean that there are not that many libraries and senior developers
willing to jump to fix the bugs.

Too larger programming language communities may get toxic pretty quickly. It may not sound as a
big deal but I've heard stories where community around certain
language was quite cool and open minded when it was small but as soon as they start
dominating market and gaining
popularity they become more a [political correctness](https://en.wikipedia.org/wiki/Political_correctness) group.
Long story short some decent friendly developers were highly criticized over minor jokes they say on social media.

> I'm not going to name that language as it would just spawn a fire of
> outrage comments from that community. It would just prove my
> point but at the same time I'm not suicidal.

## Languages

Ok lets finally analyze the languages in question:

Ruby is an excellent **Object Oriented programming** language where the primary
goal (in my opinion) is excellent OOP experience and developer happiness.
But speed of the code is not a primary goal.

Ruby on Rails is web framework built upon Ruby language where the
primary goal  is productivity and developer happiness. Speed of the code and
true decoupled OOP experience is not the main goal and socket
connection is ok but not great.

Elixir is excellent **functional programming** language where the primary goal
(in my opinion) is multi-core processing (code speed) and socket
connection support while keeping in mind developer happiness and
reasonable productivity.

Elixir also has Phoenix web framework but more you read about it more you
understand that it's really
collection of  libraries that go hand in hand with Elixir primary goals.

Therefore Elixir vs Ruby vs Ruby on Rails :)

My explanation sounds really similar but devil is in the details:


#### Ruby

More you will learn deeper concepts of object oriented programming (SOLID principles,
object composition, DCI, object oriented decomposition and design, simple design, bounded contexts, DDD, BDD, TDD, etc..)
you will discover how well Ruby works with these concepts.

My opinion is that Ruby is the best language to express
yourself which is more important than some developers tend to admit.
Most of your career you will work in a team. It's important to understand
what you and your colleague try to say with the code (it's called
language after all)

It's often misconception that one cannot build much usable web-applications
with Ruby without Rails. There are several alternatives out there (e.g.: <https://hanamirb.org>,
<http://sinatrarb.com>)

Remember that Ruby is generic programming language not just
web-development language.  During past 9 years I've manage to build several
dozen custom plain Ruby CLI tools for personal use
and companies I've worked for. Applications like [Google Sketchup](https://www.sketchup.com) are
running Ruby and in Japan Ruby is quite a preferred language.

Every now and then you can find an article that Ruby is dead but rarely those articles provide any evidence.
Usually those articles are just developers personal opinions or personal experiences not tackling global data.
Just because one company decides to use other technology doesn't
means that the entire language is dead.

Ruby is very much alive:

* <https://www.tiobe.com/tiobe-index/>
* <https://expertise.jetruby.com/is-ruby-on-rails-dead-2018-edition-407a618dab3a>

...just because Ruby is not the major player doesn't mean that that is bad.
Like I've explained in the community section, it may be actually
preferred state.

Ruby is around for over 25 years now. It will not go away that soon.

> To provide full perspective more often with evidence you read how Rails is falling
> in favor e.g. [this article](https://thenextweb.com/dd/2017/07/26/ruby-rails-major-coding-bootcamp-ditches-due-waning-interest/) on how Rails is being replaced in coding bootcamps.
> I'll get to that in next section

#### Ruby on Rails

Rails a framework (collection of libraries that work well together) but is also a philosophy
on how to write code so you build your
products fast.

Many developers from different languages jump into Rails world without realizing history
and highly different system of values:

* <https://rubyonrails.org/doctrine/> (seriously, read this before becoming Rails developer)
* [RailsConf 2014 - Keynote: Writing Software by DHH](https://www.youtube.com/watch?v=9LfmrkyP81M)
* [DHH on Rails web development - Ruby Rouges podcast Dec. 2017](https://player.fm/series/all-ruby-podcasts-by-devchattv/rr-342-rails-development-and-more-with-david-heinemeier-hansson)
* [DHH on testing](http://testandcode.com/45)

More you read and truly understand intention of Rails you will discover
that the way how authors propose solving problems in 2018 are similar
then those from 10 years ago because they just work. Server rendered
HTML & CSS with sprinkles of JavaScript (and yes RJS is still a thing).

> Proof that that approach works is Basecamp and Shopify revenue (they
> are profitable) and
> developers are happy ([source](https://m.signalvnoise.com/employee-benefits-at-basecamp-d2d46fd06c58))

Many things in Rails are coupled together because they make developer
more productive. For example the way how Rails models write directly to
database or how Frontend is coupled with Backend by default.

Now the biggest trend out there these days are
SPA ([single page applications](https://en.wikipedia.org/wiki/Single-page_application) to which
Rails is not oppose to, Rails authors just prefers not to use SPA.

So you can build SPA frontend with Rails but it will definitely have it's own unique taste.
Only recently [Webpack](https://guides.rubyonrails.org/5_1_release_notes.html#optional-webpack-support)
was introduced to Rails 5 as standard thing.
Up till certain point Rails Asset pipeline (via ruby gems) render SPA lib was common thing.
This created tension between Rails Backend developers and
Frontend only developers that dislike this shotgun marriage of JS an Rails.

Another approach is to just generate Rails application as an [API only](https://edgeguides.rubyonrails.org/api_app.html)
and just have SPA on a completely separate VM but that add extra step
for DevOps and developer team synchronization as you are literally
building two different projects now.

So the point is that Rails prefers not to use SPA but if you want to use
SPA there is at least 3 different ways how to use them now days. This in my
opinion sends a confusing message to Rails newcomers  and also
coding bootcamps that want to teach latest technology
"trends" like SPA. So they just drop off Rails in favor plain JS backend.

> I'll explain why in section reserved for JavaScript language.

That's why it may seen that Rails is dropping in favor. But is not.
Boot camps may just gave up Rails but startups are still choosing it for
new projects.

Remember one thing from this. Just because something is trendy it doesn't mean it's the only way how
to do it. We seen this several years ago with NoSQL databases. There
was a  huge movement on how databases like MongoDB, Casandra, Riak will completely
replace SQL database like MySQL or PostgreSQL. And guess what, they
didn't. There are scenarios where you want to use SQL database there are
scenarios where NoSQL database makes more sense.

Another similar trend these days is Microservices. Same scenario.
Everyone is saying how microservices are the "best practice" how to do
applications in 2018, yet they don't explain you will run out of money before you
release the product.

Anyway, developers may find Rails good for monolith applications but for microservice you
may find it bit too heavy in memory. So you would pick something lighter
like Sinatra.

Same will apply for "best practices of coding", "best practices of
testing", deployments, ...

Every team and project is different. It's up to you to sit down and discuss
with your team how you are going to build the project, what technologies you
want to use and create a plan to which you would stick to. Worst thing you
can do to a project is to change opinions all the time.

So if your main concern is "development speed and ease" then I would go
with Rails without SPA (turbolinks is more powerful than you think).
Especially if it's just one man project (not a team of developers)

If your main goal is to have a separate team of FE only developers that
will write just SPA JavaScript and team of BE developers that will just
provide SPA then go with Rails API only option (`rails new myapp --api`) 

If this API needs to really handle lot of traffic use Rails but maybe
check engine alternatives like [Eventmachine](https://github.com/eventmachine/eventmachine)
That being said, default  Rails Puma webserver is really powerful too. And if you learn to apply
[caching](https://guides.rubyonrails.org/caching_with_rails.html)
properly you can get away with a lot.

If you need mega traffic on your API (like millions of requests) then
Elixir/Phoenix may be much better choice.

> I heard a story in one podcast that in one USA city had their crime
> reporting software running on Rails on like 6 servers on average due
> to heavy traffic. They
> refactored it to Elixir and they have it on 2 servers. They really
> need just one server as average load is 30% but they keep two servers up just in
> case one goes down.

#### Elixir & Phoenix

[Elixir](https://elixir-lang.org/) is an excellent **functional programming language** where primary goal
(in my opinion) is multi-core processing (code speed) and socket
connection support while keeping in mind developer happiness and
reasonable productivity.

Phoenix is web framework built in Elixir language  but more you read about it it's really
collection of  libraries that go hand in hand with Elixir primary goals.
So there is not a major philosophy fight between language and framework.

Elixir is built upon [Erlang VM](https://en.wikipedia.org/wiki/Erlang_(programming_language)) which is
really powerful functional programming language designed for
telecommunication industry where you need to guarantee fault tolerant
system If you have telecommunication tower deep in the forest it better
run on `99.9999999%`.

Other requirement of telecommunication industry that Erlang fulfils is that
one communication tower can take over responsibility
of the other tower so caller don't experience interruptions. Some smart
people noticed that this
distribution capability matches multicore communication requirements and
therefore if you have server machine with lot of CPU cores (like 32, 64
and even more) Erlang will be able to effectively execute your application
on all of them.

> You may argue that there are already lot of OOP languages (like Java or even Ruby) that handles
> multicore. Well newsflash, all OOP languages sucks at multicore
> processing. Yes you can do it but you will not get to results like
> with Functional programming languages.
>
> **Root of all evil is state.** It's supper hard to exchange state
> without mutations between CPU cores. As OOP is functions+state you
> are done.
>
> Functional programming languages don't mutate state that means no side effects.
> (I'm explaining it in more depth [here](https://blog.eq8.eu/article/lessons-learned-from-functional-programming-as-a-ruby-developer.html))

So as Elixir is built upon Erlang this benefit is passed on to it too.

Another important point is socket connections. You see any webserver can
handle request&response type of communication. But when you are building
real time application (e.g. chat, videocall) you need to use "sockets"
that means to hold connection on your server.

Now Rails or Java can handle couple of thousands on one server at once.

Erlang & Elixir can handle like
2 million connections ([Erlang proof](https://blog.whatsapp.com/196/1-million-is-so-2011),
[Elixir proof](https://phoenixframework.org/blog/the-road-to-2-million-websocket-connections)).
Truth be told those are light connections on a huge like 40 core CPU and 128 GB RAM server but
still pretty impressive.

So Elixir and Phoenix are truly awesome. Why is not everyone using it?.
Like I said everything comes with a price. Doh Phoenix and Elixir are
trying to do all the best to help developers be productive, when you are
a technology that promises such a huge scale you need to introduce
practices that need to be decoupled => bit slower for developers.

Good
example of this how a "model" writes to database. Module (with schema) need to call
a changeset, changeset call repository, repository writes to database ([example](http://whatdidilearn.info/2018/01/28/introduction-to-ecto-and-models.html)).
That's 3 manual steps where in Rails you have in in one

Now this 3 steps is much better practice from coding perspective. You
are writing clean decoupled easy to test code. But it will definitely
take more time than with Rails. Rails has no worse coding practice but
focused on productivity faster implementation time.

> It's not a design choice. Functional programming is more explicit way
> of writing code, so you need to pass everything, therefore it
> complicates your code (again that's both good and bad thing)

So if you are building application to withstand  lot of traffic, or application that
will heavily rely on socket communication or you are working for company
that can afford longer delivery time: Go with Elixir and Phoenix

Please watch some talks from Elixir and Phoenix before you jump on the
train. Not to distract you but to get you more motivated and understand
philosophy not just code. Here are two I recommend:

* [Lonestar ElixirConf 2017- KEYNOTE: Phoenix 1.3 by Chris McCord](https://www.youtube.com/watch?v=tMO28ar0lW8)
* [Jose Valim - Idioms for building distributed fault-tolerant applications with Elixir](https://www.youtube.com/watch?v=MMfYXEH9KsY]


#### JavaScript

At least minimum level of  JavaScript knowledge is essential for frontend web-development when
one is building fullstack side project. So given or take JavaScript
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
one programming language. No wonder that coding bootcamps prefere to learn JS these days as it's a simpler for
them.

But like I've said in previous sections that's
not true forever. Sooner or later you will reach a point in your
professional life where you will have to add more tools to your toolbox.

> Also when developing BE with Node JS you will work with "event loop"
> which is bit different philosophy than you would be used to with
> synchronous Ruby MRI. If you have no idea what I'm talking about and
> you understand Ruby try to play around with
> [eventmachine](https://github.com/eventmachine/eventmachine) it's
> similar principle than Node JS.

One more benefit of JavaScript is also that is supported language on
many FaaS providers (serverless) like [AWS Lambda](https://aws.amazon.com/lambda/).


### One last note

There are many many things you need to learn (There are still many
things I need to learn) No mater what you choose be prepared you will
have to read, study and implement many coding practices in your free
time otherwise you will suck no mater what is the language.

Recommended topics to start with for next couple of years:

* try both object oriented and functional programming
* SOLID principles, DCI, Simple design, Object composition
* learn design patterns (e.g. [M. Fawler](https://martinfowler.com/eaaCatalog/))
* DDD (domain driven design)
* Bounded Contexts
* why to use of TDD and BDD and why to stop using TDD and BDD
* try FE development even if you  are BE developer
* learn how to be a professional (e.g.book [Clean Coder](https://www.amazon.com/Clean-Coder-Conduct-Professional-Programmers/dp/0137081073))
* try microservices, then stop using them.

> Techniques like TDD or SOLID principles are good, but they are not unquestionable truth (Yes I said it!)
> Don't be religious about them. Definitely worth learning and to
> apply them when needed, definitely not worth breaking a stable productive team because of
> them. Much better practice is to be a good team member.

Most importantly work on your own project in a free time. Do the
experiments there not on your job project. Bring the knowledge to your job.

Worst attitude developer can have is "I'm not going to learn in my free
time, I'll just learn on the spot in my company". Web developer is a
lifestyle not a job. Deal with it!

