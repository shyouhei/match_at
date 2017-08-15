#! /your/favourite/path/to/gem
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

# :HACK: avoid namespace pollution
path      = File.expand_path 'lib/match_at/version.rb', __dir__
content   = File.read path
version   = Module.new.module_eval <<-'end'
  MatchAt = Module.new
  eval content, binding, path
end

Gem::Specification.new do |spec|
  spec.name        = 'match_at'
  spec.version     = version
  spec.author      = 'Urabe, Shyouhei'
  spec.email       = 'shyouhei@ruby-lang.org'
  spec.summary     = 'implements String#match_at'
  spec.description = 'implements String#match_at'
  spec.homepage    = 'https://github.com/shyouhei/match_at'
  spec.license     = 'MIT'
  spec.extensions  = %w'ext/match_at/extconf.rb'
  spec.files       = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r'^(test|spec|features|samples)/')
  }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'stackprof'
  spec.add_development_dependency 'test-unit', '>= 3'
  spec.add_development_dependency 'yard'
  spec.required_ruby_version =    '>= 2.0.0'
end
