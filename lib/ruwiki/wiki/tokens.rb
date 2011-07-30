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
  # The base Token class. All Token classes must inherit from Token and
  # *must* implement the following methods:
  #
  # [self.regexp]   The regular expression that the Token will be replacing.
  # [replace]       The mechanism for replacing the Token with the desired
  #                 results.
  #
  # Token classes <i>should</i> implement the following method:
  # [self.rank]          Default: <tt>5000</tt>. Affects the sort order.
  #                      Must return an integer.
  #
  # Token classes <i>may</i> implement the following methods:
  # [restore]            Restores the token without replacement. Implements
  #                      the results of the escape character. NOTE: each
  #                      Token class is responsible for its own restore.
  #                      Tokens that are anchored to the beginning of a line
  #                      are the most likely to need to reimplement this.
  # [self.post_replace]  Performs any necessary massaging of the data. See
  #                      the implementation of Ruwiki::Wiki::Lists for more
  #                      information.
class Ruwiki::Wiki::Token
  @tokenlist = []
  @sorted    = false

  class << self
      # Tokens should define rank if they must be first or last in
      # processing. Otherwise, they are sorted in the order defined.
    def rank
      5000
    end

      # The Wiki parsing routine uses Token.tokenlist to determine the
      # tokens that are processed, and the order in which they are
      # processed. See Token.rank for more information.
    def tokenlist(sort = true)
      if sort and not @sorted
        @tokenlist.sort! { |aa, bb| aa.rank <=> bb.rank }
        @sorted = true
      end
      @tokenlist
    end

    def inherited(child_class) #:nodoc:
        # Make the child class post_replace a blank function because we
        # don't want to propogate the currently defined post_replace. The
        # current post_replace is specific to Token_Base only.
      class << child_class
        def self.post_replace(content)
          content
        end
      end

      @tokenlist << child_class
      @sorted = false
    end

      # The replacement regular expression.
    def regexp
      /TOKEN_(\d*)/o
    end
  end

    # All Token classes must match this header signature if they define
    # #initialize.
    #
    # [match]     The MatchData object for this Token.
    # [project]   The project being processed.
    # [backend]   The backend for the wiki. This is used to determine if
    #             the page or project exists. The object passed must
    #             respond to #project_exists?(project) and
    #             #page_exists?(page, project).
    # [script]    The URI to the script.
    # [message]   The message hash for localized messages.
    # [title]     The title of the Wiki.
  def initialize(match, project, backend, script, message, title)
    @match    = match
    @project  = project
    @backend  = backend
    @script   = script
    @message  = message
    @title    = title
  end

    # The replacement method. Uses @match to replace the token with the
    # appropriate values.
  def replace
    "TOKEN_#{@match[1]}"
  end

      # Restores the token without replacement. By default, replaces
      # "dangerous" HTML characters.
  def restore
    Ruwiki.clean_entities(@match[0])
  end

    # The content may need massaging after processing.
  def self.post_replace(content)
    content
  end
end

  # Load the tokens from the ruwiki/wiki/tokens directory.
tokens_dir = 'ruwiki/wiki/tokens'

$LOAD_PATH.each do |path|
  target = "#{path}/#{tokens_dir}"
  if File.exists?(target) and File.directory?(target)
    Dir::glob("#{target}/*.rb") do |token|
      begin
        require token
      rescue LoadError, TypeError
        nil
      end
    end
  end
  Ruwiki::Wiki::Token.tokenlist.each { |tk| tk.freeze }
end
