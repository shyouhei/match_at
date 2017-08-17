#! /your/favourite/path/to/ruby
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil; ruby-indent-level: 2 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Copyright (c) 2017 Urabe, Shyouhei
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction,  including without limitation the rights
# to use,  copy, modify,  merge, publish,  distribute, sublicense,  and/or sell
# copies  of the  Software,  and to  permit  persons to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
#         The above copyright notice and this permission notice shall be
#         included in all copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY  KIND, EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This  library  is  a  Refinements.    By  `use`-ing  it  your  namespace  has
# `String#match_at`.
module MatchAt
  refine String do

    # Match, at the exact `pos`-th character.
    #
    # This is much like String#index / String#rindex, but does not try to shift
    # forward / backward to search for other matching points.
    #
    # ```ruby
    # "foobar".match_at(/o/,    0) # => nil
    # "foobar".match_at(/o/,    1) # => #<MatchData "o">
    # "foobar".match_at(/o/,    2) # => #<MatchData "o">
    # "foobar".match_at(/o/,    3) # => nil
    # "foobar".match_at(/bar/, -3) # => #<MatchData "bar">
    # ```
    #
    # @param rexp [Regexp]    pattern to match.
    # @param pos  [Integer]   character index.
    # @return     [MatchData] successful match
    # @return     [nil]       failure in match
    def match_at rexp, pos = 0
      MatchAt.match_at self, rexp, pos
    end

    # Similar to #match_at, but returns true/false instead of MatchData.
    #
    # @param          (see #match_at)
    # @return [true]  successful match
    # @return [false] failure in match
    def match_at? rexp, pos = 0
      MatchAt.match_at? self, rexp, pos
    end
  end

  refine Regexp do

    # Match, at the exact `pos`-th character.
    #
    # This is much like Regexp#match, especially the arguments are identical.
    # However the way it matches the target string is different.
    #
    # ```ruby
    # /o/.match_at("foobar",    0) # => nil
    # /o/.match_at("foobar",    1) # => #<MatchData "o">
    # /o/.match_at("foobar",    2) # => #<MatchData "o">
    # /o/.match_at("foobar",    3) # => nil
    # /bar/.match_at("fo0bar", -3) # => #<MatchData "bar">
    # ```
    #
    # @param str [String]    target string.
    # @param pos [Integer]   character index.
    # @return    [MatchData] successful match
    # @return    [nil]       failure in match
    def match_at str, pos = 0
      MatchAt.match_at str, self, pos
    end

    # Similar to #match_at, but returns true/false instead of MatchData.
    #
    # @param          (see #match_at)
    # @return [true]  successful match
    # @return [false] failure in match
    def match_at? str, pos = 0
      MatchAt.match_at? str, self, pos
    end
  end
end

require 'match_at/match_at'

__END__

# Dialogue about regular expression matching at the beginning of a String:
#
# 2017/06/30 [14:50] @shyouhei onig_matchってなんでRuby側に出してないんだっけ
# 2017/06/30 [15:00] @naruse   特に理由はない気がする
# 2017/06/30 [15:00] @naruse   strscanみたいなの作るときに欲しいかもね
# 2017/06/30 [15:08] @shyouhei もう少し詳しくいうと正規表現を引数にとって毎回 `/\A#{re}/.match(…)` とか書くみたいなアホっぽいことをするときに欲しくなる。
# 2017/06/30 [15:08] @naruse   問題は名前だな
# 2017/06/30 [15:09] @shyouhei Regexp#match(str, -1)とか
# 2017/06/30 [15:09] @shyouhei -1はあんまりか
# 2017/06/30 [15:09] @nobu     String#rindex(re, -1)
# 2017/06/30 [15:10] @shyouhei match_at_the_beginning: true
# 2017/06/30 [15:10] @naruse   -1は末尾以降でマッチに見える
# 2017/06/30 [15:10] @nobu     引数間違えたかも
# 2017/06/30 [15:10] @nobu     0だな
# 2017/06/30 [15:11] @nobu     rindex(prefix, 0)はstart_with?ができるまではよく使ったidiom
# 2017/06/30 [15:11] @naruse   0でも先頭以降でマッチっていう現在の挙動と同じに見えるよ
# 2017/06/30 [15:11] @nobu     r
# 2017/06/30 [15:12] @shyouhei なるほど?
# 2017/06/30 [15:13] @naruse   ふむ?
# 2017/06/30 [15:14] @naruse   それっぽい動きをしているな
# 2017/06/30 [15:16] @naruse   idiomとしてはそれでよさそうだけど、start_with?で正規表現許した方がよさそうかな
# 2017/06/30 [15:16] @shyouhei start_with?に正規表現はわかりやすくていいですね
#
# @see https://ruby.slack.com/archives/C02A3SL0U/p1498801851550590
