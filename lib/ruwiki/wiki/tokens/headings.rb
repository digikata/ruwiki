#--
# Ruwiki
#   Copyright � 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
class Ruwiki
  class Wiki
      # Converts headings.
    class Headings < Ruwiki::Wiki::Token
#     def self.rank
#       5
#     end

      def self.regexp
        %r{^\\?(=+)\s+(.*)}
      end

      def restore
        @match[0][1 .. -1]
      end

      def replace
        level   = @match.captures[0].count("=")
        content = @match.captures[1]
        level   = 6 if level > 6
        %Q(<h#{level} class="rwtk_Headings">#{content}</h#{level}>)
      end

      def self.post_replace(content)
        content.gsub!(%r{(</h\d>)\n}) { |m| %Q(#{$1}\n<p class="rwtk_Paragraph">) }
        content.gsub!(%r{(</h\d>)</p>\n<p>}) { |m| %Q(#{$1}\n<p class="rwtk_Paragraph">) }
        content.gsub!(%r{<p[^>]*>(<h\d[^>]*>)}, '\1')
        content.gsub!(%r{(</h\d>)</p>}, '\1')
        content
      end
    end
  end
end
