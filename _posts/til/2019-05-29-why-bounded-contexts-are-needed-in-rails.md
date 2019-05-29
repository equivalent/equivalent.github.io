---
layout: til_post
title: "Why you should consider Bounded Contexts in Rails"
categories: til
disq_id: til-63
---

> This TIL note is extension of arguments for my article [Ruby on Rails - Bounded contexts via interface objects](https://blog.eq8.eu/article/rails-bounded-contexts.html)


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
    work_upload_service.rb
  jobs
    reprocess_work_thumbnail_job.rb
lib
  generate_thumbnail_from_pdf.rb
```


> Let's not argue if service objects are "traditional" for Rails.
> As was pointed out by article [How DHH Organizes His Rails Controllers](http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/)
> well organized job objects and controllers can replace all features of service objects.
> But this is not a topic of my article. For sake of saving time let's
> assume service objects are Rails feature. My point is you would get
> into same problems that I'll desribe here even without Service Objects


Now the issue is that you are jamming multiple perspectives of business
logic into single class. Take for example `StudentMailer`  We can jam
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

This is quite simple example but more the business logic grows you
will end up with bigger mess.

Now you could introduce separate Mailer classes for different scenarios
or introduce more service objects in `app/service` folder, introduce [Policy Objects](https://blog.eq8.eu/article/policy-object.html) in `app/policy`, jobs in `app/jobs` but you will  still  organize application along the "type of classes" not really
around "business logic" boundaries.

You will end up with something like this:

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
    parent_mailer.rb
    evaluation_student_mailer.rb
    lesson_student_mailer.rb
    teacher_mailer.rb
  services
    lesson_creation_service.rb
    work_upload_service.rb
    create_work.rb
    call_up_parents.rb
    invite_teacher.rb
    evaluate_student_marks.rb
    update_lesson.rb
    pull_students_from_3rd_party.rb
    invite_parent_of_a_student.rb
    reprocess_lesson.rb
  jobs
    reprocess_work_thumbnail_job.rb
    notify_parents_of_new_work.rb
    notify_studnet_of_new_lesson.rb
lib
  generate_thumbnail_from_pdf.rb
  recalculate_curency.rb
```

Does this appear like a mess ? Yes that's the point!  There is no
organization around business logic on folder level. The classes are well named but they
don't tell you anything about their place in the world.

Lets take the same mess and translate it to Bounded Contexts


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
  bounded_contexts
    parentship
      invite_parent_of_a_student.rb
      call_up_parents.rb
      parent_mailer.rb
    classroom
      lesson_creation_service.rb
      create_work.rb
      work_upload_service.rb
      update_lesson.rb
      reprocess_lesson.rb
      reprocess_work_thumbnail_job.rb
      notify_parents_of_new_work.rb
      notify_studnet_of_new_lesson.rb
      student_mailer.rb
      generate_thumbnail_from_pdf.rb
    term_evaluation
      recalculate_curency.rb
      student_mailer.rb
      evaluate_student_marks.rb
    school_management
      teacher_mailer.rb
      invite_teacher.rb
      pull_students_from_3rd_party.rb
```

Now without knowing what those classes really do you can kindof see the
business values the Application is trying to achieve



[link to main article](https://blog.eq8.eu/article/rails-bounded-contexts.html)

