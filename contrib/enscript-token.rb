#!/usr/bin/env ruby
#--
# Ruwiki
#   Copyright � 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# This token by Javier Fontan <jfontan@pc3d.cesga.es>.
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++

require "open3"

class Ruwiki::Wiki::CodeColor < Ruwiki::Wiki::Token
  def self.rank
    0
  end

  def self.regexp
    %r<\{\{\{(?::(\w+)\b)?(.*?)\}\}\}>m
  end

  def replace
    cap = @match.captures

    if cap[0].nil?
      language = "ruby"
    else
      language = cap[0]
    end

    text = cap[1]

    i, o, e = Open3.popen3("enscript -B --color=emacs -Whtml -E#{language} -o -")
    i.print text
    i.close

    re_script = %r{(<pre>.*?</pre>)}mio
    c = o.readlines[1..-1].join("\n")
    re_script.match(c).captures[0]
  end

  def self.post_replace(content)
    content.gsub!(%r{<pre>\n}im, '<pre class="rwtk_CodeColor>')
    content.gsub!(%r{\n</pre>}im, '</pre>')
    content.gsub!(%r{<font color="(.+?)">}im, '<span style="color: \1">')
    content.gsub!(%r{</font>}im, '</span>')
    content.gsub!(%r{<B>}i, '<b>')
    content.gsub!(%r{</B}i, '</b>')
    content
  end
end
