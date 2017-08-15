# match_at: implementation of `String#match_at`, `Regexp#match_at`

Regular expressions are useful but current Ruby lacks one feature: to match a regular expression against particular position of a String.  This functionality _is_ in fact implemented in the regular expression engine, but have not been exposed so far.  This is a very tiny extension library to give you that feature.

## What is match_at and why you need it

Your basic usage of regular expressions in ruby is like this:

```ruby
md = /bar/.match "foobarbaz" # => #<MatchData "bar">

# 0 1 2 3 4 5 6 7 8
# f o o b a r b a z
#       |---|
#       match

md.pre_match  # => "foo"
md.post_match # => "baz"
md.begin(0)   # => 3
md.end(0)     # => 5
```

Here, the regular expression matches at the middle of the parameter string.  Normal behaviour of a regular expression is to search for leftmost & longest string that fits the pattern.

But that is not always what you want.  When you want to split a long string into a series of tokens, it is usually not optimal to scan again and again from the beginning.

```
... f o o b a r b a z ...
    ---> |
         suppose you have already scanned here.
         you want to start from this exact position...
```

This kind of situation has formerlly been tackled by the StringScanner standard library.  That is still okay today.  However strscan is not "fluent"; for instance you can't get a MatchData with it.

Luckily as I wrote above the functionality is already there.  This library is to let you use it.

```ruby
md = /bar/.match_at "foobarbaz", 3 # => #<MatchData "bar">

# 0 1 2 3 4 5 6 7 8
# f o o b a r b a z
#       |---|
#       match

md.pre_match  # => "foo"
md.post_match # => "baz"
md.begin(0)   # => 3
md.end(0)     # => 5
```
