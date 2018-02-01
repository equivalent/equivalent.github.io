# Remote working ? Use VPN !

Remote working is being more and more popular amongst more and more
companies.  But one thing we must not to forget is security of your
internet connection.

You see lot of employers/employees misunderstood the term "remote
working" as "home office". This is not true. When you are working
remotely you are working "remote" from the main office. You can be
working from home, but you may be working from coffee place down the
road, from public library, from shared work space...

In all this places you need to connect to internet and this is what can
get you and your company to trouble.

In this article I will not go to too much details explaining why is WiFi not
safe. You can read plenty of articles / youtube videos explaining
"packet sniffing" and "man in the middle attack".

> Original draft of this article was including all those things
> explained but the article was 1000 lines and I still didn't get to the
> point that I want to make in this article


### VPN a security solution


Thie is how your typical network looks like when you want to connect to
a server (e.g. load a web page, ssh connection)

```
                              (packet sniffing attacker)


[myLaptop] - - - - WiFi- - - - \

[myCoworker] - - - WiFi- - - -[WiFi Router]------[Ethernet/Optic Cable]-------[ISP]--[node]-[node]-[Internet]-[node]-[node]---[ServerYouWantToConnectTo]
                                       \
                                     (MIM attacker)
[myCoworker] - - - WiFi- - - - /

```


You and your co-workers are
connected to a WiFi router (or access point). Router is then connected to ISP (internet
service provider - those guys you pay money every month for internet).
Your request is shared around several nodes till it reaches it's
destination on the desired server

So when you make a **request** (load a page) it will travel entire way
to the server and server will then send **response** all the way to your
laptop via all those points of communication.





So here are the questions you need to ask before you connect you click
"connect" on the WiFi access point:

#### Who is in control of that router ? Do you trust that person?

That person may have configured the network in such way he can read your
requests and pass them on to other nodes, and read responses from your
server to your laptop.


> Man in the Middle attack, google it

One more thing. This can be happening on **any node** of the
communication!  But
is not likely that someone will break into the ISP building and tap the
main switch to read your gossip on poorly encrypted websites.

#### How well is the Router password secure?

If the password is "jimmy123" then the  answer is: not much.

If there is no password




#### Could anyone be sniffing for your packets ?

For packet sniffing you don't even need to be connected to the router







Let me just say if you are connected to a WiFi router that you are not
in controll you

### What could go wrong ?

First of all you need to understand how networks works

##### security concern 1 - man in the middle

Whew you are in on a public work place (coffee place, library) you  probably
won't be able to plug into your laptop an ethernet cable.

> And even if you could do that, would you ? WiFi is way more comfortable.

Therefore you
would connect to the internet via WiFi router within that
building:



```

[myLaptop] - - - - - WiFi- \

[someone else] - - - WiFi- - --[WiFi Router] ------ ... ----[Internet]

[someone else] - - - WiFi- /       |
                                   |
                                [admin - someone else]

```

Now here is a first question, Who is that "Someone Else" ? Your and
(Everyone else) trafic is going via the same router. Whoever is in
control of that router can be "man in the middle attack" intercepting
your packets:



```

[myLaptop] - - - - - WiFi- \

[someone else] - - - WiFi- - --[WiFi Router] -- [man in the middle]---- ... ----[Internet]
                                                 /
[someone else] - - - WiFi- /       |            /
                                   |           /
                                [admin -  someone else]

```


##### security concern 2 - packet sniffing

Ok let say you know who the admin is, he's a great guy he would never do
such a thing. Well you still have a situation that someone else can
"sniff" for the packets in the air (after all WiFi is transfering packets via
waves in the air):



```
( ( ( ( [someone else SNIFF SNIFF] ) ) )
  ( ( ( ( () ) ) ) ) ) )
      ( ( () ) ) )
  ( ( ( ( () ) ) ) ) ) )
( ( ( ( [myLaptop] ) ) ) ) )- - - - - WiFi- - - - - -  \
   ( ( ( ( () ) ) ) ) ) )                               \
       ( ( () ) ) )                                      \
   ( ( ( ( () ) ) ) ) ) )                                 \
( ( ( ( [someone else SNIFF SNIFF] ) ) ) - - - WiFi- - --[WiFi Router]  ----[Internet]
   ( ( ( ( () ) ) ) ) ) )
       ( ( () ) ) )

```

As you can see for Sniffing packets you don't even have to be part of
the network, you can just be outside of the building in a black van (of course) running
Sniffing application

> Really it's not that hard. You don't have to be experienced hacker/cracker.
> Any kid can download [BlackTrack linux](https://www.backtrack-linux.org) (Linux distribution designed
> for pen-testing company networks) and run some of the built in tools.
>
> Speaking of which, when I've first moved
> to Prague for a jobhunt, me and my friend we were living in rented out
> campus room (as we were broke and it was the cheapest option). The campus had WiFi but they refused to give us the
> access. Only the students were allowed to use it. Friend downloaded
> Blacktrack, run some tools over night next morning we had WiFi access.
> This was like 10 years ago, and security since then improved a lot but
> still gives you a glimps of "where is a will there is a way"
>
> B.T.W that campus was one of the best IT & Networking school campus of Prague.



##### security concern 3 - ISP

But even if you trust everyone all around you there is still ISP that
can monitor you.

The full picture of how your laptop is making a resquent to server looks
like this:

```

[myLaptop] - - - - WiFi- - - - \

[myCoworker] - - - WiFi- - - -[WiFi Router]------[Ethernet/Optic Cable]-------[ISP]--[node]-[node]-[Internet]-[node]-[node]----[ServerYouWantToConnectTo]

[myCoworker] - - - WiFi- - - - /

```

As you can see there are lot of nodes there till your request (from your
laptop) will get to the server.

Who is your ISP (internet service provider) ?
* Are they trust worthy ?
* Do they keep logs?  (e.g. if you download copyright item torrents ISP will send you a letter on how owner will sue you) `<3`

> Not to mention ISPs thx to Net Neutrality abolished, ISP will be able to blacklisting
> any websites in USA [more on that](https://www.youtube.com/watch?v=bd27PgNJNIo)

You need to realize all your traffic goes via ISP or other nodes that
can be monitered.


##### security concern 4 - how you transfer

So ok let say you are connected to your router via ethernet cable. But
you live in e


One other thing people living in remote locations don't understand is
that the entire trip (and the media transfering your packets ) to your server matters ...a lot !


### What about my home network ?

Your is in 98% cases safe. Usually if you are living in well know
neighbourhood several years surounded with friendly elderly people or
live in a cabin  or desert several miles from nearest neighbour
I almost certain no-one will sniff for your packets.

But If you just moved into multi-story building or to neigborhood packed
with houses close to each other you are is the same risk as if in coffee
place.




### VPN, The Security solution




In last couple of mont
