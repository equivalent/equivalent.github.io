---
layout: article_post
categories: article
title:  "Ruby on Rails - Bounded contexts via interface objects"
disq_id: 50
description:
  Rails Bounded contexts via interface objects
  Article in progress
---

This article is not finished yet !!!

> This article is still in progress !!! Lot of developers asked me for a
> preview of this article that's why I'm releasing it unfinished.
>
> please check on later once it's officially relased


In this Article I'll show you how to organize business
classes in [Ruby on Rails](https://rubyonrails.org/) so your application
can benefit from [Bounded Contexts](https://martinfowler.com/bliki/BoundedContext.html)
while still keep Rails conventions and best practices.

> This will be really pragmatic solution. I'll enlist and compare other Rails Bounded Context
> solutions at the bottom of the article.

As this topic is quite extensive article is separated in following
sections:

1. Bounded Contexts general theory
2. Bounded contexts via interface objects (theory around my solution)
3. Example Rails code
4. Summary
5. Comparison of other ways how to do Bounded Contexts in Rails

If something too long to read please just skip to section you are interested in.

## Bounded Contexts general theory

The point of [Bounded Contexts](https://martinfowler.com/bliki/BoundedContext.html) is to organize the code
inside **business boundaries**.

For example let say we are building an education application
in which you have `students` `teachers` and their `works` inside `lessons`.

So two natural bounded contexts may be:

* `classroom` bounded context
  * creation of lesson
  * adding students to the lesson
  * students receiving email notifications when they are invited to lesson
  * students uploading their work files
  * teachers receiving email notifications when they new work is uploaded to  lesson
  * publish  the lesson (all the works)
* `public_board` bounded context
  * once the lesson is published students can comment on each other works
  * students will be notified when new comments are added on their work

As you can imagine both bounded contexts are interacting with same
"models" (Student, Teacher, Work, Lesson) just around different
business perspective.

That means you would place all related code for `classroom` to one folder
and all related code to `public_board` to that folder.

So what you are ultimately trying to achieve is organize code into layers similar to this:

![bounded contexts example 1](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/bounded-context-1.jpg)

> You may be ask: "Are Bounded Contexts something like namespaces e.g.: `/admin` or `/api` ?"
> No, no their not. Think about it this way: "every Bounded Context have
> its own code for admin e.g. `classroom/admin`, `public_board/admin`".
> It's the same structure like if you are building microservices (every
> microservice is own independent application pulling only data
> needed from other microservices that it needs)
> If you don't understand what I mean by that please watch talk
> [Web Architecture choices & Ruby](https://skillsmatter.com/skillscasts/11594-lrug-march)([mirror](https://www.youtube.com/watch?v=xhEyUYTuSQw)) or
> [Microservices • Martin Fowler](https://www.youtube.com/watch?v=wgdBVIX9ifA)

## Bounded contexts via interface objects

Solution that I'll demonstrate here is **not** advising to split every
Rails app class into separate bounded contexts
but rather creating pragmatic partial bounded contexts only around business logic classes.

This means we will keep `views`, `models`,`controllers`, as they are in `app/views`
`app/controllers`, `app/models`.

We will move only the `app/jobs/*`, `app/mailers/*`, (and other business logic like  `app/services/*`)
into bounded contexts.

> I'm explaining why in Summary part of the article down at the bottom

Therefore we will end up with something like:

```
app
  models
    lesson.rb
    student.rb
    work.rb
    teacher.rb
    comment.rb
  controllers
    lessons_controller.rb
    works_controller.rb
  views
    # ...
  bounded_contexts
    classroom
      lesson_creation_service.rb
      student_mailer.rb
      teacher_mailer.rb
      reprocess_work_thumbnail_job.rb
      work_upload_service.job
    public_board
      comment_posted_job.rb
      student_mailer.rb
```


![bounded contexts example 1](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/bounded-context-1.jpg)


But we will go even further. We will introduce **interface objects**
that will allow us to call related bounded contexts from perspective of
the Rails models.

Something like:

```ruby
student = Student.find(123)
student = Student.find(654)

# Lesson creation
lesson = teacher.classroom.create_lesson(students: [student1, student2], title: "Battle of Kursk")

# Student Work file upload
some_file = File.open('/tmp/some_file.doc')
lesson.classroom.upload_work(student: student1, file: some_file)

work = Work.find(468)
work.work_interaction.post_comment(student: student2, title: "Great work mate!")
```

## Code Example

In traditional Ruby on Rails application you organize code in this way:

```
app
  controllers
    works_controller.rb
    lessons_controller.rb
  model
    teacher.rb
    work.rb
    lesson.rb
    student.rb
    comment.rb
  mailer
    student_mailer.rb
    teacher_mailer.rb
  services
    lesson_creation_service.rb
    work_upload_service.job
  jobs
    reprocess_work_thumbnail_job.rb
lib
  generate_thumbnail_from_pdf.rb
```


> Let's not argue if service objects are "traditional" for Rails.
> As was pointed out by article [How DHH Organizes His Rails Controllers](http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/)
> well organized job objects and controllers can replace all features of service objects.
> But this is not a topic of my article. For sake of saving time let's
> assume service objects are Rails feature


Now the issue is that you are jamming multiple perspective of business
logic into single class. Take for example `StudentMailer` we would jam
responsibility for sending email when "student was invited to lesson"
and "student received comment on his published work"

```ruby
class Classroom::StudentMailer < ApplicationMailer

  # invitation to new lesson
  def new_lesson(lesson_id:, student_id:)
    @lesson = Lesson.find_by!(id: lesson_id)
    @student = Student.find_by!(id: student_id)

    mail(to: @student.email, subject: %{New lesson "#{@lesson.title}"})
  end

  # new comment on student's work
  def comment_received(comment_id:)
    @comment = Comment.find_by!(id: comment_id)

    to = comment.work.student.email
    subject = "Student #{comment.author.id} posted comment on your work #{comment.work.id}"

    mail(to: to, subject: subject })
  end
end
```

Now this is quite simple example but more the business logic grows








Now you cauld jam the busines related update/create methods to be in `app/service` folder (so called Service Objects) and
authentication methods to `app/policy` (e.g. [Policy Objects](https://blog.eq8.eu/article/policy-object.html), [Pundit Gem](https://github.com/varvet/pundit)

But still you will organize  along the "type of classes" not really do
any organization around "business logic"


```
app
  controllers
    students_controller.rb
    works_controller.rb
    lessons_controller.rb
    comments_controller.rb
  model
    teacher.rb
    work.rb
    lesson.rb
    student.rb
    comment.rb
  jobs
    process_works_job

lib
  some_custom_lib_for_correcting_student_age.rb
  some_custom_lib_for_for_correcting_comment_.rb
```



Now theory of bounded


If you do this right you will end up with a folder structure like this:


Theory of bounded context is to organize your code according to busines
logic. 

```
app
  views
    baskets
      show.erb
  models
    product.rb
    basket.rb
  controllers
    baskets_controller.rb
  bounded_context
    discounts
      basket_value.rb
      basket_serializer.rb
      twenty_percent_discount.rb
      compare_competitors_prices_discount.rb
      evil_corp_pricing_gateway.rb
```

While keeping Rails models & controllers  first class citizens of
application not violiting any Rails best practices. Bounded context
classes will be invoked directly from within the related model:

```ruby
@basket.discount.overal_discount
@basket.discount.total_price_after_discount
@basket.discount.as_json
```


```ruby
student1 = Student.find(123)
student2 = Student.find(654)

# Lesson creation

class Classroom::LessonCreationService
  def call(students:, title:)
    lesson = Lesson.create!(title: title)

    students.each do |student|
      lesson.students << student
      Classroom::StudentMailer
        .new_lesson(lesson_id: lesson.id, student_id: student.id)
        .deliver_later
    end

    lesson
  end
end

class Classroom::StudentMailer < ApplicationMailer
  def new_lesson(lesson_id:, student_id:)
    @lesson = Lesson.find_by!(id: lesson_id)
    @student = Student.find_by!(id: student_id)

    mail(to: @student.email, subject: %{New lesson "#{@lesson.title}"})
  end
end

lesson = Classroom::LessonCreationService.call(students: [student1, student2], title: "Battle of Kursk")

# Student Work file upload
some_file = File.open('/tmp/some_file.doc') # or this could be passed from controller as params[:file]
work = Work.create(lesson: lesson, file: some_file, student: student1 )

##
lesson.classroom.deliver_lesson

work = Work.find(468)
work.work_interaction.post_comment(student: student2, title: "Great work mate!")
```



## Conclusion

We (me and my colleagues) are writing Backend code for JSON API Rails application
following way for over a year
(dating since late 2017) 

Furthermore I also use this pattern for  personal projects in which the server renders HTML ([majestic monolith](https://m.signalvnoise.com/the-majestic-monolith/))

These applications are quite extensive in business logic. Therefore
consider the following pattern only when building long running large
applications where long term maintainability is the key.

Let me epmasize one more thing: This article took more over a year to be finilized. Behind it are
countless hours of learning, comparing and trying solutions. Lot of real team development. Trial
and error so you have final form that I'm 100% confident with.


## Other ways to do Bounded Contexts in Rails


> You can think about this folders  as Microservices where every responsibility lives in its own application
>
> If you don't understand what I mean by that please watch talk
> [Web Architecture choices & Ruby](https://skillsmatter.com/skillscasts/11594-lrug-march)([mirror](https://www.youtube.com/watch?v=xhEyUYTuSQw)) or
> [Microservices • Martin Fowler](https://www.youtube.com/watch?v=wgdBVIX9ifA)

There are several good resources on Bounded Contexts in Ruby on Rails. Some
are calling for [splitting Rails into Bounded Context via Rails
Engine](https://medium.com/@dan_manges/the-modular-monolith-rails-architecture-fb1023826fc4)

> basically you create own Rails Engine `classroom` and another
> engine `public_board`. That means controllers and models are in
> their own Rails engine

Some are calling for [event architecture](https://www.youtube.com/watch?v=STKCRSUsyP0) to achieve
Bounded context like in [Domain Driven Design in Rails book](https://blog.arkency.com/domain-driven-rails/)

> book is about creating isolated bounded contexts and then interacting in-between
> those bounded contexts via publishing events. Check out their [gem](https://railseventstore.org/) for more info.

Although I really like and respect all these suggestions they all are
trying to introduce something that Rails was not designed for. In my
opinion they are
trying to introduce new way of thinking so much that junior developers
cannot catch up with them.

Biggest benefit of Rails is that it is trying to be as friendly as
possible to junior and senior developers by following certain conventions. And although those
conventions may be annoying/limiting for large applications they form
basis of community and framework that is still dominating in Ruby world
for more then 15 years.

Other good references explaining Bounded context

* [Elixir Phoenix 1.3 by Chris McCord - bounded context in Phoenix](https://youtu.be/tMO28ar0lW8?t=15m31s)


