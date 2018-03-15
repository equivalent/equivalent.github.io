---
layout: talk_post
categories: talk
title:  "Architecture"
description: "LRUG talk on Architecture in Web Applications. Monolith, Microservices and Serverless from perspective of Ruby developer."
disq_id: talk-3
---


* **>>[TALK Video](https://skillsmatter.com/skillscasts/11594-lrug-march)<<**


* [Slides](https://docs.google.com/presentation/d/15-o7Cos6UAmYn0AW0lfyBvyyC3_LdE7kF6TnxXBE3p0/edit)
  (short link <https://bit.ly/arch-lrug-slides>)
* [LRUG - March 2018 Meeting](http://lrug.org/meetings/2018/march/)
* [Skillsmatter meeting](https://skillsmatter.com/meetups/10709-lrug-march)

Aim of the talk: Show different ways how a developer can think about
product.

Conclusion:

Microservices and Serverless are all really cool Architectural
strategies but if you are
productive with monolith and don't have any scaling or team organization
issue stick with Monolith. Monolith is not dead.

You really need to have a good reason to reach for microservices /
serverless and if you do I hope this talk will be helpful :)




## Contact

* mail: equivalent@eq8.eu
* website: www.eq8.eu
* twitter: [equivalent8](https://twitter.com/equivalent8)
* github: [equivalent](https://github.com/equivalent)


## Resources

### Monolith


> Note: When it comes to Monolith a I'm fan of both good object oriented practices
> (e.g.: SOLID, object composition, abstractions ...) and pragmatic principles
> as proposed by DHH (minimize abstractions, stick with conventions, ...)
>
> I'm fan of both "Majestic Monolith" and "FE / BE split with JSON API in the middle"
>
> They all work, but team need to agree on one strategy form day one
> and stick with it. Changing your
> mind on how to develop stuff every other day is the true reason why your
> software is a mess.


### Majestic Monolith Architecture

* [DHH - Majestic Monolith](https://m.signalvnoise.com/the-majestic-monolith-29166d022228)
* [Ruby Rouges podcast featuring DHH on Monolith development](https://devchat.tv/ruby-rogues/rr-342-rails-development-david-heinemeier-hansson)
* [How DHH Organizes His Rails Controllers](http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/)

### Object Composition Monolith Architecture

* [Robert C Martin - Clean Architecture and Design](https://www.youtube.com/watch?v=Nsjsiz2A9mg)
* [David West OOP is Dead! Long Live OODD!](https://www.youtube.com/watch?v=RdE-d_EhzmA)

My articles related to this topic:

* <https://blog.eq8.eu/article/rails-association-relation-arel-magic.html>
* <https://blog.eq8.eu/article/policy-object.html>
* <https://blog.eq8.eu/article/rspec-json-api-testing.html>
* <https://blog.eq8.eu/article/lessons-learned-from-functional-programming-as-a-ruby-developer.html>

> Note: I recommend every Ruby developer to try in depth Elixir and Phoenix
> framework. This will make you better OOP developer. Yes it's a functional language but the way how
> processes work and send messages inbetween each other strangely
> mimics how messages are sent from one object to another in OOP
> languages.

Recommended paid resources:

* [Clean Coders screencasts (PAID)](https://cleancoders.com)
* [Ruby Tapas screencasts (PAID)](rubytapas.com)
* [Both Books from Sandi Metz](https://www.sandimetz.com/products/)

> Learning real OOP is a long road  and requires some investment


### Monolith with Bounded Contexts

Articles:

* [Bounded Context by Martin Fowler](https://martinfowler.com/bliki/BoundedContext.html)
* [Modular monolith with Rails engines](https://medium.com/@dan_manges/the-modular-monolith-rails-architecture-fb1023826fc4)


Talks:

* [Elixir Phoenix 1.3 by Chris McCord](https://youtu.be/tMO28ar0lW8?t=15m31s) - good
  resource explaining Bound Contexts from a perspective of a functional
  programming language Elixir (Phoenix framework).

### Other monolith approaches

* [The Many Meanings of Event-Driven Architecture • Martin Fowler](https://www.youtube.com/watch?v=STKCRSUsyP0&t=2436s)
* [José Valim - Idioms for building distributed fault-tolerant applications with Elixir](https://www.youtube.com/watch?v=MMfYXEH9KsY)

### JWT Token

* [100% Stateless with JWT (JSON Web Token) by Hubert Sablonnière](https://www.youtube.com/watch?v=67mezK3NzpU)

### Microservices

Articles:

* [What are Microservices by M.Fowler](https://martinfowler.com/microservices/#what)
* [Two pizza teams](http://blog.idonethis.com/two-pizza-team/)
* [Is EC2 Container Service the Right Choice on AWS?](https://medium.com/containermind/is-ec2-container-service-the-right-choice-on-aws-3d419d96a390)

Talks:

* [Mastering Chaos - A Netflix Guide to Microservices by Josh Evans](https://www.youtube.com/watch?v=CZ3wIuvmHeM)
* [Microservices by Martin Fowler](https://www.youtube.com/watch?v=wgdBVIX9ifA)
* [Containerized Micro Services on AWS](https://www.youtube.com/watch?v=rcjXQxRgMj0)
* [Chad Fowler -  From Homogeneous Monolith to Heterogeneous Microservices Architecture](https://www.youtube.com/watch?v=sAsRtZEGMMQ)

Books:

* [Building Microservices](http://shop.oreilly.com/product/0636920033158.do)

### Serverless

* [Serverless framework](https://serverless.com)
* [What is Serverless](https://martinfowler.com/articles/serverless.html)

Ruby as FaaS:

* [AWS Lambda and Ruby](https://aws.amazon.com/blogs/compute/scripting-languages-for-aws-lambda-running-php-ruby-and-go#toc_10)
* [Using Ruby in AWS Lambda](http://www.adomokos.com/2016/06/using-ruby-in-aws-lambda.html)
* [Traveling Ruby](https://github.com/phusion/traveling-ruby)
* [2017 RubyHACK, James Thompson: "Serverless" Ruby on AWS](https://www.youtube.com/watch?v=3NdFzhIvUQA)
* [Serverless framework - Ruby](https://github.com/stewartlord/serverless-ruby)
* [AWS Lambda JRuby](https://github.com/plainprogrammer/aws-lambda-jruby)

AWS Lambda:

* [Running Web Server on AWS Lambda (Express JS)](https://www.youtube.com/watch?v=Cuh_gtFX5gI) (I'm not recommending this approach)
* [Build serverless app with AWS Lambda and Auth0](https://auth0.com/blog/building-serverless-apps-with-aws-lambda/)

Books:

* [Serverless Single Page Apps](https://pragprog.com/book/brapps/serverless-single-page-apps)


### Please help request FaaS providers to support Ruby

<https://www.serverless-ruby.org>

Also please `:+1` these discussions if you can:

* <https://bit.ly/ruby-azure>  [Direct link](https://forums.aws.amazon.com/thread.jspa?messageID=758159)
* <https://bit.ly/ruby-lambda> [Direct link](https://github.com/Azure/Azure-Functions/issues/705)

### Serverless on Kubernetes

If you want to be your own FaaS provider. And yes you can run Ruby.

* <https://github.com/kubeless/kubeless>
* <https://www.youtube.com/watch?v=AxZuQIJUX4s>
* <https://www.youtube.com/watch?v=1QZ6x_8h8qY>

