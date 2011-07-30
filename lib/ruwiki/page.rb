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
require 'ruwiki/exportable'

  # The page class for Ruwiki. The page defines the data and meta-data for a
  # page.
class Ruwiki::Page
  include Ruwiki::Exportable

  exportable_group 'ruwiki'
    # Returns the content version of the page. If the page has a greater
    # content version than this version of Ruwiki does, we should probably
    # throw an exception, because attempting to save such a page will cause
    # a loss of data. Immutable.
    #
    # Class:: +ruwiki+
    # ID::    +content-version+
  attr_reader :content_version
  exportable :content_version
    # Returns the version of Ruwiki from which this page was generated.
    # Informational only. Immutable.
    #
    # Class:: +ruwiki+
    # ID::    +version+
  attr_reader :ruwiki_version
  exportable :ruwiki_version, :name => 'version'

  exportable_group 'properties'
    # Returns or sets the displayed title of the page, which may differ from
    # the topic of the page. As of Ruwiki 0.8.0, this is not currently used
    # and it may disappear.
    #
    # Class:: +properties+
    # ID::    +title+
  attr_accessor :title
  exportable :title
    # Returns or sets the topic of the page, which may differ from the
    # title. This is used to set the topic on a page being saved.
    #
    # Class:: +properties+
    # ID::    +topic+
  attr_accessor :topic
  exportable :topic
    # Returns or sets the project of the page, which may differ from the
    # title. This is used to set the project on a page being saved.
    #
    # Class:: +properties+
    # ID::    +project+
  attr_accessor :project
  exportable :project
    # Returns or sets the creator of the page. Unless we know the user
    # (through the authentication mechanism, only partially implemented for
    # Ruwiki 0.9.0), this will be +nil+.
    #
    # Class:: +properties+
    # ID::    +creator+
  attr_accessor :creator
  exportable :creator
    # Returns or sets the creator's IP address. This should always be set.
    # It will have a value of "UNKNOWN" on the off-chance that something
    # prevents this from working.
    #
    # Class:: +properties+
    # ID::    +creator-ip+
  attr_accessor :creator_ip
  exportable :creator_ip
    # Returns or sets the date of creation.
    #
    # Class:: +properties+
    # ID::    +create-date+
  attr_accessor :create_date
  exportable :create_date
    # Returns or sets the last editor of the page. Unless we know the user
    # (through the authentication mechanism, only partially implemented for
    # Ruwiki 0.9.0), this will be +nil+.
    #
    # Class:: +properties+
    # ID::    +editor+
  attr_accessor :editor
  exportable :editor
    # Returns or sets the last editor's IP address. This should always be
    # set. It will have a value of "UNKNOWN" on the off-chance that
    # something prevents this from working.
    #
    # Class:: +properties+
    # ID::    +editor-ip+
  attr_accessor :editor_ip
  exportable :editor_ip
    # Returns or sets the date of the last edit.
    #
    # Class:: +properties+
    # ID::    +edit-date+
  attr_accessor :edit_date
  exportable :edit_date
    # Indicates whether the page is editable. Non-editable pages are
    # effectively static pages.
    #
    # Class:: +properties+
    # ID::    +editable+
  attr_accessor :editable
  exportable :editable
    # Indicates whether the page is indexable. Non-indexable pages are
    # invisible to compliant web robots, and their links may not be
    # followed.
    #
    # Class:: +properties+
    # ID::    +indexable+
  attr_accessor :indexable
  exportable :indexable
    # The current version of the page. The old version is always (#version
    # - 1).
    #
    # Class:: +properties+
    # ID::    +version+
  attr_accessor :version
  exportable :version
    # An array of complete tags that will appear in the HTML <HEAD> section.
    # Can be used to specify additional CSS, <META> tags, or even JavaScript
    # on a per-page basis. Currently unused.
    #
    # Class:: +properties+
    # ID::    +html-headers+
  attr_accessor :html_headers
  exportable :html_headers
    # The entropy of the page. This is a ratio of the number of lines
    # changed in the file vs. the total number of lines in the file. This
    # value is currently unused. (And, sad to say, I don't remember why
    # I included it. However, it's an interesting value that may be useful
    # in spam fighting techniques. It is currently stored in the meta-data,
    # but that may change moving forward.)
    #
    # Class:: +properties+
    # ID::    +entropy+
  attr_reader :entropy
  exportable :entropy
    # The edit comment for the current revision of the page.
    #
    # Class:: +properties+
    # ID::    +edit-comment+
  attr_accessor :edit_comment
  exportable :edit_comment

  exportable_group 'page'
    # The header content of the page. This is static content (in either Wiki
    # or HTML formats) that appears before the editable contents of the
    # page. If both this and Wiki-level header content are specified, this
    # will appear *after* the Wiki-level header content.
    #
    # Class:: +page+
    # ID::    +header+
  attr_accessor :header
  exportable :header
    # The footer content of the page. This is static content (in either Wiki
    # or HTML formats) that appears before the editable contents of the
    # page. If both this and Wiki-level footer content are specified, this
    # will appear *before* the Wiki-level footer content.
    #
    # Class:: +page+
    # ID::    +footer+
  attr_accessor :footer
  exportable :footer
    # The editable unformatted Wiki content of the page.
    #
    # Class:: +page+
    # ID::    +content+
  attr_accessor :content
  exportable :content

    # Creates a Ruwiki page. This must be created from the canonical export
    # hash.
  def initialize(exported = {})
    ruwiki = exported['ruwiki']
    @content_version  = (ruwiki['content-version'] || Ruwiki::CONTENT_VERSION).to_i
    @ruwiki_version   = ruwiki['version']         || Ruwiki::VERSION

    props = exported['properties']
    @title        = props['title']
    @topic        = props['topic']        || "NewTopic"
    @project      = props['project']      || "Default"
    @creator      = props['creator']      || ""
    @creator_ip   = props['creator-ip']   || "UNKNOWN"
    @create_date  = Time.at((props['create-date']  || Time.now.utc).to_i)
    @editor       = props['editor']       || ""
    @editor_ip    = props['editor-ip']    || "UNKNOWN"
    @edit_date    = Time.at((props['edit-date']    || Time.now.utc).to_i)
    @edit_comment = props['edit-comment'] || ""
    case props['editable']
    when "false"
      @editable = false
    else
      @editable = true
    end
    case props['indexable']
    when "false"
      @indexable = false
    else
      @indexable = true
    end
    @entropy      = (props['entropy']      || 0).to_f
    @html_headers = props['html-headers'] || []
    @version      = (props['version']      || 0).to_i

    page = exported['page']
    @header       = page['header']  || ""
    @content      = page['content'] || ""
    @footer       = page['footer']  || ""

      # Fix the possibility that the content might be an array of chunks.
    @content = @content.join("") if @content.kind_of?(Array)

    @content.gsub!(/\r/, "")
  end

    # Outputs the HTML version of the page.
  def to_html(markup)
      # Normalise the content, first
    @content.gsub!(/\r/, "")
    markup.parse(@content, @project)
  end

    # Provides the canonical export hash.
  def export
    sym = super

    sym.each_key do |sect|
      if sect == 'ruwiki'
        sym[sect]['content-version'] = Ruwiki::CONTENT_VERSION
        sym[sect]['version'] = Ruwiki::VERSION
      else
        sym[sect].each_key do |item|
          case [sect, item]
          when ['properties', 'create-date'], ['properties', 'edit-date']
            sym[sect][item] = sym[sect][item].to_i
          when ['properties', 'editable'], ['properties', 'indexable']
            sym[sect][item] = (sym[sect][item] ? 'true' : 'false')
          else
            sym[sect][item] = sym[sect][item].to_s
          end
        end
      end
    end

    sym
  end

  NULL_PAGE = {
      'ruwiki' => {
        'content-version' => Ruwiki::CONTENT_VERSION,
        'version'         => Ruwiki::VERSION
      },
      'properties' => { },
      'page' => { },
    }
end
