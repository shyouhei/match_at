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

require_relative 'test_helper'
require 'match_at'

class TC001_MatchAt < Test::Unit::TestCase
  using MatchAt

  sub_test_case String do

    sub_test_case '#match_at' do
      data(
        "empty"     => ['',       /foo/,  0, false, ''],
        "foobar,0"  => ['foobar', /o/,    0, false, ''],
        "foobar,1"  => ['foobar', /o/,    1, true,  'o'],
        "foobar,2"  => ['foobar', /o/,    2, true,  'o'],
        "foobar,3"  => ['foobar', /o/,    3, false, ''],
        "foobar,4"  => ['foobar', /o/,    4, false, ''],
        "foobar,-3" => ['foobar', /bar/, -3, false, ''],
        "\\A,0"     => ['foobar', /\A/,   0, true,  ''],
        "\\A,1"     => ['foobar', /\A/,   1, false, '']
      )

      test '#match_at' do |(str, rexp, pos, match, expected)|
        if match then
          assert_nothing_raised do
            assert_equal expected, str.match_at(rexp, pos)[0]
          end
        else
          assert_nothing_raised do
            assert_nil str.match_at(rexp, pos)
          end
        end
      end

      test 'expects Regexp' do
        assert_raise TypeError do
          "foo".match_at("bar", 0)
        end
      end

      test 'expects Numeric' do
        assert_raise TypeError do
          "foo".match_at(/foo/, /bar/)
        end
      end

      test 'expects finite' do
        assert_raise RangeError do
          "foo".match_at(/foo/, Float::INFINITY)
        end
      end

      test 'encoding mismatch' do
        subject = "\u337B".encode("CP932")
        assert_raise Encoding::CompatibilityError do
          subject.match_at(/\u337B/, 0)
        end
      end

      test 'return value' do
        str     = "foo\nbar\nbaz\n"
        subject = str.match_at(/^(.+)$/, 4)
        assert_not_nil subject
        assert_equal 4, subject.begin(0)
        assert_equal 7, subject.end(0)
        assert_equal ["bar"], subject.captures
      end
    end

    sub_test_case '#match_at?' do
      data(
        "empty"     => ['',       /foo/,  0, nil],
        "foobar,0"  => ['foobar', /o/,    0, nil],
        "foobar,1"  => ['foobar', /o/,    1, 1],
        "foobar,2"  => ['foobar', /o/,    2, 1],
        "foobar,3"  => ['foobar', /o/,    3, nil],
        "foobar,4"  => ['foobar', /o/,    4, nil],
        "foobar,-3" => ['foobar', /bar/, -3, nil],
        "\\A,0"     => ['foobar', /\A/,   0, 0],
        "\\A,1"     => ['foobar', /\A/,   1, nil]
      )

      test '#match_at?' do |(str, rexp, pos, expected)|
        assert_nothing_raised do
          assert_equal expected, str.match_at?(rexp, pos)
        end
      end

      test 'expects Regexp' do
        assert_raise TypeError do
          "foo".match_at?("bar", 0)
        end
      end

      test 'expects Numeric' do
        assert_raise TypeError do
          "foo".match_at?(/foo/, /bar/)
        end
      end

      test 'expects finite' do
        assert_raise RangeError do
          "foo".match_at?(/foo/, Float::INFINITY)
        end
      end

      test 'encoding mismatch' do
        subject = "\u337B".encode("CP932")
        assert_raise Encoding::CompatibilityError do
          subject.match_at?(/\u337B/, 0)
        end
      end
    end
  end

  sub_test_case Regexp do

    sub_test_case '#match_at' do
      data(
        "empty"     => ['',       /foo/,  0, false, ''],
        "foobar,0"  => ['foobar', /o/,    0, false, ''],
        "foobar,1"  => ['foobar', /o/,    1, true,  'o'],
        "foobar,2"  => ['foobar', /o/,    2, true,  'o'],
        "foobar,3"  => ['foobar', /o/,    3, false, ''],
        "foobar,4"  => ['foobar', /o/,    4, false, ''],
        "foobar,-3" => ['foobar', /bar/, -3, false, ''],
        "\\A,0"     => ['foobar', /\A/,   0, true,  ''],
        "\\A,1"     => ['foobar', /\A/,   1, false, '']
      )

      test '#match_at' do |(str, rexp, pos, match, expected)|
        if match then
          assert_nothing_raised do
            assert_equal expected, rexp.match_at(str, pos)[0]
          end
        else
          assert_nothing_raised do
            assert_nil rexp.match_at(str, pos)
          end
        end
      end

      test 'expects String' do
        assert_raise TypeError do
          /foo/.match_at(/bar/, 0)
        end
      end

      test 'expects Numeric' do
        assert_raise TypeError do
          /foo/.match_at("foo", /bar/)
        end
      end

      test 'expects finite' do
        assert_raise RangeError do
          /foo/.match_at("foo", Float::INFINITY)
        end
      end

      test 'encoding mismatch' do
        target = "\u337B".encode("CP932")
        assert_raise Encoding::CompatibilityError do
          /\u337B/.match_at(target, 0)
        end
      end

      test 'return value' do
        str     = "foo\nbar\nbaz\n"
        subject = /^(.+)$/.match_at(str, 4)
        assert_not_nil subject
        assert_equal 4, subject.begin(0)
        assert_equal 7, subject.end(0)
        assert_equal ["bar"], subject.captures
      end
    end

    sub_test_case '#match_at?' do
      data(
        "empty"     => ['',       /foo/,  0, nil],
        "foobar,0"  => ['foobar', /o/,    0, nil],
        "foobar,1"  => ['foobar', /o/,    1, 1],
        "foobar,2"  => ['foobar', /o/,    2, 1],
        "foobar,3"  => ['foobar', /o/,    3, nil],
        "foobar,4"  => ['foobar', /o/,    4, nil],
        "foobar,-3" => ['foobar', /bar/, -3, nil],
        "\\A,0"     => ['foobar', /\A/,   0, 0],
        "\\A,1"     => ['foobar', /\A/,   1, nil]
      )

      test '#match_at?' do |(str, rexp, pos, expected)|
        assert_nothing_raised do
          assert_equal expected, rexp.match_at?(str, pos)
        end
      end

      test 'expects String' do
        assert_raise TypeError do
          /foo/.match_at(/bar/, 0)
        end
      end

      test 'expects Numeric' do
        assert_raise TypeError do
          /foo/.match_at("foo", /bar/)
        end
      end

      test 'expects finite' do
        assert_raise RangeError do
          /foo/.match_at("foo", Float::INFINITY)
        end
      end

      test 'encoding mismatch' do
        target = "\u337B".encode("CP932")
        assert_raise Encoding::CompatibilityError do
          /\u337B/.match_at(target, 0)
        end
      end
    end
  end
end
