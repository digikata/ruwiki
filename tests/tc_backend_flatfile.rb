#!/usr/bin/env ruby
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

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

require 'harness'
require 'ruwiki/backend/flatfiles'
require 'ostruct'
require 'test/unit'
require 'fileutils'

class TestBackendFlatfiles < Test::Unit::TestCase
  def setup
    @ffopts = { 'data-path' => "./test/data", 'extension' => nil }

      # generate a database
    raise "Setup Error: #{@ffopts['data-path']} exists" if File.exists?(@ffopts['data-path']) 

    @flatbase = {
      'Proj1' => ['ProjectIndex:all projects must have this',
                  'P1TopicOne:this is the content',
                  'P1TopicTwo:more content'],
      'Proj2' => ['ProjectIndex:all projects must have this',
                  'P2TopicOne:this is the content',
                  'P2TopicTwo:more content',
                  'P2TopicThree:even more more content']
    }
    
    @flatbase.each do |key, val|
      prjdir = "#{@ffopts['data-path']}/#{key}"
      FileUtils.mkdir_p(prjdir) rescue nil
      val.each do |topcon|
        topic, content = topcon.split(":")
        File.open("#{prjdir}/#{topic}", "w") do |fh|
          fh.puts "page!content:\x09#{content}"
        end
      end
    end

    @backend = nil
    @pg = nil
  end

  def teardown
      # remove testing flatabase
    FileUtils.rm_rf(@ffopts['data-path'])
    Dir.rmdir("./test") # ugly but it works
  end

  def test_list_projects
    assert_nothing_raised { @backend = Ruwiki::Backend::Flatfiles.new(@ffopts) }

      # should be ['Proj1', 'Proj2']
    assert_equal(@flatbase.keys, @backend.list_projects)
  end

  def test_list_topics
    assert_nothing_raised { @backend = Ruwiki::Backend::Flatfiles.new(@ffopts) }

    @flatbase.keys.sort.each do |proj|
      got_topics = @backend.list_topics(proj)
      exp_topics = @flatbase[proj].map { |ent| ent.split(':')[0] }
      assert_equal(exp_topics.sort, got_topics.sort)
    end
  end

    # test simple one word lookups
    # need to add more complex search strings
  def test_search_project
    assert_nothing_raised { @backend = Ruwiki::Backend::Flatfiles.new(@ffopts) }

    assert_equal({'ProjectIndex' => 1,
                  'P1TopicOne'   => 1,
                  'P1TopicTwo'   => 0 }.to_a.sort,
                 @backend.search_project('Proj1', 'this').to_a.sort)
    assert_equal({'ProjectIndex' => 0,
                  'P1TopicOne'   => 0,
                  'P1TopicTwo'   => 1 }.to_a.sort,
                 @backend.search_project('Proj1', 'more').to_a.sort)
    assert_equal({'ProjectIndex' => 0,
                  'P1TopicOne'   => 1,
                  'P1TopicTwo'   => 1 }.to_a.sort,
                 @backend.search_project('Proj1', 'topic').to_a.sort)
    assert_equal({'ProjectIndex' => 0,
                  'P1TopicOne'   => 1,
                  'P1TopicTwo'   => 1 }.to_a.sort,
                 @backend.search_project('Proj1', 'content').to_a.sort)
    assert_equal({'ProjectIndex' => 0,
                  'P2TopicOne'   => 0,
                  'P2TopicTwo'   => 1,
                  'P2TopicThree' => 2 }.to_a.sort,
                 @backend.search_project('Proj2', 'more').to_a.sort)
  end
end
