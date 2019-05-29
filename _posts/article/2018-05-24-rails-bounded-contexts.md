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
while still keep Rails conventions and best practices. Solution is also friendly for junior developers.

As this topic is quite extensive article is separated in following
sections:

1. What are Bounded Contexts
2. Bounded Contexts via Interface Objects (theory around my solution)
3. Example Rails code
4. Summary
5. Comparison of other ways how to do Bounded Contexts in Rails

If something too long to read please just skip to section you are interested in.

## What are Bounded Contexts

The point of [Bounded Contexts](https://martinfowler.com/bliki/BoundedContext.html) is to organize the code
inside **business boundaries**.

For example let say we are building an education application
in which you have `students` `teachers` and their `works` inside `lessons`.
After `lesson` is done (published) other students can `comment` each other
works.

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
models (Student, Teacher, Work, Lesson) just around different
business perspective.

That means you would place all related code & classes for `classroom` to one folder
and all related code to `public_board` to that other folder. As for the shared
models you would create own representation of those models in give
bounded context `Classroom::Student` (ideally with own DB table)
and `PublicBoard::Student` (ideally with own DB table)

> I'll not go into details of how you might sync up  data in those
> cases as this article is not working with this solution.

So what Bounded Contexts are ultimately trying to achieve is organize code into separate business boundaries:

![bounded contexts example 1](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/bounded-context-1.jpg)

**In order to fetch data or call functionality of different bounded context you would call
interfaces of those bounded contexts** (you should not call directly classes hidden inside Bounded Context)

> You may be ask: "Are Bounded Contexts something like namespaces e.g.: `/admin` or `/api` ?"
> No, no their not. Think about it this way: "every Bounded Context have
> its own code for admin e.g. `classroom/admin`, `public_board/admin`".
> It's the same structure like if you are building microservices (every
> microservice is own independent application pulling only data
> needed from other microservices) Microservices are the ultimate
> respresentation of Bounded Contexts.
> If you don't understand what I mean by that please watch talk
> [Web Architecture choices & Ruby](https://skillsmatter.com/skillscasts/11594-lrug-march)([mirror](https://www.youtube.com/watch?v=xhEyUYTuSQw)) or
> [Microservices • Martin Fowler](https://www.youtube.com/watch?v=wgdBVIX9ifA)


## Bounded contexts via interface objects

(our solution)

Let me first clarify:

* solution in this article will **not** introduce any requirements for database split or table split for different models or bounded contexts
* solution that I'll demonstrate here is **not** advising to split every Rails application class into separate bounded contexts
* we will also **not** separate controllers to different bounded contexts

> Full explanation why can be found in "Summary" part of the article at the bottom.
> I'll also enlist and compare other Rails Bounded Context solutions.

We will rather create more pragmatic **bounded contexts only around business logic classes** and we will work with same models in same database tables (as would traditional Rails application)

This means we will keep `views`, `models`,`controllers`, as they are in `app/views`
`app/controllers`, `app/models`.

We will move only the `app/jobs/*`, `app/mailers/*`, (and other business logic like  `app/services/*`)
into bounded contexts.

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


![bounded contexts example 1](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/bounded-context-2.jpg)


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
work.public_board.post_comment(student: student2, title: "Great work mate!")
```

## Code Example


While keeping Rails models & controllers  first class citizens of
application not violiting any Rails best practices. Bounded context
classes will be invoked directly from within the related model:


```ruby
ActiveRecord::Schema.define(version: 2019_05_22_134007) do
  create_table "lessons" do |t|
    t.string "title"
    t.bigint "teacher_id"
    t.boolean "published", default: false
  end

  create_table "students" do |t|
    t.string "email"
  end

  create_table "students_lessons" do |t|
    t.bigint "lesson_id"
    t.bigint "student_id"
  end

  create_table "teachers" do |t|
    t.string "email"
  end

  create_table "works" do |t|
    t.bigint "lesson_id"
    t.bigint "student_id"
  end

  create_table "comments" do |t|
    t.bigint "work_id"
    t.bigint "student_id"
    t.string "content"
  end
end
```

```ruby
# app/models/students.rb
class Student < ActiveRecord::Base
  has_many :works
  has_many :comments
  has_and_belongs_to_many :lessons
end
```

```ruby
# app/models/teacher.rb
class Teacher < ActiveRecord::Base
  has_many :lessons

  def classroom
    @classroom ||= Classroom::TeacherInterface.new(self)
  end
end
```

```ruby
# app/models/lesson.rb
class Lesson < ActiveRecord::Base
  belongs_to :teacher
  has_many :works
  has_and_belongs_to_many :students

  def classroom
    @classroom ||= Classroom::LessonInterface.new(self)
  end
end
```

```ruby
# app/models/work.rb
class Work < ActiveRecord::Base
  belongs_to :student
  belongs_to :lesson
  has_many :comments

  def classroom
    @classroom ||= Classroom::WorkInterface.new(self)
  end
end
```

```ruby
# app/models/comment.rb
class Comment < ActiveRecord::Base
  belongs_to :student
  belongs_to :work
end
```

So far standard Rails stuff, now let's start introducing Bounded
Contexts

#### Bounded Contexts


```ruby
# config/application.rb
module MyApplication
  class Application < Rails::Application
    # ...
    config.autoload_paths << Rails.root.join('app', 'bounded_contexts')
    # ...
  end
end
```

```ruby
# app/bounded_contexts/classroom/teacher_interface.rb
module Classroom
  class TeacherInterface
    attr_reader :teacher

    def initialize(teacher)
      @teacher = teacher
    end

    def create_lesson(students:, title:)
      Classroom::LessonCreationService.call(students: students, title: title, teacher: teacher)
    end
  end
end
```

```ruby
# app/bounded_contexts/classroom/lesson_creation_service.rb
module Classroom
  module LessonCreationService
    extend self

    def call(students:, teacher:, title:)
      lesson = Lesson.create!(title: title, teacher: teacher)

      students.each do |student|
        lesson.students << student
        notify_student(student, lesson)
      end

      lesson
    end

    private

    def notify_student(student, lesson)
      Classroom::StudentMailer
        .new_lesson(lesson_id: lesson.id, student_id: student.id)
        .deliver_later
    end
  end
end
```

```ruby
# app/bounded_contexts/classroom/student_mailer.rb
class Classroom::StudentMailer < ApplicationMailer
  def new_lesson(lesson_id:, student_id:)
    @lesson = Lesson.find_by!(id: lesson_id)
    @student = Student.find_by!(id: student_id)

    mail(to: @student.email, subject: %{New lesson "#{@lesson.title}"})
  end
end
```


```ruby
# app/bounded_contexts/classroom/lesson_interface.rb
module Classroom
  class LessonInterface
    attr_reader :lesson

    def initialize(lesson)
      @lesson = lesson
    end

    def upload_work(student:, file:)
      Classroom::WorkUploadService.call(student: student, lesson: lesson, file: file)
    end

    def publish
      lesson.published = true
      lesson.save!
    end
  end
end
```

```ruby
# app/bounded_contexts/classroom/work_upload_service.rb
module Classroom
  module WorkUploadService
    extend self

    def call(student:, lesson:, file:)
      lesson = Lesson.create!(title: title, teacher: teacher)

      work = lesson.works.new(student: student)
      work.file = file
      work.save!

      notify_teacher(work, teacher)
      schedule_reprocess_work_thumbnail(work)
      work
    end

    private

    def notify_teacher(work, teacher)
      Classroom::TeacherMailer
        .new_work_uploaded_to_lesson(work_id: work.id, teacher_id: teacher.id)
        .deliver_later
    end

    def schedule_reprocess_work_thumbnail(work)
      Classroom::ReprocessWorkThumbnailJob.perform_later(work_id: work.id)
    end
  end
end
```

```ruby
# app/bounded_contexts/classroom/teacher_mailer.rb
module Classroom
  class TeacherMailer < ApplicationMailer
    def new_work_uploaded_to_lesson(work_id:, teacher_id:)
      @work = Work.find_by!(id: work_id)
      @teacher = Teacher.find_by!(id: teacher_id)

      mail(to: @teacher.email, subject: %{New work was added "#{@work.id}"})
    end
  end
end
```

```ruby
# app/bounded_contexts/classroom/reprocess_work_thumbnail_job.rb
module Classroom
  class ReprocessWorkThumbnailJob < ActiveJob::Base
    queue_as :classroom

    def perform(work_id:)
      work = Work.find_by!(id: work_id)

      # do something with the work
    end
  end
end
```


```ruby
# app/bounded_contexts/public_board/work_interface.rb
module PublicBoard
  class WorkInterface
    attr_reader :work

    def initialize(work)
      @work = work
    end

    def can_post_comment?(current_user:)
      work.lesson.published && current_user.is_a?(Student)
    end

    def post_comment(student:, content:)
      comment = @work.comments.create!(student: student, content: content)
      PublicBoard::CommentPostedJob.perform_later(comment_id: comment.id)
      PublicBoard::StudentMailer.new_comment_on_your_work(comment_id: comment.id).deliver_later
      comment
    end
  end
end
```

```ruby
# app/bounded_contexts/public_board/comment_posted_job.rb
module Classroom
  class CommentPostedJob < ActiveJob::Base
    queue_as :public_board

    def perform(comment_id:)
      comment = Comment.find_by!(id: comment_id)
      # do something with the comment
    end
  end
end
```

```ruby
# app/bounded_contexts/public_board/student_mailer.rb
module Classroom
  class StudentMailer < ActiveJob::Base

    def new_comment_on_your_work(comment_id:)
      comment = Comment.find_by!(id: comment_id)
      # ...
    end
  end
end
```


#### controllers

```ruby
class LessonsController < ApplicationController

  # POST /lessons
  def create
    students = Student.where(id: params[:student_ids])
    lesson = teacher.classroom.create_lesson(students: students, title: params[:title])
    # ...
  end

  # POST /lessons/345/publish
  def publish
    lesson = Lesson.find(params[:lesson_id])
    lesson.classroom.publish
    # ...
  end
end
```

```ruby
class WorksController < ApplicationController

  # POST /lesson/123/works
  def create
    lesson = Lesson.find(params[:lesson_id])
    current_user_student = Student.find(session[:id])

    lesson.classroom.upload_work(student: current_user_student, file: params[:file])
    # ...
  end
end
```

```ruby
class CommentsController < ApplicationController

  # POST /works/123/comments
  def create
    work = Work.find(params[:work_id])
    current_user_student = Student.find(session[:id])

    if work.public_board.can_post_comment?(current_user: current_user_student)
      work.work_interaction.post_comment(student: current_user_student, content: params[:content])
      # ...
    end
  end
end
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


