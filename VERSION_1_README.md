# Version 1

I've learned a lot in the past ~3 years of LazyResource and its predecessors.
The biggest realization is that the #where syntax, stolen from ActiveRecord,
was a mistake. It leaked way too often because I was writing a RESTful API
library using relation database language. There were also a number of issues
with things under the covers that, in 2 years, I've realized were a mistake
(namely, the heavy reliance on modules). I'd like to correct all of that, which
is what Version 1 aims to do.

## What the rewrite is not?

Well, it's not actually a total rewrite. There's plenty of code in LazyResource
that works fine and isn't particular ugly. My main aims are to clean up the
class hierarchy, correct the errors in syntax, and clean up some of the
particularly gnarly bits of codes (like anything in the Attributes module).

## What's changing?

Mainly, to the outside world, just the interface for fetching resources. Instead
of #where, #order, #limit, and so on, you have #route, #params, #headers, #body,
and #method. #route and #params take the place of the various #where methods.

One of the major issues I've run into in actual production code is in generating
routes. There are a number of hacks added to LazyResource in the past to deal
with this, but all of them are just that: hacks. I want to approach this with a
way of doing it correctly (or at least not as annoyingly), which means being
more explicit about the routing code.

Instead of having the routes magically generated from your #where call, you can
instead explicitly pass a route that should be used. So this

```ruby
@posts = Post.where(company_id: 123)
@post.from = "news"
```

becomes this

```ruby
Post.route("/companies/123/news")
```

or if you have a param that has \_id in it, you can pass it without having to
explicitly write a route that stores that in the params by doing

```ruby
Post.route(company_id: 123).params(user_id: 123)
```

In case you do want the magic, just don't call route. #params can work
the same as #where.
