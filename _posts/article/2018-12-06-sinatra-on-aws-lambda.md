---
layout: article_post
categories: article
title:  "Ruby Sinatra on AWS Lambda"
disq_id: 55
description:
  AWS Lambda now Supports Ruby natively. That means we can build
  serverless applications with the language we all love. Not only that
  doh. You can run small Sinatra microservices with AWS serverless
  approach and in this article we will have a look how/why
---

29.11.2018 [AWS Lambda announced official Ruby Support](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/).
That means we all can build Serverless applications (or FaaS scripts)
with the language that we love.

AWS in the [same article](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/)
also provided quite decent step by step manual for creating AWS Lambda
functions but also how to run [Sinatra](http://sinatrarb.com/)
application on AWS Lambda with a code sample project [AWS Lambda - serverless Sinatra app example](https://github.com/aws-samples/serverless-sinatra-sample)

In this article I will explain in more depth how this works and how it is even
possible to run Sinatra (and other small Rack applications) on AWS Lambda

> Originally I wanted to create step by step Sinatra - AWS Lambda manual from
> scratch but guys at AWS done really good job with the mentioned example repo. I couldn't produce
> anything that would add more value.

### AWS Lambda - how it works

[Lamda](https://aws.amazon.com/lambda/) is a product from AWS (Amazon
Web Services) in which you run code without provisioning or managing servers.
You pay only for the compute time you consume - there is no charge when your code is not running.

> I literally copy paste this definition from their website

So what it means is you write Ruby script, you load the code to AWS Lamda and
then when you trigger it. That will:

1. spin up Lambda function (this is when you start being charged $$$)
2. run your script code (e.g. write some record to DB, process some payment, send an email)
3. kill Lamda (this is when you will stop being charged)

The price of execution depends of how much memory you allocate to the
Lambda execution and how long it will took to finish. If **Lambda spin up + code execution + die** took 100 ms you will pay
only  for 100ms (And we are talking like $0.0001 per execution, check [pricing](https://aws.amazon.com/lambda/pricing/))

> Serverless folks will hate me for using the words "spin up". In reality you are not spinning up anything as the AWS Lamda function is Function as a Service (FaaS)
> therefore provisioning is taken care of by AWS. What I mean by "spin up"  is trigger the lamda function.
>
> BUT this "trigger" is more complex than "run a script". You see there
> is a concept of "cold starts" of Lambda executions; meaning  the Lambda function
> was not executed for a while, it will take bit longer to execute
> compared to often executed Lambda functions. So it  really feels like Spin
> up.
>
> That's why I'll keep on using this term trough out the article in sense of special kind
> of "trigger"

**If you need to run the same Lambda function 1000 times you have to
trigger up 1000 separate Lamba executions** of the same functionality.

> Imagine that if you wanted to do the same thing with VM servers, you would have to lunch 1000 VMs
> and execute same one script on every one of those VMs and then kill the individual VMs after script finished. Lambda
> is obviously much faster on spin up but principle of execution is
> similar.

The important part is that you are not able to cache anything in the memory
for next execution (e.g. no point using Ruby memoize `||=`)

Yes there is some level of "next Lambda execution will be faster"
because first Lamda had a "cold start" but in principle you cannot rely
on this. Good example what I'm talking about is described in article [AWS Lambda cold starts](https://theburningmonk.com/2018/01/im-afraid-youre-thinking-about-aws-lambda-cold-starts-all-wrong/)

> Also this depends on what programming lang you use in AWS Lambda. Java
> would would notice this far more than  Python or Ruby.

Bare with me I'll get to the point why all this is important in a
minute.

### Plugging in API Gateway

AWL Lambda is just a engine. It only executes your Ruby script. There is
no routing inside as you would have in Ruby on Rails application.

What you need to do is to plug routing solution to your individual
Lambda Functions.

AWS provides another product called [AWS API Gateway](https://aws.amazon.com/api-gateway/) in which you define
what route will call what AWS Lambda / Lambdas

e.g.:

* GET `/users` => call `list_users` AWS Lambda function
* POST `/users` => call `create_user` AWS Lambda function and pass the JSON request body to it e.g `{"first_name": "Tomas"}`

But you can also configure proxy routes with `*` where anything
(POST/GET/PUT/DELETED can be directed to a particular Lambda Function

So technically speaking you can have

* `* /users/*` pointing to one AWS Lambda 
* `* /products/*` pointing to another AWS Lambda 
* `* /cusstomer_support/*` pointing to another AWS Lambda 

### Sinatra

So now we understand how API Gateway and AWL Lambda works I can finally
explain how is it even possible that you can run Sinatra on AWS Lambda?


You need to realize that you are not actually running web-server (or App-server) like you would
normally do with Sinatra or Ruby on Rails.

When you for example run `rails server` in Ruby on Rails project on your laptop you actually start
Puma/Webrick app server that listens on a port (e.g. 3000 or 8080) and
when request hit's the server/localhost this app server will call the
[Rack](https://github.com/rack/rack) application == your Ruby code,
Ruby routes -> Ruby controllers -> Ruby Model -> ...

> Similar way Sinatra works. You call `ruby app.rb` you will start
> Webrick Ruby server. ->Browser->Webrick->Rack->Sinatra routes & code


Therefore in the [AWS Lambda Sinatra example](https://github.com/aws-samples/serverless-sinatra-sample)  you don't lunch any App server (no Puma, no Webrick). The
AWS API Gateway is your APP server. 

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/2018-12-aws-sinatra-lambda.jpg)


**You just need to call the [Rack](https://github.com/rack/rack) part of Sinatra with your AWS Lambda function passing the request params/body from the AWS API Gateway**

That's being done [here](https://github.com/aws-samples/serverless-sinatra-sample/blob/master/lambda.rb#L45) in the source code ([mirror](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/lambda.rb#L45) )

> I'll describe the entire flow of the code at the bottom of this
> article


That Brings us to the main point of how this works:

**AWS API Gateway will proxy any/every request to this one AWS Lambda that will spin up and execute one route of the Sinatra application. Once the response is returned to the API Gateway Lambda will die.**

That means if this Sinatra app needs to receive 1000 requests, it will
spin up 1000 AWS Lambda Functions.



### Use case

So is this solution good ?

Well every tool has it's purpose. You will
use hammer to nail a nail to a wall but to fix your laptop hammer would
not be the best tool.

Originally this "run your webserver in Lambda" feature was introduced to
help web developers to migrate existing microservices to AWS without
the need of full rewrite to Lambda scripts

> Sinatra is not the first "tiny web server" that AWS Lambda introduced. You can do AWS Lambda [Expres JS](https://aws.amazon.com/blogs/compute/going-serverless-migrating-an-express-application-to-amazon-api-gateway-and-aws-lambda/) web apps for
> quite some time now.

So the feature was introduced more like a migration help HOWEVER when
used with caution it can be stable in production **for microcervices**.

And you can always mix and match with regular serverless flow of simple AWS Functions

e.g.:

* `post /users/` pointing to lambda function
* `put /users/123` pointing to different lambda function
* `* /products` pointing to one Sinatra Microservice on AWS Lambda function
* `* /basket` pointing to another Sinatra Microservice on AWS Lambda function
* `* /cusstomer_support` pointing to another Sinatra Microservice on AWS Lambda function


This brings us to to next big question:

### Can I run Ruby on Rails on AWS Lambda ?

Sinatra is build on top of Rack. [Rails](https://rubyonrails.org/) is build on top Rack. So there should not be any problem running entire Ruby on Rails project on AWS Lambda right ?

![](https://raw.githubusercontent.com/equivalent/myWallpapers/master/fun/its-a-trap.jpg)

You need to realize that serverless is next level of Microservices. It's
not designed for Monolith Applications. And although Rails can be used
to some degree in Microservices it's primary goal is Monolith ( e.g.: [Majestic Monolith by D.H.H](https://m.signalvnoise.com/the-majestic-monolith-29166d022228))

> I have entire 40 min talk about  [Monolith, Microservices & Serverless Ruby](https://skillsmatter.com/skillscasts/11594-lrug-march)

By definition Rails have lot of tools and dependencies that are freaking
awesome in long running Monolith but makes zero sense in Serverless.

If you manage to make AWS Lambda work with Rails you would discover that
every request is taking ridiculous amount of time because every request
would have to load entire Rails and your code to memory .

You need to have your Lambda functions to die fast otherwise you will
have slow response times and pay much more than you would with server
running 24h a day.

Same would apply for large Sinatra Applications. 

If your Sinatra application has 5  - 10 routes  and maybe 5 small extra
gems then you are fine. If your Sinatra application is a monolith with like 100 routes
with 50 dependencies then you will have same problem as with Rails. 

So no Rails is not Designed for this. Don't do it even if you
theoretically could.

### Full flow of AWS Sinatra Serverless example

##### API Gateway is called

1. Browser makes request to `https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/Prod/hello-world`
2. Global AWS recognize subdomain domain `xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com` and pass it to your AWS API Gateway product
3. AWS API Gatway see that you are using the `/Prod` pipeline  (as you can have /Stage or /Prod) so it will pass the request to the `Prod` stage
4. In `Prod` Stage will recognize you are calling `/hello-world` now the [project](https://github.com/aws-samples/serverless-sinatra-sample) has configured a API Gateway to pass all request `*` to AWS Lambda executing our Sinatra app. Therefore this Proxy will trigger our Sinatra AWS Lamda for any request (`/`, `/hello-world`, `/api/feedback`) any method (`GET`, `POST`,...)
5. AWS Lamda is executed. 


#### AWS Lambda Execution

AWS lambda calls [lambda.rb](https://github.com/aws-samples/serverless-sinatra-sample/blob/master/lambda.rb) `#handler` method which does the following:

1. set Rack enviroment variables related to the replication of appserver call


```ruby
# ...
  env = {
    "REQUEST_METHOD" => event['httpMethod'],
    "SCRIPT_NAME" => "",
    "PATH_INFO" => event['path'] || "",
    "QUERY_STRING" => event['queryStringParameters'] || "",
    "SERVER_NAME" => "localhost",
    "SERVER_PORT" => 443,

    "rack.version" => Rack::VERSION,
    "rack.url_scheme" => "https",
    "rack.input" => StringIO.new(event['body'] || ""),
    "rack.errors" => $stderr,
    }
```

> [source](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/lambda.rb#L25)

form this the most important is the setting of the `PATH_INFO` => what will end up in Sinatra routing and the  `"rack.input"` => what will become our `params`

2. as aleady mentioned we call The Rack application 

```ruby
# ...
    status, headers, body = $app.call(env)
# ...
```

> [source](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/lambda.rb#L45)

From this point the
[app/server.rb](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/app/server.rb)


3. Sinatra will carry on application execution as normal Sinatra webserver. That means it will find the [get '/hello-world'](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/app/server.rb#L22) route and execute the code.


One important point to mention here is the `before` block we do at the
top of the file ([here](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/app/server.rb#L4))

```ruby
before do
  if request.body.size > 0
    request.body.rewind
    @params = Sinatra::IndifferentHash.new
    @params.merge!(JSON.parse(request.body.read))
  end
end
```

As in first step we were setting the `ENV` variable `rack.input` with
the body of API Gateway, Sinatra would not effectively parse the body as
it would be in raw JSON format. That's why this block will parse the
JSON to hash as would Sinatra normally do with HTTP form params

This will be needed when you do `POST /api/feedback`

4. and finally `lambda.rb` will pass the response of the rack
   application back to API Gateway via return value
   [here](https://github.com/equivalent/serverless-sinatra-sample/blob/2018-12-eq8article-sinatra-on-aws-lambda/lambda.rb#L68)


### Links

* [Monolith, Microservices & Serverless Ruby](https://www.youtube.com/watch?v=fn17nojYa-I) [Mirror](https://skillsmatter.com/skillscasts/11594-lrug-march)
* <https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/>
* <https://github.com/aws-samples/serverless-sinatra-sample>

### Discussion:

* <http://www.rubyflow.com/p/hbi870-ruby-sinatra-on-aws-lambda> 
* <https://www.reddit.com/r/ruby/comments/a5f7as/sinatra_on_aws_lambda/>

